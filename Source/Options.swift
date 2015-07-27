//
//  Options.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public struct OpenMode : OptionSetType {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    static var Reader:         OpenMode { return OpenMode(rawValue: JBOREADER) }
    static var Writer:         OpenMode { return OpenMode(rawValue: JBOWRITER) }
    static var Create:         OpenMode { return OpenMode(rawValue: JBOCREAT) }
    static var Truncate:       OpenMode { return OpenMode(rawValue: JBOTRUNC) }
    static var NoLock:         OpenMode { return OpenMode(rawValue: JBONOLCK) }
    static var LockNoBlocking: OpenMode { return OpenMode(rawValue: JBOLCKNB) }
    static var Sync:           OpenMode { return OpenMode(rawValue: JBOTSYNC) }
}

