//
//  OID.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/29.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public final class OID {
    internal(set) var oid: bson_oid_t = bson_oid_t()

    public init() {}

    public init(string: String) {
        string.withCString { s in
            bson_oid_from_string(&oid, s)
        }
    }

    public init(oid: bson_oid_t) {
        self.oid = oid
    }

    public static func generate() -> OID {
        let o = OID()
        bson_oid_gen(&o.oid)
        return o
    }
}

extension OID: CustomStringConvertible {
    public var description: String {
        var ch = Array<Int8>(count: 25, repeatedValue: 0)
        ch.withUnsafeMutableBufferPointer { p -> () in
            bson_oid_to_string(&oid, p.baseAddress)
            ()
        }
        return String.fromCString(ch) ?? ""
    }
}

