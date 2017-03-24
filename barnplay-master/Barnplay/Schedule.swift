//
//  Schedule.swift
//  Barnplay
//
//  Created by Oskar Ek on 2016-04-04.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import SwiftyJSON

class Schedule {

    /// A date-string, sush as "onsdag 6 apr"
    let date: String
    /// A time-string, sush as "10:25"
    let time: String

    init?(json: JSON) {
        guard let date = json["dateStr"].string,
            time = json["timeStr"].string else { return nil }
        self.date = date
        self.time = time
    }

}
