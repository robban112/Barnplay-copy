//
//  Category.swift
//  Barnplay
//
//  Created by John Wikman on 2016-03-17.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import SwiftyJSON

var knownCategories: [String] {
    return ["Populärt", "För de yngsta", "För de äldsta", "Andra språk"]
}

class Category {
    let name: String
    let slug: String
    let icon: String?
    let titles: [Title]

    init?(json: JSON, titleMap: [Int:Title]) {
        guard let slug = json["slug"].string,
                  name = json["name"].string else { return nil }
        self.slug = slug
        self.name = name
        self.icon = json["icon"].string
        self.titles = json["titles"].arrayValue.map { titleMap[$0.intValue]! }
    }

    init(name: String, slug: String, icon: String, titles: [Title]) {
        self.name = name
        self.slug = slug
        self.icon = icon
        self.titles = titles
    }
}
