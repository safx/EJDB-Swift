//
//  Collection.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation



public final class Collection {
    public typealias QueryResult = OpaqueList<BSONIterator>

    private let coll: COpaquePointer

    public init(name: String, database: Database) { // FIXME: EJCOLLOPTS to args
        assert(name.characters.count < Int(JBMAXCOLNAMELEN))
        coll = name.withCString { str in
            return ejdbcreatecoll(database.jb, str, nil)
        }
        assert(coll != nil)
    }

    internal init(coll: COpaquePointer) {
        self.coll = coll
    }

    public func save(bson: BSON, oid: OID = OID()) {
        ejdbsavebson(coll, &bson.bs, &oid.oid)
    }

    public func remove(oid: OID) -> Bool {
        return ejdbrmbson(coll, &oid.oid)
    }

    public func load(oid: OID) -> BSON {
        let b = ejdbloadbson(coll, &oid.oid)
        assert(b != nil)
        return BSON(b: b.memory)
    }

    public func query(query: Query) -> QueryResult {
        var count: UInt32 = 0
        let result = ejdbqryexecute(coll, query.q, &count, 0, nil) // FIXME: fixed param
        return OpaqueList(list: result)
    }

    public func sync() -> Bool {
        return ejdbsyncoll(coll)
    }

    public func transaction(@noescape closure: Collection -> Bool) {
        ejdbtranbegin(coll)
        if closure(self) {
            ejdbtrancommit(coll)
        } else {
            ejdbtranabort(coll)
        }
    }
}

