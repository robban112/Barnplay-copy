//
//  CategoryCollectionCell.swift
//  Barnplay
//
//  Created by Oskar Ek on 2016-03-25.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit

class CategoryCollectionCell: UICollectionViewContainerCell, UICollectionViewDataSource {

    // MARK: Properties

    static let reuseIdentifier = "CategoryCollectionCell"

    // MARK: Model

    var category: Category? {
        didSet {
            categoryHeader.text = category?.name

            collectionView.performBatchUpdates({
                self.collectionView.reloadSections(NSIndexSet(index: 0))
                }, completion: { _ in self.collectionView.setNeedsFocusUpdate() })
        }
    }

    // MARK: Outlets

    @IBOutlet var headerStackView: UIStackView!
    @IBOutlet var categoryHeader: UILabel!
    @IBOutlet var categoryIcon: UIImageView!

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryTitleCell.reuseIdentifier, forIndexPath: indexPath) as? CategoryTitleCell else {
            fatalError("Failed to dequeue a CategoryTitleCell")
        }
        let title = category?.titles[indexPath.item]
        cell.title = title

        if let urlString = title?.thumbnail, thumbnailURL = NSURL(string: urlString) {
            cell.thumbnailImageView.kf_showIndicatorWhenLoading = true
            cell.thumbnailImageView.kf_indicator?.activityIndicatorViewStyle = .WhiteLarge
            cell.thumbnailImageView.kf_setImageWithURL(thumbnailURL)
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category?.titles.count ?? 0
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? CategoryTitleCell else { return }
        cell.thumbnailImageView.kf_cancelDownloadTask()
    }

    // MARK: Lifecycle methods

    override func awakeFromNib() {
        categoryHeader?.text = nil
    }

    override func prepareForReuse() {
        category = nil
        categoryHeader?.text = nil
    }

}
