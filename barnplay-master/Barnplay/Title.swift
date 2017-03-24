//
//  Title.swift
//  Barnplay
//
//  This struct represents a title that we can
//  fetch from SVT:s api.
//
//  Created by Jonas Wedin on 2016-03-05.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import SwiftyJSON

class Title {
    // Not optionals
    let id: Int
    let slug: String
    let onlySweden: Bool
    // Optionals
    let title: String?
    let description: String?
    let thumbnail: String?
    let characterImage: String?
    let relatedTitles: [Int]?
    let languages: [Language]?
    let series: Bool?
    let latestEpisodePublicationDate: String?
    // These will not be set right away
    // as they require an extra http request
    // to be set
    var episodes: [Episode]?
    var episodeMap: [Int:Episode]?
    var schedules: [Schedule]?

    init?(json: JSON) {
        guard let id = json["id"].int,
            slug = json["slug"].string else { return nil }
        self.id = id
        self.slug = slug
        title = json["title"].string
        description = json["description"].string
        onlySweden = json["onlySweden"].boolValue
        series = json["series"].boolValue
        thumbnail = json["thumbnail"].string
        characterImage = json["characterImage"].string
        relatedTitles = json["relatedTitles"].arrayValue.flatMap { $0.int }
        languages = json["languages"].arrayValue.map { knownLangs[$0.stringValue] ?? .Other }
        latestEpisodePublicationDate = json["latestEpisodePublicationDate"].string
    }
}
