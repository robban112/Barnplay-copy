//
//  EpisodeViewController.swift
//  Barnplay
//
//  Created by Fredrik Gisslén on 2016-03-15.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit
import PSOperations
import AVKit

class EpisodeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var charImage: UIImageView!
    @IBOutlet weak var informationLabel: UILabel!

    var firstLaunch = true

    var titleObj: Title!
    var epObj: Episode?
    let operationQueue = OperationQueue()
    var player: AVPlayer?
    var playerView: AVPlayerViewController?

    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.remembersLastFocusedIndexPath = true
        informationLabel.sizeToFit()
        informationLabel.numberOfLines = 0
    }

    override func viewDidAppear(animated: Bool) {
        guard firstLaunch else { return }

        let loadOperation = LoadEpisodesOperation(title: titleObj, presentationContext: self) {
            self.initialize()
        }
        operationQueue.addOperation(loadOperation)
        firstLaunch = false
    }

    //Saves the latest episode current time
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard let duration = player?.currentItem?.currentTime().seconds, epObj = self.epObj else { return }

        let durseconds = Int(duration)
        let userHistory = UserHistory()
        let endLength = epObj.length! - (epObj.length! / 10)
        if durseconds >= endLength || durseconds == 0 {
            //we finished watching the episode and need to select the next one
            let lastEpisodeIndex = self.titleObj.episodes!.indexOf { $0.id == epObj.id }
            if lastEpisodeIndex >= self.titleObj.episodes!.count - 1 {
                userHistory.updateTitle(self.titleObj.id, episodeId: self.titleObj.episodes![0].id, episodeDuration: 0)
            } else {
                userHistory.updateTitle(self.titleObj.id, episodeId: self.titleObj.episodes![lastEpisodeIndex!+1].id, episodeDuration: 0)
            }
        } else {
            userHistory.updateTitle(self.titleObj, episode: epObj, episodeDuration: durseconds)
        }
        self.epObj = nil
        self.player = nil
        self.playerView = nil
        self.isPlaying = false
    }

    private func initialize() {
        let displayOperation = BlockOperation {
            self.collectionView.reloadData()
        }
        operationQueue.addOperation(displayOperation)
        if let titleText = titleObj?.title?.uppercaseString {
            titleLabel.text = titleText
        }
        informationLabel.sizeToFit()
        if let informationText = titleObj?.description {
            informationLabel.text = informationText
        }
        fetchImage()
    }

    //Overrides the initial focus position to the last viewed episode if there is one,
    //otherwise it leaves focus at the first item
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {

        let userHistory = UserHistory()

        guard let latestEpisodeId = userHistory.getTitlesLatestEpisodeId(self.titleObj) else {
            return NSIndexPath(forRow: 0, inSection: 0)
        }

        guard let episodeIndex = self.titleObj.episodes?.indexOf({ $0.id == latestEpisodeId }) else {
            print("Minor error: There was a last episode id in history but it was not available in the title object")
            return NSIndexPath(forRow: 0, inSection: 0)
        }

        let episodePath = NSIndexPath(forRow: episodeIndex, inSection: 0)
        self.collectionView.selectItemAtIndexPath(episodePath, animated: false, scrollPosition: .Left)
        return episodePath
    }

    private func fetchImage() {
        guard let urlStr = titleObj.characterImage, url = NSURL(string: urlStr) else { return }
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            guard let imageData = NSData(contentsOfURL: url) else { return }
            dispatch_async(dispatch_get_main_queue()) {
                if let image = UIImage(data: imageData) where url.absoluteString == self.titleObj?.characterImage {
                    self.charImage.image = image
                    self.charImage.layer.cornerRadius = self.charImage.frame.size.width/2
                    self.charImage.clipsToBounds = true
                    self.charImage.layer.masksToBounds = true
                    self.charImage.layer.borderWidth = 10
                    self.charImage.layer.borderColor = UIColor(red:45/255.0, green:147/255.0, blue:250/255.0, alpha: 1.0).CGColor
                }
            }
        }
    }


    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EpisodeCell.reuseIdentifier, forIndexPath: indexPath) as? EpisodeCell else {
            fatalError("Expected to deque an EpisodeCell but found another cell.")
        }

        cell.episode = titleObj?.episodes![indexPath.row]

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? EpisodeCell else { return }

        guard !isPlaying else { return }
        isPlaying = true

        //Load the next view
        let episode = cell.episode!
        self.epObj = episode
        let userHistory = UserHistory()
        let time = userHistory.getEpisodeDuration(self.titleObj, episode: self.epObj!)
        if time == 0 {
            userHistory.updateTitle(self.titleObj!, episode: self.epObj!, episodeDuration: 0)
        }

        let loadOperation = LoadStreamingURLOperation(episode: self.epObj!, presentationContext: self) {
            if self.epObj?.videoFeed != nil {
                self.playEpisodeFromTime(episode, time: time)
            } else {
                self.isPlaying = false
                let noVideofeedAlertOperation = AlertOperation(presentationContext: self)
                noVideofeedAlertOperation.title = "Denna episod verkar inte ha någon video-feed att spela upp"
                self.operationQueue.addOperation(noVideofeedAlertOperation)
            }
        }
        operationQueue.addOperation(loadOperation)
    }

    private func playEpisodeFromTime(episode: Episode, time: Int) {
        let displayOperation = VideoPlayerOperation(title: self.titleObj, episode: self.epObj!, view: self, startPlayingFrom: time)
        let playOperation = BlockOperation {
            self.playVideo(time)
        }
        let notificationOperation = BlockOperation {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player!.currentItem!)
        }

        playOperation.addDependency(displayOperation)
        notificationOperation.addDependency(playOperation)
        operationQueue.addOperation(displayOperation)
        operationQueue.addOperation(playOperation)
        operationQueue.addOperation(notificationOperation)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleObj?.episodes?.count ?? 0
    }

    //we recive a notification that the player is finished
    func playerDidFinishPlaying(note: NSNotification) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //play the video stored in variable 'player'
    func playVideo(startPlayingFrom: Int) {
        let time = CMTimeMakeWithSeconds(Float64(startPlayingFrom), 1)
        self.presentViewController(playerView!, animated: true, completion: {
            if startPlayingFrom != 0 {
                self.player!.seekToTime(time)
            }
            self.player!.play()
        })
    }
}
