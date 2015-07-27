//
//  List.swift
//  EJDB-Swift
//
//  Created by Safx Developer on 2015/07/28.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation

public protocol RawMemoryConvertible {
    init(memory: UnsafePointer<Int8>)
}

public final class OpaqueList<T: RawMemoryConvertible> {
    var list: UnsafeMutablePointer<TCLIST>

    init(list: UnsafeMutablePointer<TCLIST>) {
        self.list = list
    }

    deinit {
        tclistdel(list)
    }
}

extension OpaqueList: SequenceType {
    public typealias Generator = OpaqueItemGenerator<T>

    public func generate() -> Generator {
        return OpaqueItemGenerator(list: list)
    }
}

public final class OpaqueItemGenerator<T: RawMemoryConvertible>: GeneratorType {
    let list: UnsafeMutablePointer<TCLIST>
    var index: Int = 0

    init(list: UnsafeMutablePointer<TCLIST>) {
        self.list = list
    }

    private var length: Int {
        return Int(tclistnum(list))
    }

    public func next() -> T? {
        if index < length {
            let memPtr = list.memory.array.advancedBy(index).memory.ptr // FIXME: remove `memory`
            ++index

            return T(memory: memPtr)
        }
        
        return nil
    }
}
