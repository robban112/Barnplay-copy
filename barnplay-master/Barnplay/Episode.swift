//
//  Episode.swift
//  Barnplay
//
//  This struct represents an episode that we can fetch
//  from SVT:s api
//
//  Created by Jonas Wedin on 2016-03-05.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import SwiftyJSON

class Episode {

    // Enum for thumbnail sizes
    enum ThumbnailSize {
        case Small, Medium, Large, XL
    }

    // Not optionals
    let id: Int
    let programVersionId: String    // Required for fetching video
    let titleSlug: String           // Was used to get here so it should be here
    // Optionals
    let title: String?
    let seasonNumber: Int?
    let episodeNumber: Int?
    let description: String?
    let language: Language?
    let length: Int?
    let thumbnails: [ThumbnailSize: String]
    // These will not be set right away
    // as they require an extra http request
    // to be set
    var videoFeed: String?

    init?(json: JSON) {
        //Let the init fail if required values are nil
        guard let id = json["id"].int,
            programVersionId = json["programVersionId"].string,
            titleSlug = json["titleSlug"].string else { return nil }
        self.id = id
        self.programVersionId = programVersionId
        self.titleSlug = titleSlug
        // Optionals
        title = json["title"].string
        seasonNumber = json["seasonNumber"].int
        episodeNumber = json["episodeNumber"].int
        description = json["description"].string
        language = knownLangs[json["language"].stringValue] ?? .Other
        length = json["materialLength"].int
        var thumbs = [ThumbnailSize: String]()
        thumbs[.Small] = json["thumbnailSmall"].string
        thumbs[.Medium] = json["thumbnailMedium"].string
        thumbs[.Large] = json["thumbnailLarge"].string
        thumbs[.XL] = json["thumbnailXL"].string
        self.thumbnails = thumbs
    }
}
