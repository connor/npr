//
//  Pref2ViewController.swift
//  NPR
//
//  Created by Connor Montgomery on 1/3/19.
//  Copyright © 2019 Connor Montgomery. All rights reserved.
//

import Cocoa
import Preferences

class AboutViewController: NSViewController, Preferenceable {
    
    let toolbarItemTitle = "About"
    let toolbarItemIcon = NSImage(named: NSImage.infoName)!
    
    @IBOutlet weak var codeLabel: NSTextField!
    @IBOutlet weak var madeByLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        madeByLabel.addLinkableText(text: "@connor", link: "https://www.twitter.com/connor")
        codeLabel.addLinkableText(text: "github.com/connor/npr", link: "github.com/connor/npr")
    }
    
}
