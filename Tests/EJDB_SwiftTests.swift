//
//  EJDB_SwiftTests.swift
//  EJDB-SwiftTests
//
//  Created by Safx Developer on 2015/07/26.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import XCTest
@testable import EJDBSwift

class EJDB_SwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, [.UserDomainMask], true);
        let dbPath = paths[0] + "/addressbook.db"

        let db = Database()
        db.open(dbPath, mode: [.Writer, .Create, .Truncate])
        let col = Collection(name: "foo", database: db)

        let b1: BSON = [
            "address": "Somewhere",
            "name": "foreign",
            "age": 443,
            "hoge": false
        ]
        col.save(b1)

        let b2: BSON = [
            "address": "Canada",
            "name": "fooobar",
            "age": 999,
            "hoge": true
        ]
        col.save(b2)

        let b3: BSON = [
            "address": "Canada",
            "name": "barrrr",
            "age": 1024,
            "hoge": true
        ]
        col.save(b3)

        let qry = Query(query: BSON(query: [ "name": ["$begin": "fo"] ]), database: db)
        col.query(qry).map { it -> () in
            for var t = it.next(); t != BSON_EOO; t = it.next() {
                //print(t)
                print(it.key)
                switch t.rawValue {
                case BSON_OID.rawValue:
                    print(it.oid)
                case BSON_STRING.rawValue:
                    print(it.stringValue)
                case BSON_INT.rawValue:
                    print(it.intValue)
                case BSON_BOOL.rawValue:
                    print(it.boolValue)
                default:
                    ()
                }
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
