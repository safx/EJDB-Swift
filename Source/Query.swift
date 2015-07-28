//
//  Query.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public final class Query {
    internal(set) var q: COpaquePointer

    public init(query: BSON, database: Database) {
        q = ejdbcreatequery(database.jb, &query.bs, nil, 0, nil) // FIXME: fixed param
        assert(q != nil)
    }

    deinit {
        ejdbquerydel(q)
    }
}
