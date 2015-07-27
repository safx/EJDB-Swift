//
//  Collection.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public final class Collection {
    let coll: COpaquePointer

    init(name: String, database: Database) { // FIXME: EJCOLLOPTS to args
        assert(name.characters.count < Int(JBMAXCOLNAMELEN))
        coll = name.withCString { str in
            return ejdbcreatecoll(database.jb, str, nil)
        }
        assert(coll != nil)
    }

    func save(bson: BSON) { // FIXME: add oid to args
        var oid: bson_oid_t = bson_oid_t()
        ejdbsavebson(coll, &bson.bs, &oid)
    }

    func query(query: Query) -> OpaqueList<BSONIterator> {
        var count: UInt32 = 0
        let result = ejdbqryexecute(coll, query.q, &count, 0, nil) // FIXME: fixed param
        return OpaqueList(list: result)
    }

    func sync() -> Bool {
        return ejdbsyncoll(coll)
    }
}