//
//  TitleLoadOperation.swift
//  Barnplay
//
//  Created by John Wikman on 2016-04-07.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PSOperations

/**
 *  ~∞%#%∞~ MUTUALLY EXCLUSIVE ~∞%#%∞~
 *
 *  Loads titles into a TitleHandler.
 */
class LoadTitlesOperation: NetworkDependentOperation {

    let handler = TitleHandler.shared
    let jsonAddress = "http://www.svt.se/barnkanalen/barnplay"

    init(presentationContext: UIViewController? = nil, successCompletionHandler: (Void -> Void)? = nil) {

        super.init(hosts: [jsonAddress], presentationContext: presentationContext, successCompletionHandler: successCompletionHandler, opClosure: {
            LoadTitlesOperation(presentationContext: presentationContext, successCompletionHandler: successCompletionHandler)
        })

        self.addCondition(MutuallyExclusive<LoadTitlesOperation>())
    }

    /**
     *  If the handler has titles then it immediately finishes.
     *  Else it loads a JSON and imports all the titles.
     */
    override func execute() {
        guard handler.titles.isEmpty else {
            finish()
            return
        }

        // Load JSON
        let json: JSON

        do {
            json = try getJSON()
        } catch let error as NSError {
            finishWithError(error)
            return
        }

        // Import titles from JSON
        handler.titles = json["titlePages"].arrayValue.flatMap { Title(json: $0) }

        // Construct titlemap
        for title in handler.titles {
            handler.titleMap[title.id] = title
        }

        // Add categories
        let categories = json["categories"].arrayValue

        for category in knownCategories {
            guard let catJson = categories.find({ $0["name"].stringValue == category }),
                      cat = Category(json: catJson, titleMap: handler.titleMap) else { continue }
            handler.categories.append(cat)
        }

        // This operation must finish without any errors
        finish()
    }


    /*
     *  Loads the JSON that contains information about titles and categories.
     */
    private func getJSON() throws -> JSON {
        // Creates a dispatch group to wait for Alamofire.
        let loadingGroup = dispatch_group_create()
        dispatch_group_enter(loadingGroup)
        var error: NSError?
        var json: JSON?
        Alamofire.request(.GET, jsonAddress).responseString { response in
            switch response.result {
                case .Success(let html):
                    let range = html.rangeOfString("(?<=bpGridJson = )\\{.*\\}", options: .RegularExpressionSearch)!
                    let jsonString = html.substringWithRange(range)
                    guard let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else { return }
                    json = JSON(data: dataFromString)
                case .Failure(let jsonError): error = jsonError
            }
            dispatch_group_leave(loadingGroup)
        }
        // Wait for Alamofire before returning.
        dispatch_group_wait(loadingGroup, DISPATCH_TIME_FOREVER)
        if let error = error {
            throw error
        }
        return json!
    }

}

// Operators to use in the switch statement.
private func ~= (lhs: (String, Int, String?), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1 ~= rhs.1 && lhs.2 == rhs.2
}

private func ~= (lhs: (String, OperationErrorCode, String), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1.rawValue ~= rhs.1 && lhs.2 == rhs.2
}
