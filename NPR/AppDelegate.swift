//
//  AppDelegate.swift
//  NPR
//
//  Created by Connor Montgomery on 6/8/20.
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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let streamURL = URL.init(string: "https://kcurlive.umkc.edu/kcur893") else { return }
        let streamItem = AVPlayerItem.init(url: streamURL)
        player.replaceCurrentItem(with: streamItem)
        player.play()
        isCurrentlyPlaying = true

        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.button?.title = "Hello, world!"
        statusBarItem.menu = menu

        menu.addItem(NSMenuItem.init(title: "Play / Pause", action: #selector(togglePlayPause), keyEquivalent: ""))
    }

    @objc func togglePlayPause() {
        if isCurrentlyPlaying {
            player.pause()
            isCurrentlyPlaying = false
        } else {
            player.play()
            isCurrentlyPlaying = true
        }
    }
}
