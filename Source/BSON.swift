//
//  BSON.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public typealias BSONType = bson_type


public final class BSON: DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = AnyObject
    public typealias Pair = (Key, Value)

    internal(set) var bs: bson

    public init(_ elements: [String: AnyObject]) {
        bs = bson()
        bson_init(&bs)
        let b = BSONBuilder(elements)
        b.setToBSON(self)
    }

    public init(query elements: [String: AnyObject]) {
        bs = bson()
        bson_init_as_query(&bs)
        let b = BSONBuilder(elements)
        b.setToBSON(self)
    }

    public required init(dictionaryLiteral elements: Pair...) {
        bs = bson()
        bson_init(&bs)
        let b = BSONBuilder(elements: elements)
        b.setToBSON(self)
    }

    internal init(query: Bool = false) {
        bs = bson()
        if query {
            bson_init_as_query(&bs)
        } else {
            bson_init(&bs)
        }
    }

    internal init(b: bson) {
        self.bs = b
    }

    deinit {
        bson_destroy(&bs)
    }

    public var size: Int {
        return Int(bson_size(&bs))
    }

    public var data: UnsafePointer<Int8> {
        return bson_data(&bs)
    }
}

// MARK: - BSON utils

extension BSON {
    public func duplicate() -> BSON {
        let b = bson_dup(&bs)
        return BSON(b: b.memory)
    }

    public func merge(bson: BSON, overwrite: Bool = false, recursive: Bool = false) -> BSON {
        let out = BSON(query: false)
        let ow  = Int32(overwrite ? 1 : 0)
        if recursive {
            bson_merge_recursive(&bs, &bson.bs, ow, &out.bs)
        } else {
            bson_merge(&bs, &bson.bs, ow, &out.bs)
        }
        return out
    }

    public func validate(checkDots dot: Bool = false, checkDollars dollar: Bool = false) -> Bool {
        return BSON_OK == bson_validate(&bs, dot, dollar)
    }

    public static func fromJSONString(string: String) -> BSON {
        let bs = string.withCString { s in
            return json2bson(s)
        }
        return BSON(b: bs.memory)
    }

    public func toJSONString() -> String {
        let buf = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>.alloc(1)
        let len = UnsafeMutablePointer<Int32>.alloc(1)
        defer {
            buf.destroy()
            len.destroy()
        }
        bson2json(data, buf, len)

        return String.fromCString(buf.memory) ?? ""
    }
}

// MARK: - BSON construct functions

extension BSON {
    public func append(name: String, value: String) -> BSON? {
        return name.withCString { n in
            value.withCString { v in
                return bson_append_string(&bs, n, v) == BSON_OK ? self : nil
            }
        }
    }

    public func append(name: String, value: Int) -> BSON? {
        return name.withCString { n in
            // FIXME value range in Int32
            return bson_append_int(&bs, n, Int32(value)) == BSON_OK ? self : nil
        }
    }

    public func appendObject(name: String) -> BSON? {
        return name.withCString { n in
            return bson_append_start_object(&bs, n) == BSON_OK ? self : nil
        }
    }

    public func appendObjectFinish() -> BSON? {
        return bson_append_finish_object(&bs) == BSON_OK ? self : nil
    }

    public func finish() -> BSON? {
        return bson_finish(&bs) == 0 ? self : nil
    }
}


public final class BSONIterator: RawMemoryConvertible {
    private var iter: UnsafeMutablePointer<bson_iterator>

    public required init() {
        iter = bson_iterator_create()
    }

    public required init(memory: UnsafePointer<Int8>) {
        iter = bson_iterator_create()
        bson_iterator_from_buffer(iter, memory)
    }

    public func next() -> BSONType {
        return bson_iterator_next(iter)
    }

    public var more: Bool {
        return bson_iterator_more(iter) == 0
    }

    public func find(name: String, bson: BSON) -> bson_type {
        return name.withCString { p in
            return bson_find(iter, &bson.bs, p)
        }
    }

    public func find(path: String) -> bson_type {
        return path.withCString { p in
            return bson_find_fieldpath_value(p, iter)
        }
    }

    public var key: String {
        return String.fromCString(bson_iterator_key(iter)) ?? ""
    }

    public var oid: OID {
        let id = bson_iterator_oid(iter)
        assert(id != nil)
        return OID(oid: id.memory)
    }

    public var stringValue: String {
        return String.fromCString(bson_iterator_string(iter)) ?? ""
    }

    public var intValue: Int {
        return Int(bson_iterator_int(iter))
    }

    public var longValue: Int64 {
        return Int64(bson_iterator_long(iter))
    }

    public var doubleValue: Double {
        return bson_iterator_double(iter)
    }

    public var boolValue: Bool {
        return Bool(bson_iterator_int(iter) != 0)
    }

    public var dateValue: NSDate {
        let t = bson_iterator_time_t(iter)
        return NSDate(timeIntervalSince1970: NSTimeInterval(t))
    }

    public var regexValue: NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: stringValue, options: [])
        } catch {
            return NSRegularExpression()
        }
    }

    public var binaryData: NSData {
        //let type = bson_iterator_bin_type(iter)
        let len  = bson_iterator_bin_len(iter)
        let data = bson_iterator_bin_data(iter)
        return NSData(bytes: data, length: Int(len))
    }

    public var subIterator: BSONIterator {
        let it = BSONIterator()
        bson_iterator_subiterator(iter, it.iter)
        return it
    }

    public var object: [String: AnyObject] {
        var d = [String: AnyObject]()
        for var t = next(); t != BSON_EOO; t = next() {
            d[key] = anyObject(t)
        }
        return d
    }

    public var array: [AnyObject] {
        var d = [AnyObject]()
        for var t = next(); t != BSON_EOO; t = next() {
            d.append(anyObject(t))
        }
        return d
    }

    private func anyObject(t: bson_type) -> AnyObject {
        switch t.rawValue {
        case BSON_UNDEFINED.rawValue: return NSNull()
        case BSON_NULL.rawValue:      return NSNull()
        case BSON_OID.rawValue:       return oid.description
        case BSON_BOOL.rawValue:      return boolValue
        case BSON_INT.rawValue:       return intValue
        case BSON_LONG.rawValue:      return Int(longValue) // TODO: overflow check
        case BSON_DOUBLE.rawValue:    return doubleValue
        case BSON_STRING.rawValue:    return stringValue
        case BSON_DATE.rawValue:      return dateValue
        case BSON_BINDATA.rawValue:   return binaryData
        case BSON_REGEX.rawValue:     return regexValue
        case BSON_OBJECT.rawValue:    return subIterator.object
        case BSON_ARRAY.rawValue:     return subIterator.array
        case BSON_CODE.rawValue:
            () // TODO
        case BSON_SYMBOL.rawValue:
            () // TODO
        case BSON_CODEWSCOPE.rawValue:
            () // TODO
        case BSON_TIMESTAMP.rawValue:
            () // TODO
        default:
            ()
        }
        return NSNull()
    }
}


public final class BSONBuilder: DictionaryLiteralConvertible {
    public typealias Key = String
    public typealias Value = AnyObject
    public typealias Pair = (Key, Value)

    private let pairs: [Pair]

    public required init(_ elements: [String: AnyObject]) {
        pairs = elements.map { e in
            return (e.0, e.1)
        }
    }

    internal init(elements: [Pair]) {
        self.pairs = elements
    }

    public required init(dictionaryLiteral elements: Pair...) {
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

    public func toBSON(query: Bool = false) -> BSON {
        let bsonObj = BSON(query: query)
        setToBSON(bsonObj)
        return bsonObj
    }

    internal func setToBSON(bsonObj: BSON) {
        for kv in pairs {
            constructBSON(bsonObj, key: kv.0, value: kv.1)
        }

        bson_finish(&bsonObj.bs)
    }
}
