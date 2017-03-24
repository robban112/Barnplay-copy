//
//  VideoPlayer.swift
//  Barnplay
//
//  Created by Jonas Wedin on 2016-03-13.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import AVKit
import UIKit

class VideoPlayerHelper {

    func playVideo(title: Title, episode: Episode) -> AVPlayerViewController {
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
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }
}
