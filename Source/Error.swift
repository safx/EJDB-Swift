//
//  Error.swift
//  EJDB-Swift
//
//  Created by MATSUMOTO Yuji on 7/23/15.
//  Copyright © 2015年 Safx Developers. All rights reserved.
//

import Foundation


public enum DatabaseError: ErrorType {
    case InvalidColumnName
    case InvalidBSON
    case InvalidBSONObjectID
    case InvalidQueryControl

    case Unknown

    init(errorCode: Int) {
        switch errorCode {
        case JBEINVALIDCOLNAME:   self = .InvalidColumnName
        case JBEINVALIDBSON:      self = .InvalidBSON
        case JBEINVALIDBSONPK:    self = .InvalidBSONObjectID
        case JBEQINVALIDQCONTROL: self = .InvalidQueryControl
            /*
        case JBEQINOPNOTARRAY:
        case JBEMETANVALID:
        case JBEFPATHINVALID:
        case JBEQINVALIDQRX:
        case JBEQRSSORTING:
        case JBEQERROR:
        case JBEQUPDFAILED:
        case JBEQONEEMATCH:
        case JBEQINCEXCL:
        case JBEQACTKEY:
        case JBEMAXNUMCOLS:
        case JBEEI:
        case JBEEJSONPARSE:
        case JBETOOBIGBSON:
        case JBEINVALIDCMD:
*/
        default: self = .Unknown
        }
    }
}
