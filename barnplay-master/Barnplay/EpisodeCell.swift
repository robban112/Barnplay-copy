//
//  EpisodeCell.swift
//  Barnplay
//
//  Created by Fredrik Gisslén on 2016-03-15.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit

class EpisodeCell: UICollectionViewCell {

    static let reuseIdentifier = "EpisodeCell"

    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var episodeLabel: UILabel!


    var episode: Episode? {
        didSet {

            episodeLabel.text = episode?.title
            fetchImage()
            episodeLabel.alpha = 0
        }
    }

    private func fetchImage() {
        guard let urlStr = episode?.thumbnails[.Medium], url = NSURL(string: urlStr) else { return }
        //activityIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            guard let imageData = NSData(contentsOfURL: url) else { return }
            dispatch_async(dispatch_get_main_queue()) {
                if let image = UIImage(data: imageData) where url.absoluteString == self.episode?.thumbnails[.Medium] {
                    self.episodeImageView.image = image
                    //self.activityIndicator.stopAnimating()
                }
            }
        }
    }

    // Only the focused cell has a visible title label
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [unowned self] in
            if self.focused {
                self.episodeLabel.alpha = 1
            } else {
                self.episodeLabel.alpha = 0
            }
            }, completion: nil)
    }





}
