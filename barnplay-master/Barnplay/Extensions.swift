//
//  Extensions.swift
//  Barnplay
//
//  Created by Oskar Ek on 2016-04-26.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import UIKit

// MARK: NSDate extensions
extension NSDate: Comparable { }

public func == (leftDate: NSDate, rightDate: NSDate) -> Bool {
    return leftDate === rightDate || leftDate.compare(rightDate) == .OrderedSame
}

public func < (leftDate: NSDate, rightDate: NSDate) -> Bool {
    return leftDate.compare(rightDate) == .OrderedAscending
}

// MARK: SequenceType extensions
extension SequenceType {
    /// Returns first element in self that satisfies the given predicate, or `nil` if no such element exists.
    func find(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
        for element in self {
            if try predicate(element) { return element }
        }
        return nil
    }
}
