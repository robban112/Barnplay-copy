//
//  VideoPlayerOperation.swift
//  Barnplay
//
//  Created by John Wikman on 2016-04-07.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import AVKit
import UIKit
import Foundation
import PSOperations

/**
 *  ~∞%#%∞~ MUTUALLY EXCLUSIVE ~∞%#%∞~
 *
 *  Loads titles into a TitleHandler.
 *
 *  Depends on:
 *  - LoadStreamingURLOperation
 */
class VideoPlayerOperation: Operation {

    var title: Title
    var episode: Episode
    var view: EpisodeViewController
    var startPlayingFrom: Int

    init(title: Title, episode: Episode, view: EpisodeViewController, startPlayingFrom: Int) {
        self.title = title
        self.episode = episode
        self.view = view
        self.startPlayingFrom = startPlayingFrom

        super.init()

        self.addCondition(MutuallyExclusive<VideoPlayerOperation>())
    }

    /**
     *  Plays the selected episode.
     */
    override func execute() {
        // Initiates the player
        let playerViewController = playVideo()
        //let time = CMTimeMakeWithSeconds(Float64(self.startPlayingFrom), 1)

        // Presents the player to the episode view
        /*view.presentViewController(playerViewController, animated: true, completion: {
            if self.startPlayingFrom != 0 {
                playerViewController.player!.seekToTime(time)
            }
            playerViewController.player!.play()
        })*/
        view.player = playerViewController.player!
        view.playerView = playerViewController
        finish()
    }

    private func playVideo() -> AVPlayerViewController {
        //Create asset
        let mediaURL = NSURL(string: episode.videoFeed!)
        let playerItem = AVPlayerItem(asset: AVURLAsset(URL: mediaURL!))
        //Avoid duplication
        let loc = NSLocale.currentLocale()
        let keySpace = AVMetadataKeySpaceCommon
        // Title
        let titleMetadata = AVMutableMetadataItem()
        titleMetadata.locale = loc
        titleMetadata.keySpace = keySpace
        titleMetadata.key = AVMetadataCommonKeyTitle
        titleMetadata.value = title.title! + " " + episode.title!
        // Description
        let descMetadata = AVMutableMetadataItem()
        descMetadata.locale = loc
        descMetadata.keySpace = keySpace
        descMetadata.key = AVMetadataCommonKeyDescription
        descMetadata.value = episode.description ?? title.description ?? ""

        playerItem.externalMetadata.append(titleMetadata)
        playerItem.externalMetadata.append(descMetadata)

        // Create player
        let player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .Pause
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }
}
