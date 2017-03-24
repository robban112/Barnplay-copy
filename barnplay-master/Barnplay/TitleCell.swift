//
//  TitleCell.swift
//  Barnplay
//
//  Created by Oskar Ek on 2016-03-28.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit

class TitleCell: UICollectionViewCell {
    var title: Title?
}

class TopTitleCell: TitleCell {

    // MARK: Reuse Identifier

    static let reuseIdentifier = "TopTitleCell"

    // MARK: Outlets

    @IBOutlet var characterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    // MARK: Initialization

    override func awakeFromNib() {
        super.awakeFromNib()

        // Make titles initially hidden
        titleLabel.alpha = 0.0

        // Position title label just under the image view when focused
        titleLabel.centerXAnchor.constraintEqualToAnchor(characterImageView.centerXAnchor).active = true
        titleLabel.widthAnchor.constraintEqualToAnchor(characterImageView.focusedFrameGuide.widthAnchor).active = true
        titleLabel.topAnchor.constraintEqualToAnchor(characterImageView.focusedFrameGuide.bottomAnchor, constant: 10).active = true
    }

    // MARK: UICollectionReusableView

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset the label's alpha value so it's initially hidden.
        titleLabel.alpha = 0.0
    }

    // MARK: UIFocusEnvironment

    // Only the focused cell has a visible title label
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [unowned self] in
            if self.focused {
                self.titleLabel.alpha = 1
            } else {
                self.titleLabel.alpha = 0
            }
            }, completion: nil)
    }

}

class CategoryTitleCell: TitleCell {

    // MARK: Reuse Identifier

    static let reuseIdentifier = "CategoryTitleCell"

    // MARK: Outlets

    @IBOutlet var thumbnailImageView: UIImageView!
}
