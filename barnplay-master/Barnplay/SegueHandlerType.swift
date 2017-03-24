//
//  SegueHandlerType.swift
//
//  Created by Oskar Ek on 2015-08-03.
//  Copyright © 2015 OskarApps. All rights reserved.
//

import UIKit

protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier, segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identifier: \(segue.identifier)")
        }
        return segueIdentifier
    }

    func performSegueWithIdentifier(identifier: SegueIdentifier, sender: AnyObject?) {
        performSegueWithIdentifier(identifier.rawValue, sender: sender)
    }
}
