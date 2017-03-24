//
//  CreateLastViewCategoryOperation.swift
//  Barnplay
//
//  Created by Jonas Wedin on 2016-04-07.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import PSOperations

class CreateLastViewCategoryOperation: Operation {
    /// The type of operation that was performed.
    enum OperationType {
        /// The LastView category was updated.
        case update
        /// The LastView category was created for the first time.
        case creation
    }

    let handler = TitleHandler.shared
    let slug = "latestWatched"

    let completionHandler: ((OperationType) -> ())?

    init(completionHandler: ((OperationType) -> ())? = nil) {
        self.completionHandler = completionHandler
    }

    override func execute() {
        defer { finish() }

        let userHistory = UserHistory()
        let sortedTitles = userHistory.latestWatchedTitles(16)

        guard !sortedTitles.isEmpty else { return }

        let titleObjects = sortedTitles.flatMap { handler.titleMap[$0] }
        let category = Category(name: "Senast sedda", slug: self.slug, icon: "latestWatched", titles: titleObjects)

        //We may need to update this while running
        if handler.categories.first?.slug == self.slug {
            handler.categories[0] = category
            completionHandler?(.update)
        } else {
            handler.categories.insert(category, atIndex: 0)
            completionHandler?(.creation)
        }
    }
}
