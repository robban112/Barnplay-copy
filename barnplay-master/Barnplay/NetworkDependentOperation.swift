//
//  NetworkDependentOperation.swift
//  Barnplay
//
//  Created by Oskar Ek on 2016-05-07.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit
import PSOperations

class NetworkDependentOperation: Operation {

    init(hosts: [String], presentationContext: UIViewController? = nil, successCompletionHandler: (Void -> Void)? = nil, opClosure: (Void -> Operation)) {
        super.init()

        for host in hosts.flatMap({ NSURL(string: $0) }) {
            let reachabilityCondition = ReachabilityCondition(host: host)
            addCondition(reachabilityCondition)
        }

        let alertPresenter = BlockObserver { operation, errors in
            if !errors.isEmpty {
                let alert = AlertOperation(presentationContext: presentationContext)

                alert.title = "Anslutning misslyckad"
                alert.message = "Kan inte upprätta en anslutning. Se till att du är ansluten till internet och försök igen."

                alert.addAction("Försök igen") { _ in
                    self.produceOperation(opClosure())
                }

                self.produceOperation(alert)
            } else {
                successCompletionHandler?()
            }
        }

        addObserver(alertPresenter)
    }

}
