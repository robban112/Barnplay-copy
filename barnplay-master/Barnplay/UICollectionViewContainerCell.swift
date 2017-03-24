//
//  UICollectionViewContainerCell.swift
//  Barnplay
//
//  Created by Oskar Ek on 2016-03-28.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit

/// A UICollectionViewCell that itself contains a UICollectionView.
class UICollectionViewContainerCell: UICollectionViewCell, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var segueHandler: UICollectionViewContainerCellSegueHandler?

    override var preferredFocusedView: UIView? {
        // Delegate the managing of focus to the containing UICollectionView
        return collectionView
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        segueHandler?.didSelectCell(cell)
    }
}

/**
 Protocol that should be implemented by a view controller with the following properties:

 - Displays a UICollectionView
 - That UICollectionView displays cells of type UICollectionViewContainerCell
 - Wants to perform a segue in response to those cells being selected
 */
protocol UICollectionViewContainerCellSegueHandler {
    /**
     Tells the segueHandler that a cell was selected.

     - parameter cell: The cell that was selected.
    */
    func didSelectCell(cell: UICollectionViewCell)
}
