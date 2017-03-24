//
//  LoadEpisodeURLOperation.swift
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
 *  Loads the streaming URL into an episode.
 */
class LoadStreamingURLOperation: NetworkDependentOperation {

    var episode: Episode
    let url: String

    init(episode: Episode, presentationContext: UIViewController? = nil, successCompletionHandler: (Void -> Void)? = nil) {
        self.episode = episode
        self.url = "http://www.svt.se/videoplayer-api/video/" + episode.programVersionId

        super.init(hosts: [url], presentationContext: presentationContext, successCompletionHandler: successCompletionHandler, opClosure: {
            LoadStreamingURLOperation(episode: episode, presentationContext: presentationContext, successCompletionHandler: successCompletionHandler)
        })
    }

    /**
     *  If the episode already has the URL it immediately finishes.
     *  Else it loads the URL from the JSON.
     */
    override func execute() {
        guard episode.videoFeed == nil else {
            finish()
            return
        }

        // Load JSON
        var json: JSON? = nil
        do {
            json = try getJSON()
        } catch let error as NSError {
            finishWithError(error)
            return
        }

        // Extract the HLS streaming URL from the JSON
        if let hlsJSON = json?["videoReferences"].array?.find({ $0["format"].string == "hls" }),
           let url = hlsJSON["url"].string {
            episode.videoFeed = url
        }

        finish()
    }


    private func getJSON() throws -> JSON {
        // Creates a dispatch group to wait for Alamofire.
        let loadingGroup = dispatch_group_create()
        dispatch_group_enter(loadingGroup)
        var json: JSON?
        var error: NSError?
        Alamofire.request(.GET, url).validate().responseJSON { response in
            switch response.result {
            case .Success(let html):
                json = JSON(html)
                dispatch_group_leave(loadingGroup)
            case .Failure(let jsonError): error = jsonError
            }
        }
        // Wait for Alamofire before returning.
        dispatch_group_wait(loadingGroup, DISPATCH_TIME_FOREVER)
        if let error = error {
            throw error
        }
        return json!
    }
}
