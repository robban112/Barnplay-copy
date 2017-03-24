//
//  UserHistory.swift
//  Barnplay
//
//  Space is limited to 500kb on tvOS unless you work with iCloud
//  This allows an array of the class TitleHistory to be stored into that
//  memory space and unpacked again.
//
//  Holds ~100-140 titles, and we have not tested what happends when it gets full
//
//  Created by Jonas Wedin on 2016-04-05.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation

class TitleHistory: NSObject, NSCoding {
    var id: Int!
    var lastWatched: NSDate!
    var latestEpisode: Int!
    var latestEpisodeDuration: Int!

    convenience required init?(coder decoder: NSCoder) {
        guard let id = decoder.decodeObjectForKey("id") as? Int,
            lastWatched = decoder.decodeObjectForKey("lastWatched") as? NSDate,
            latestEpisode = decoder.decodeObjectForKey("latestEpisode") as? Int,
            latestEpisodeDuration = decoder.decodeObjectForKey("latestEpisodeDuration") as? Int else { return nil }

        self.init(id: id, lastWatched: lastWatched, lastestEpisode: latestEpisode, latestEpisodeDuration: latestEpisodeDuration)
    }

    init(id: Int, lastWatched: NSDate = NSDate(), lastestEpisode: Int, latestEpisodeDuration: Int) {
        super.init()
        self.id = id
        self.lastWatched = lastWatched
        self.latestEpisode = lastestEpisode
        self.latestEpisodeDuration = latestEpisodeDuration
    }

    func encodeWithCoder(coder: NSCoder) {
        if let id = id { coder.encodeObject(id, forKey: "id") }
        if let lastWatched = lastWatched { coder.encodeObject(lastWatched, forKey: "lastWatched") }
        if let latestEpisode = latestEpisode { coder.encodeObject(latestEpisode, forKey: "latestEpisode") }
        if let latestEpisodeDuration = latestEpisodeDuration { coder.encodeObject(latestEpisodeDuration, forKey: "latestEpisodeDuration") }
    }

}


class UserHistory {

    let identifier = "titlesHistoryData"

    //Returns the 16 latest watched titles in order
    func latestWatchedTitles(howMany: Int) -> [Int] {
        let titles = loadData().sort { $0.lastWatched > $1.lastWatched }
        return titles.prefix(howMany).flatMap { $0.id }
    }

    func getTitlesLatestEpisodeId(title: Title) -> Int? {
        return loadData().find { $0.id == title.id }?.latestEpisode
    }

    //Updates a title and sets the latest episode watched and what duration
    func updateTitle(titleId: Int, episodeId: Int, episodeDuration: Int) {
        var titles = self.loadData()
        let updatedTitle = TitleHistory(id: titleId, lastestEpisode: episodeId, latestEpisodeDuration: episodeDuration)

        if let index = titles.indexOf({ $0.id == titleId }) {
            titles[index] = updatedTitle
        } else {
            titles.append(updatedTitle)
        }

        // Save the new list
        saveData(titles)
    }

    //same as above but accepts title and episode objects
    func updateTitle(title: Title, episode: Episode, episodeDuration: Int) {
        self.updateTitle(title.id, episodeId: episode.id, episodeDuration: episodeDuration)
    }

    //Returns how long the user has viewed in the episode, if it is
    //not saved it returns 0
    func getEpisodeDuration(titleId: Int, episodeId: Int) -> Int {
        return loadData().find { $0.id == titleId && $0.latestEpisode == episodeId }?.latestEpisodeDuration ?? 0
    }

    //GO POLYMORPH!! 🐙🦀🦂
    func getEpisodeDuration(title: Title, episode: Episode) -> Int {
        return getEpisodeDuration(title.id, episodeId: episode.id)
    }

    //Helper function to load user data
    private func loadData() -> [TitleHistory] {
        guard let loadedData = NSUserDefaults().dataForKey(self.identifier) else { return [] }

        guard let loadedTitles = NSKeyedUnarchiver.unarchiveObjectWithData(loadedData) as? [TitleHistory] else {
            fatalError("Could not load local user data")
        }

        return loadedTitles
    }

    //Helper function to save user data
    private func saveData(titles: [TitleHistory]) {
        let s = NSUserDefaults.standardUserDefaults()
        let titlesData = NSKeyedArchiver.archivedDataWithRootObject(titles)
        s.setObject(titlesData, forKey: self.identifier)
    }


    func debugPrint() {
        let titles = self.latestWatchedTitles(16)
        print("Latest 16 watched titles:")
        for title in titles {
            print("    \(title)")
        }
        print("Done debug from user history")
        print("All information in userHistory:")
        let titlesUnsorted = self.loadData()
        for title in titlesUnsorted {
            print("    \(title.id) - \(title.latestEpisodeDuration)")
        }
        print("Done")
    }

}
