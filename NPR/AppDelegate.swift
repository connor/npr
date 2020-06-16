//
//  AppDelegate.swift
//  NPR
//
//  Created by Connor Montgomery on 6/15/20.
//  Copyright © 2020 Connor Montgomery. All rights reserved.
//

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let player = AVPlayer()

    let statusBar = NSStatusBar.system
    var statusBarItem:NSStatusItem!

    var menu:NSMenu = NSMenu()
    var isCurrentlyPlaying = false
    let playPauseIcon = NSMenuItem.init(title: "Pause", action: #selector(togglePlayPause), keyEquivalent: "")

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let streamURL = URL.init(string: "https://kcurlive.umkc.edu/kcur893") else { return }
        let streamItem = AVPlayerItem.init(url: streamURL)
        player.replaceCurrentItem(with: streamItem)
        player.play()
        isCurrentlyPlaying = true

        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.button?.image = NSImage.init(named: "npr-icon")
        statusBarItem.menu = menu

        menu.addItem(playPauseIcon)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem.init(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        updateMenuIcon()
        updatePlayPauseButtonTitle()
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }

    @objc func togglePlayPause() {
        if isCurrentlyPlaying {
            player.pause()
            isCurrentlyPlaying = false
        } else {
            player.play()
            isCurrentlyPlaying = true
        }

        updateMenuIcon()
        updatePlayPauseButtonTitle()
    }

    func updateMenuIcon() -> Void {
        let imageName = isCurrentlyPlaying ? "npr-icon" : "npr-icon-greyscale"
        self.statusBarItem.button?.image = NSImage.init(named: imageName)
    }

    func updatePlayPauseButtonTitle() {
        playPauseIcon.title = isCurrentlyPlaying ? "Pause" : "Play"
    }
}
