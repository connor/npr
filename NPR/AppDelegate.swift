//
//  AppDelegate.swift
//  NPR
//
//  Created by Connor Montgomery on 1/3/19.
//  Copyright © 2019 Connor Montgomery. All rights reserved.
//

import Cocoa
import Preferences
import AVFoundation

public enum NPRMenuItemType:Int {
    case separator
    case quit
    case playPause
    case preferences
    case currentStation
    case donate
    case chooseStation
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    var statusBar = NSStatusBar.system
    var isPlaying:Bool = false
    var player:AVPlayer = AVPlayer.init()
    var keyTap:SPMediaKeyTap?
    var statusBarItem:NSStatusItem = NSStatusItem()
    var menu:NSMenu = NSMenu()
    var menuItemTypes:[NPRMenuItemType] = []
    let preferencesWindowController = PreferencesWindowController(
        viewControllers: [
            StationsViewController(),
            AboutViewController()
        ]
    )

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        keyTap = SPMediaKeyTap.init(delegate: self)
        if keyTap != nil {
            keyTap?.startWatchingMediaKeys()
        }
        
        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.menu = menu
        statusBarItem.button?.image = NSImage.init(named: "npr-icon")
        statusBarItem.button?.imagePosition = .imageRight
        
        NotificationCenter.default.addObserver(self, selector: #selector(stationDidChange(notification:)), name: .stationChanged, object: nil)
    
        player.volume = 1.0
        updateMenuIcon()
        if let currentStation = StationsManager.sharedManager.currentStation {
            setStationToPlay(station: currentStation)
        } else {
            // explicitly call it here since it's called in setStationToPlay
            buildMenu()
        }
    }
    
    func generateMenuItemTypes() -> Void {
        var itemTypes:[NPRMenuItemType] = []
        if let _ = StationsManager.sharedManager.currentStation {
            itemTypes.append(.playPause)
            itemTypes.append(.separator)
            itemTypes.append(.currentStation)
            itemTypes.append(.donate)
            itemTypes.append(.separator)
            itemTypes.append(.preferences)
            itemTypes.append(.quit)
        } else {
            itemTypes.append(.chooseStation)
            itemTypes.append(.separator)
            itemTypes.append(.quit)
        }
        
        menuItemTypes = itemTypes
    }
    
    func buildMenu() -> Void {
        generateMenuItemTypes()
        var menuItems:[NSMenuItem] = []
        for menuItemType in menuItemTypes {
            if let menuItem = buildMenuItem(itemType: menuItemType) {
                menuItems.append(menuItem)
            }
        }
        menu.removeAllItems()
        for menuItem in menuItems {
            menu.addItem(menuItem)
        }
    }
    
    func buildMenuItem(itemType:NPRMenuItemType) -> NSMenuItem? {
        switch itemType {
        case .separator:
            return NSMenuItem.separator()
        case .quit:
            let menuItem = NSMenuItem.init(title: "Quit", action: #selector(didTapQuit), keyEquivalent: "q")
            menuItem.keyEquivalentModifierMask = NSEvent.ModifierFlags.command
            return menuItem
        case .playPause:
            return NSMenuItem.init(title: isPlaying ? "Pause" : "Play", action: #selector(didTapPlayPause), keyEquivalent: "")
        case .preferences:
            let menuItem = NSMenuItem.init(title: "Preferences", action: #selector(didTapPreferences), keyEquivalent: ",")
            menuItem.keyEquivalentModifierMask = NSEvent.ModifierFlags.command
            return menuItem
        case .currentStation:
            if let title = StationsManager.sharedManager.currentStation?.getCurrentlyListeningTitle() {
                return NSMenuItem.init(title: title, action: #selector(didTapCurrentStation), keyEquivalent: "")
            }
            return nil
        case .donate:
            if let _ = StationsManager.sharedManager.currentStation?.getDonateObject() {
                return NSMenuItem.init(title: "Donate", action: #selector(didTapDonate), keyEquivalent: "")
            }
            return nil
        case .chooseStation:
            return NSMenuItem.init(title: "Choose station", action: #selector(didTapPreferences), keyEquivalent: "")
        }
    }
    
    @objc func stationDidChange(notification:NSNotification) {
        if let station = notification.object as? Station {
            setStationToPlay(station: station)
        }
    }
    
    func setStationToPlay(station:Station) -> Void {
        let newStreamItem = AVPlayerItem.init(url: URL.init(string: (station.getPrimaryStream()?.href)!)!) // TODO: make this an extension on the Station
        player.replaceCurrentItem(with: newStreamItem)
        player.play()
        isPlaying = true
        updateMenuIcon()
        buildMenu()
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        window.orderOut(self)
    }
    
    func updateMenuIcon() -> Void {
        let imageName = isPlaying ? "npr-icon" : "npr-icon-greyscale"
        self.statusBarItem.button?.image = NSImage.init(named: imageName)
    }
    
    func toggle() -> Void {
        isPlaying ? player.pause() : player.play()
        isPlaying = !isPlaying
        updateMenuIcon()
        buildMenu()
    }
    
    @objc func didTapPreferences() -> Void {
        preferencesWindowController.showWindow()
    }
    
    @objc func didTapQuit() -> Void {
        NSApplication.shared.terminate(self)
    }
    
    @objc func didTapPlayPause() -> Void {
        self.toggle()
    }
    
    @objc func didTapDonate() -> Void {
        if let donation = StationsManager.sharedManager.currentStation?.getDonateObject() {
            if let donateURL = URL.init(string: donation.href) {
                NSWorkspace.shared.open(donateURL)
            }
        }
    }
    
    @objc func didTapCurrentStation() -> Void {
        if let currentStation = StationsManager.sharedManager.currentStation {
            if let currentStationBrand = currentStation.links.brand?.first {
                if let currentStationURL = URL.init(string: currentStationBrand.href) {
                    NSWorkspace.shared.open(currentStationURL)
                }
            }
        }
    }
    
    // MARK - SPMediaKeyTap
    
    override func mediaKeyTap(_ keyTap: SPMediaKeyTap!, receivedMediaKeyEvent event: NSEvent!) {
        let keyCode = Int32(((event.data1 & 0xFFFF0000) >> 16))
        let keyFlags = event.data1 & 0x0000FFFF
        let keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA
        if keyIsPressed {
            switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                toggle()
                break
            default:
                break
            }
        }
    }
}

