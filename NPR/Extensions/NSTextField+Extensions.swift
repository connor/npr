//
//  NSTextField+Extensions.swift
//  NPR
//
//  Created by Connor Montgomery on 1/7/19.
//  Copyright © 2019 Connor Montgomery. All rights reserved.
//

import Cocoa
import Foundation

extension NSTextField {
    public func addLinkableText(text:String, link:String) -> Void {
        self.allowsEditingTextAttributes = true
        
        if let range = self.stringValue.range(of: text) {
            let offset = range.lowerBound.encodedOffset
            let length = range.upperBound.encodedOffset - offset
            let attrString:NSMutableAttributedString = self.attributedStringValue.mutableCopy() as! NSMutableAttributedString
            attrString.addAttributes([NSAttributedString.Key.link: link],
                                     range: NSRange.init(location: offset, length: length))
            self.attributedStringValue = attrString
        }
    }
}
