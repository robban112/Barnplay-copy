//
//  TitleHandler.swift
//  Barnplay
//
//  Created by John Wikman on 2016-03-10.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TitleHandler {

    static let shared = TitleHandler()

    var titles = [Title]() //sorted
    var titleMap = [Int:Title]()
    var categories = [Category]() //sorted

    private init() {
        // Empty
    }

    func getEpisodes(title: Title) -> [Episode]? {
        return nil
    }

    func getStreamURL(episode: Episode) -> String? {
        return nil
    }
}
