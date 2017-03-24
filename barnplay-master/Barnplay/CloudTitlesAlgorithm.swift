//
//  CloudRelatedTitlesAlgorithm.swift
//  Barnplay
//
//  Returns a list of all titles based on what you have
//  already watched
//
//  Created by John Wikman on 2016-04-26.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation

class CloudTitles {
    let titleHandler = TitleHandler.shared

    func getOrderedTitles() -> [Title] {
        let relevantTitles = getRelevantTitles()

        // Get all IDs for each titles
        let allTitles: [Int] = titleHandler.titles.map { return $0.id }

        // Remove those titles that are located in relevant titles
        var titleSet = Set(allTitles)
        titleSet = titleSet.subtract(relevantTitles)

        // Now unite them again so that the relevant titles are located first in the list
        let unitedTitles = relevantTitles + titleSet
        let returnTitles = unitedTitles.flatMap { return titleHandler.titleMap[$0] }

        return returnTitles
    }

    func getRelevantTitles() -> [Int] {
        return getRelevantTitles(5)
    }

    // Based on the latest watched titles
    func getRelevantTitles(amount: Int) -> [Int] {
        let userHistory = UserHistory()
        let titles = userHistory.latestWatchedTitles(amount)
        var scoreTitles = [(Int, Int)]() // [(Score, titleID)]
        for i in 0..<titles.count {
            let titleScore = titles.count - i
            guard let title = titleHandler.titleMap[titles[i]],
                relatedTitles = title.relatedTitles else { continue }

            for j in 0..<relatedTitles.count {
                let score = titles.count - j + titleScore
                let relatedTitle = relatedTitles[j]
                scoreTitles.append((score, relatedTitle))
            }
        }
        // Now sort and remove duplicates
        scoreTitles.sortInPlace {$0.0 > $1.0}
        var returnTitles = [Int]()
        for (_, id) in scoreTitles {
            if !returnTitles.contains(id) {
                returnTitles.append(id)
            }
        }

        return returnTitles
    }
}
