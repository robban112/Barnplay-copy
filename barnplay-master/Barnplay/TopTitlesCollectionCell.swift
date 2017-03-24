//
//  TopTitlesCollectionCell.swift
//  Barnplay
//
//  Created by Oskar Ek on 2016-03-26.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit

class TopTitlesCollectionCell: UICollectionViewContainerCell, UICollectionViewDataSource {

    // MARK: Properties

    static let reuseIdentifier = "TopTitlesCollectionCell"

    // MARK: Model

    var titles: [Title]? {
        didSet {
            collectionView.performBatchUpdates({
                self.collectionView.reloadSections(NSIndexSet(index: 0))
                }, completion: { _ in self.setNeedsFocusUpdate() })
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TopTitleCell.reuseIdentifier, forIndexPath: indexPath) as? TopTitleCell else {
            fatalError("Failed to dequeue a TopTitleCell")
        }
        let title = titles?[indexPath.item]
        cell.titleLabel.text = title?.title
        cell.title = title

        if let urlString = title?.characterImage, characterURL = NSURL(string: urlString) {
            cell.characterImageView.kf_showIndicatorWhenLoading = true
            cell.characterImageView.kf_indicator?.activityIndicatorViewStyle = .WhiteLarge
            cell.characterImageView.kf_setImageWithURL(characterURL)
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles?.count ?? 0
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // Kommer ändras till 2 sen
        return 1
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? TopTitleCell else { return }
        cell.characterImageView.kf_cancelDownloadTask()
    }

    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let nextIndexPath = context.nextFocusedIndexPath else { return }

        // horizontally center the currently focused cell
        coordinator.addCoordinatedAnimations({
            collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .CenteredHorizontally, animated: false)
            }, completion: nil)
    }

    // MARK: Lifecycle methods

    override func awakeFromNib() {
        // Needed to make centering of focused cell work as expected
        collectionView.scrollEnabled = false
    }

    override func prepareForReuse() {
        titles = nil
    }

}
