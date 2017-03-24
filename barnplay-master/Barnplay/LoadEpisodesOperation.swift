//
//  LoadEpisodesOperation.swift
//  Barnplay
//
//  Created by John Wikman on 2016-04-07.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PSOperations

/**
 *  Load episodes and schedule into a title.
 */
class LoadEpisodesOperation: NetworkDependentOperation {

    let title: Title
    let episodesURL: String
    let schedulesURL: String

    init(title: Title, presentationContext: UIViewController, successCompletionHandler: (Void -> Void)? = nil) {
        self.title = title
        self.episodesURL = "http://www.svt.se/barnkanalen/barnplay/episodes/" + title.slug
        self.schedulesURL = "http://www.svt.se/barnkanalen/barnplay/title_schedule/" + title.slug

        super.init(hosts: [episodesURL, schedulesURL], presentationContext: presentationContext, successCompletionHandler: successCompletionHandler, opClosure: {
            LoadEpisodesOperation(title: title, presentationContext: presentationContext, successCompletionHandler: successCompletionHandler)
        })
    }

    /**
     *  If the title has episodes it immediately finishes.
     *  Else it loads episodes from the JSON into the title.
     */
    override func execute() {
        guard title.episodes == nil else {
            finish()
            return
        }

        let loadingGroup = dispatch_group_create()
        do {
            try loadEpisodes(loadingGroup)
            try loadSchedule(loadingGroup)
        } catch let error as NSError {
            finishWithError(error)
            return
        }
        dispatch_group_wait(loadingGroup, DISPATCH_TIME_FOREVER)

        finish()
    }


    /*
     *  Loads JSON and imports episodes into the title.
     */
    private func loadEpisodes(loadingGroup: dispatch_group_t) throws {
        dispatch_group_enter(loadingGroup)
        var error: NSError?
        Alamofire.request(.GET, episodesURL).validate().responseJSON { response in
            switch response.result {
            case .Success(let html):
                let json = JSON(html)
                let episodes = json["episodes"].arrayValue.flatMap { Episode(json: $0) }
                let sortedEpisodes = episodes.sort { $0.episodeNumber < $1.episodeNumber}
                self.title.episodes = sortedEpisodes
            case .Failure(let jsonError): error = jsonError
            }
            dispatch_group_leave(loadingGroup)
        }
        if let error = error {
            throw error
        }
    }

    /*
     *  Loads JSON and imports schedule into the title.
     *
     *  (Fråga: Är det värkligen helt nödvändigt att ha fatal error här?)
     */
    private func loadSchedule(loadingGroup: dispatch_group_t) throws {
        dispatch_group_enter(loadingGroup)
        var error: NSError?
        Alamofire.request(.GET, schedulesURL).validate().responseJSON { response in
            switch response.result {
            case .Success(let html):
                let json = JSON(html)
                let schedules = json["schedules"].arrayValue.flatMap { Schedule(json: $0) }
                self.title.schedules = schedules
                dispatch_group_leave(loadingGroup)
            case .Failure(let jsonError): error = jsonError
            }
        }
        if let error = error {
            throw error
        }
    }
}
