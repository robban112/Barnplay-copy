//
//  AlertOperation.swift
//  Barnplay
//
//  Created by Oskar Ek on 2016-05-04.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit
import PSOperations

class AlertOperation: Operation {
    // MARK: Properties

    private let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
    private let presentationContext: UIViewController?

    var title: String? {
        get {
            return alertController.title
        }

        set {
            alertController.title = newValue
            name = newValue
        }
    }

    var message: String? {
        get {
            return alertController.message
        }

        set {
            alertController.message = newValue
        }
    }

    // MARK: Initialization

    init(presentationContext: UIViewController? = nil) {
        self.presentationContext = presentationContext ?? UIApplication.sharedApplication().keyWindow?.rootViewController

        super.init()

        addCondition(AlertPresentation())

        /*
            This operation modifies the view controller hierarchy.
            Doing this while other such operations are executing can lead to
            inconsistencies in UIKit. So, let's make them mutally exclusive.
        */
        addCondition(MutuallyExclusive<UIViewController>())
    }

    func addAction(title: String, style: UIAlertActionStyle = .Default, handler: AlertOperation -> Void = { _ in }) {
        let action = UIAlertAction(title: title, style: style) { [weak self] _ in
            if let strongSelf = self {
                handler(strongSelf)
            }

            self?.finish()
        }

        alertController.addAction(action)
    }

    override func execute() {
        guard let presentationContext = presentationContext else {
            finish()

            return
        }

        dispatch_async(dispatch_get_main_queue()) {
            if self.alertController.actions.isEmpty {
                self.addAction("OK")
            }

            presentationContext.presentViewController(self.alertController, animated: true, completion: nil)
        }
    }
}
