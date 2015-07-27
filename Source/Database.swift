//
//  Database.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public final class Database {

    let jb: COpaquePointer

    init() {
        jb = ejdbnew()
    }

    deinit {
        close()
    }

    func open(path: String, mode: OpenMode) -> Bool { // TODO: throws
        return path.withCString { str -> Bool in
            return ejdbopen(jb, str, Int32(mode.rawValue))
        }
    }

    func close() -> Bool { // TODO: throws
        return ejdbclose(jb)
    }

    func delete() {
        ejdbdel(jb)
    }

    var isOpen: Bool {
        return ejdbisopen(jb)
    }

    /*func getCollection(name: String) { // FIXME
    return name.withCString { str in
    ejdbgetcoll(jb, name)
    }
    }*/

    func sync() -> Bool {
        return ejdbsyncdb(jb)
    }
}