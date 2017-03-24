//
//  CloudPlacementAlgorithm.swift
//  Barnplay
//
//  Returns a number of positions for the cloud view
//  Formed as rings , with an amount of "randomness" to it
//
//  Created by John Wikman on 2016-04-24.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import Foundation
import UIKit

class CloudPlacement {

    // Constants
    let tau = 2*M_PI

    func getCloudPositions(amount: Int, minimumDistance: Int) -> [(Int, Int)] {
        let randomDistance = minimumDistance / 10
        return getCloudPositions(amount, minimumDistance: minimumDistance, randomDistance: randomDistance)
    }

    func getCloudPositions(amount: Int, minimumDistance: Int, randomDistance: Int) -> [(Int, Int)] {
        // Constants:
        //let r: Int = (minimumDistance + randomDistance)/2

        // Help constants
        let two_r = minimumDistance + randomDistance
        let halfRand = randomDistance/2

        // List:
        var list = [(0, 0)]

        // Loop variables:
        var shellElements = 0
        var shellNumber = 0
        var allowedAmount = 0
        var incrementAngle = 0.0
        var startAngle = 0.0
        var currentRadius = 0

        var addedElements = 1

        while addedElements < amount {
            // If we need to move on to the next shell
            if shellElements >= allowedAmount {
                shellElements = 0
                shellNumber += 1
                allowedAmount = getAmount(shellNumber)
                let leftToAdd = amount - addedElements
                if leftToAdd < allowedAmount {
                    incrementAngle = tau/Double(leftToAdd)
                } else {
                    incrementAngle = tau/Double(allowedAmount)
                }
                startAngle = tau * Double(arc4random_uniform(100))/100
                currentRadius = shellNumber*two_r
            }

            // Calculate positions for the current shell element
            let xRand = Int(arc4random_uniform(UInt32(randomDistance))) - halfRand
            let yRand = Int(arc4random_uniform(UInt32(randomDistance))) - halfRand
            let xRadius = currentRadius + xRand
            let yRadius = currentRadius + yRand
            let xDist = Double(xRadius)*cos(startAngle + Double(shellElements)*incrementAngle)
            let yDist = Double(yRadius)*sin(startAngle + Double(shellElements)*incrementAngle)
            let coordinates = (Int(xDist), Int(yDist))
            list.append(coordinates)

            // Increment variables
            shellElements += 1
            addedElements += 1
        }

        return list
    }

    func getAmount(shell: Int) -> Int {
        // 10 first values are pre-calculated to speed up process
        let preCalcVals = [0, 6, 12, 18, 25, 31, 37, 43, 50, 56]

        if case 0..<preCalcVals.count = shell {
            return preCalcVals[shell]
        } else {
            let angle = acos(1.0 - 1.0/(2.0*Double(shell)*Double(shell)))
            return Int(floor(tau/angle))
        }
    }
}
