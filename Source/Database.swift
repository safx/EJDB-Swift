//
//  Database.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public final class Database {

    internal let jb: COpaquePointer

    public init() {
        jb = ejdbnew()
    }

    deinit {
        close()
    }

    public func open(path: String, mode: OpenMode) -> Bool { // TODO: throws
        return path.withCString { str in
            return ejdbopen(jb, str, Int32(mode.rawValue))
        }
    }

    public func close() -> Bool { // TODO: throws
        return ejdbclose(jb)
    }

    public func delete() {
        ejdbdel(jb)
    }

    public var isOpen: Bool {
        return ejdbisopen(jb)
    }

    public var meta: BSON {
        let m = ejdbmeta(jb)
        assert(m != nil)
        return BSON(b: m.memory)
    }

    public func sync() -> Bool {
        return ejdbsyncdb(jb)
    }

    public func removeCollection(name: String, database: Database, unlinkFile: Bool) {
        return name.withCString { str in
            ejdbrmcoll(jb, str, unlinkFile)
        }
    }
    
    public func getCollection(name: String) -> Collection {
        return name.withCString { str in
            let coll = ejdbgetcoll(jb, str)
            assert(coll != nil)
            return Collection(coll: coll)
        }
    }

}