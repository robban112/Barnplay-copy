//
//  HomeViewController.swift
//  Barnplay
//
//  Created by Jonas Wedin on 2016-03-04.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit
import PSOperations

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SegueHandlerType, UICollectionViewContainerCellSegueHandler {

    // MARK: Model

    let titleHandler = TitleHandler.shared

    let operationQueue = OperationQueue()

    var firstLoad = true

    // NARK: Initialization

    override func viewDidLoad() {
        super.viewDidLoad()
        //Prints debug information about the user history
        //let test = UserHistory()
        //test.debugPrint()
    }

    override func viewDidAppear(animated: Bool) {
        let reloadLatestWatchedOperation = CreateLastViewCategoryOperation { [unowned self] opType in
            dispatch_async(GlobalMainQueue) {
                switch opType {
                case .creation: if !self.firstLoad { self.collectionView!.reloadData() }
                case .update: self.collectionView?.reloadSections(NSIndexSet(index: 1)) // only update the LastView category section
                }
            }
        }

        if firstLoad {
            firstLoad = false
            let loadTitles = LoadTitlesOperation(presentationContext: self)
            reloadLatestWatchedOperation.addDependency(loadTitles)
            let reloadCategories = BlockOperation {
                dispatch_async(GlobalMainQueue) {
                    self.collectionView!.reloadData()
                }
            }
            reloadCategories.addDependency(reloadLatestWatchedOperation)
            operationQueue.addOperation(loadTitles)
            operationQueue.addOperation(reloadCategories)
        }

        operationQueue.addOperation(reloadLatestWatchedOperation)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TopTitlesCollectionCell.reuseIdentifier, forIndexPath: indexPath) as? TopTitlesCollectionCell else {
                fatalError("Failed to dequeue a TopTitlesCollectionCell")
            }
            cell.titles = titleHandler.titles
            cell.segueHandler = self
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CategoryCollectionCell.reuseIdentifier, forIndexPath: indexPath) as? CategoryCollectionCell else {
                fatalError("Failed to dequeue a CategorCollectionCell")
            }
            let category = titleHandler.categories[indexPath.section-1]
            cell.category = category
            if let urlString = category.icon, iconURL = NSURL(string: urlString) {
                cell.categoryIcon.kf_setImageWithURL(iconURL, placeholderImage: UIImage(named: "popular"))
            }
            cell.segueHandler = self
            return cell
        }
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let numberOfCategories = titleHandler.categories.count
        if numberOfCategories == 0 {
            return 0
        }
        // all the categories plus the top titles
        return 1 + numberOfCategories
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        switch section {
        case 0: return UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
        default: return UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
        case 0: return CGSize(width: 1920, height: 610)
        default: return CGSize(width: 1920, height: 280)
        }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Only the subcollectionViews' cells should be focusable
        return false
    }

    // MARK: Segue

    enum SegueIdentifier: String {
        case ShowEpisodeViewController = "Show Episode View Controller"
        case ShowCloudViewController = "Show Cloud View Controller"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowEpisodeViewController:
            guard let epContr = segue.destinationViewController as? EpisodeViewController,
                titleCell = sender as? TitleCell,
                title = titleCell.title else { return }
            epContr.titleObj = title
        case .ShowCloudViewController:
            print("-- segue to cloud")
            return
        }

    }

    // MARK: UICollectionViewContainerCellSegueHandler

    func didSelectCell(cell: UICollectionViewCell) {
        performSegueWithIdentifier(.ShowEpisodeViewController, sender: cell)
    }

    @IBAction func goToCloudViewButton(sender: UIButton) {
        performSegueWithIdentifier(.ShowCloudViewController, sender: sender)
    }
}
