//
//  BSON.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public final class BSON {

    var bs: bson

    internal init(query: Bool = false) {
        bs = bson()
        if query {
            bson_init_as_query(&bs)
        } else {
            bson_init(&bs)
        }
    }

    deinit {
        bson_destroy(&bs)
    }

    func append(name: String, value: String) -> BSON? {
        return name.withCString { n in
            value.withCString { v in
                return bson_append_string(&bs, n, v) == BSON_OK ? self : nil
            }
        }
    }

    func append(name: String, value: Int) -> BSON? {
        return name.withCString { n in
            // FIXME value range in Int32
            return bson_append_int(&bs, n, Int32(value)) == BSON_OK ? self : nil
        }
    }

    func appendObject(name: String) -> BSON? {
        return name.withCString { n in
            return bson_append_start_object(&bs, n) == BSON_OK ? self : nil
        }
    }

    func appendObjectFinish() -> BSON? {
        return bson_append_finish_object(&bs) == BSON_OK ? self : nil
    }

    func finish() -> BSON? {
        return bson_finish(&bs) == 0 ? self : nil
    }
}


public final class BSONIterator: RawMemoryConvertible {
    var iter: UnsafeMutablePointer<bson_iterator>

    public required init(memory: UnsafePointer<Int8>) {
        iter = bson_iterator_create()
        bson_iterator_from_buffer(iter, memory)
    }

    func next() -> bson_type {
        return bson_iterator_next(iter)
    }

    var more: Bool {
        return bson_iterator_more(iter) == 0
    }

    var key: String {
        return String.fromCString(bson_iterator_key(iter)) ?? ""
    }

    var stringValue: String {
        return String.fromCString(bson_iterator_string(iter)) ?? ""
    }

    var intValue: Int {
        return Int(bson_iterator_int(iter))
    }

    var boolValue: Bool {
        return Bool(bson_iterator_int(iter) != 0)
    }
}


public final class BSONBuilder: DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = AnyObject
    public typealias Pair = (Key, Value)

    let pairs: [Pair]

    required public init(dictionaryLiteral elements: Pair...) {
        self.pairs = elements
    }

    private func constructBSON(bsonObj: BSON, dictionary: NSDictionary) {
        guard let dic = dictionary as? [String: AnyObject] else {
            // FIXME: Error
            return
        }

        for kv in dic {
            constructBSON(bsonObj, key: kv.0, value: kv.1)
        }
    }

    private func constructBSON(bsonObj: BSON, array: NSArray) {
        for kv in array.enumerate() {
            constructBSON(bsonObj, key: String(kv.0), value: kv.1)
        }
    }

    private func constructBSON(bsonObj: BSON, key: String, value: AnyObject) {
        print(key)
        key.withCString { k -> () in
            if value is NSNull {
                bson_append_null(&bsonObj.bs, k)
            } else if let v = value as? NSDictionary {
                bson_append_start_object(&bsonObj.bs, k)
                constructBSON(bsonObj, dictionary: v)
                bson_append_finish_object(&bsonObj.bs)
            } else if let v = value as? NSArray {
                bson_append_start_array(&bsonObj.bs, k)
                constructBSON(bsonObj, array: v)
                bson_append_finish_array(&bsonObj.bs)
            } else if let v = value as? NSString {
                bson_append_string(&bsonObj.bs, k, v.UTF8String)
            } else if let v = value as? NSNumber {
                if String.fromCString(v.objCType) == "c" {
                    bson_append_bool(&bsonObj.bs, k, v.boolValue ? 1 : 0)
                } else {
                    let t = CFNumberGetType(v)
                    switch t {
                    case .IntType:
                        bson_append_int(&bsonObj.bs, k, v.intValue)
                    case .SInt64Type:
                        // range check
                        bson_append_int(&bsonObj.bs, k, v.intValue)
                    default:
                        ()
                    }
                }
            } else {
                bson_append_string(&bsonObj.bs, k, "\(value)")
            }
        }
    }

    func toBSON(query: Bool = false) -> BSON {
        let bsonObj = BSON(query: query)

        for kv in pairs {
            constructBSON(bsonObj, key: kv.0, value: kv.1)
        }

        bson_finish(&bsonObj.bs)

        return bsonObj
    }
}


