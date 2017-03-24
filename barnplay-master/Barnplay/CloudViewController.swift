//
//  CloudViewController.swift
//  Barnplay
//
//  Created by Jonas Wedin on 2016-04-22.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Kingfisher
import Foundation
import PSOperations

class CloudViewController: UIViewController, SegueHandlerType {

    private var camera: SCNNode!
    private var checkedLastTime = false

    let operationQue = OperationQueue()

    // the TitleNode that is currently in focus
    private var titleNodeInFocus: TitleNode? {
        didSet(prev) {
            prev?.inFocus = false
            titleNodeInFocus?.inFocus = true
        }
    }

    private var titleNodes = [TitleNode]()

    //constants
    //distance swiped divided by this is how much the camera moves
    private let panSpeed: Float = 50
    private let cameraZoom: Double = 13
    //the time it takes to move the distance calculatec by panSpeed
    private let cameraMoveSpeed = 0.5
    //algorithm distances
    private let algoMinimumDistance = 7
    private let algoRandomDistance = 6

    //bounding coordinates for camera
    private let cameraExtensionDistance: Float = 6.0
    private var cameraBounds = Bounds(minX: 0, maxX: 0, minY: 0, maxY: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let scnView = self.view as? SCNView else { fatalError("CloudViewController - cound not set scene") }
//        scnView.showsStatistics = true
        //scene setup
        let scene = SCNScene()
        scnView.scene = scene
        scnView.backgroundColor = UIColor(red:45/255.0, green:147/255.0, blue:250/255.0, alpha: 1.0)
        let sceneNodes = initialSceneNodes()
        for node in sceneNodes {
            scnView.scene!.rootNode.addChildNode(node)
        }

        //register gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))

        var gestureRecognizers = scnView.gestureRecognizers ?? []
        gestureRecognizers.append(tapGesture)
        gestureRecognizers.append(panGesture)
        scnView.gestureRecognizers = gestureRecognizers

        let loadTitleNodes = BlockOperation {
            self.initializeTitleNodes(scnView)
        }
        let firstImageLoad = BlockOperation {
            _ = self.checkCameraRaycast()
        }
        firstImageLoad.addDependency(loadTitleNodes)
        operationQue.addOperation(loadTitleNodes)
        operationQue.addOperation(firstImageLoad)
    }

    private func initialSceneNodes() -> [SCNNode] {
        //Create camera node
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        //Forces 2d perspective and zooms out
        camera.usesOrthographicProjection = true
        camera.orthographicScale = self.cameraZoom //Adjust this to zoom in/out
        cameraNode.camera = camera
        self.camera = cameraNode
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 40)

        //Ambient light
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = SCNLightTypeAmbient
        ambientLight.color = UIColor.darkGrayColor()
        ambientLightNode.light = ambientLight

        return [cameraNode, ambientLightNode]
    }

    private func initializeTitleNodes(scnView: SCNView) {
        // Generate nodes
        let titleHandler = TitleHandler.shared
        let titleAlgo = CloudTitles()
        let cloudTitles = titleAlgo.getOrderedTitles()
        let algo = CloudPlacement()
        //we want to skip (0,0) as the first position, that why its titles.count + 1
        let cloudCoordinates = algo.getCloudPositions(titleHandler.titles.count + 1,
                                                      minimumDistance: algoMinimumDistance,
                                                      randomDistance: algoRandomDistance)

        for (i, title) in cloudTitles.enumerate() {
            let (x, y) = cloudCoordinates[i+1]
            let point = (x: Float(x), y: Float(y))

            //bounding box
            cameraBounds.stretchToFit(point)

            let titleNode = TitleNode(title: title, position: SCNVector3(x: Float(x), y: Float(y), z: 0))
            self.titleNodes.append(titleNode)
            scnView.scene!.rootNode.addChildNode(titleNode)
        }

        //Adjust values for bounding box
        cameraBounds.expandBy(cameraExtensionDistance)
    }

    func handleTap(gesture: UIGestureRecognizer) {
        guard let hitResults = checkCameraRaycast(),
            nodeName = hitResults.first?.node.name,
            hitBoxName = nodeName.characters.split("-").first.map(String.init),
            hitBoxIndex = Int(hitBoxName),
            title = TitleHandler.shared.titleMap[hitBoxIndex] else { return }

        performSegueWithIdentifier(.ShowEpisodeViewController, sender: title)
    }

    func handlePan(gesture: UIPanGestureRecognizer) {
        guard let scnView = self.view as? SCNView else { fatalError("Could not get self as view") }

        if gesture.state == .Changed {
            let endPoints = gesture.translationInView(scnView)

            let oldPos = camera.position
            // calculate move distance in x and y direction
            let (dx, dy) = (Float(endPoints.x) / panSpeed, Float(endPoints.y) / -panSpeed)
            let (newX, newY) = cameraBounds.closestMatch(toPoint: (x: oldPos.x + dx, y: oldPos.y + dy))
            let newPos = SCNVector3(x: newX, y: newY, z: oldPos.z)

            let moveAction = SCNAction.moveTo(newPos, duration: cameraMoveSpeed)
            camera.runAction(moveAction, completionHandler: cameraMovedHitCheck)
        }

    }

    //Performs an raycast from the camera down to z = -1.0 and returns the results
    private func checkCameraRaycast() -> [SCNHitTestResult]? {
        let cameraPointedAt = self.camera.position
        let toPoint = SCNVector3(x: cameraPointedAt.x, y: cameraPointedAt.y, z: -1.0)
        guard let scnView = self.view as? SCNView else { fatalError("Could not get self.view as scnView") }
        //check if we need to load some images first
        if self.checkedLastTime == false {
            self.checkedLastTime = true
            let checkImages = BlockOperation {
                for title in self.titleNodes {
                    if !title.imageLoaded && scnView.isNodeInsideFrustum(title, withPointOfView: self.camera) {
                        title.loadImage()
                    }
                }
                self.checkedLastTime = false
            }
            self.operationQue.addOperation(checkImages)
        }
        return scnView.scene?.rootNode.hitTestWithSegmentFromPoint(cameraPointedAt, toPoint: toPoint, options: [:])
    }


    //Runs everytime the camera moves
    private func cameraMovedHitCheck() {
        let titleNode = checkCameraRaycast()?.first?.node as? TitleNode
        let titleIdString = titleNode.map { node in String(node.titleObject.id) }

        self.titleNodeInFocus = titleNodes.find { node in node.name == titleIdString }
    }

    //MARK: Segue stuff for moving to episode view
    enum SegueIdentifier: String {
         case ShowEpisodeViewController = "Show Episode View Controller"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowEpisodeViewController:
            guard let epContr = segue.destinationViewController as? EpisodeViewController, let titleObj = sender as? Title else { return }
            epContr.titleObj = titleObj
        }
    }
}

typealias Point = (x: Float, y: Float)

private struct Bounds {
    var minX, maxX, minY, maxY: Float
}

extension Bounds {
    /**
     Returns the point inside the bounds that is closest to the given point.

     - Parameter point: The point to find a match for.
     */
    func closestMatch(toPoint point: Point) -> Point {
        var newPoint = point
        newPoint.x = min(maxX, max(minX, point.x))
        newPoint.y = min(maxY, max(minY, point.y))
        return newPoint
    }

    /**
     Expand bounds to fit a given point.

     - Parameter point: The point that should fit into the bounds.
     */
    mutating func stretchToFit(point: Point) {
        minX = min(point.x, minX)
        maxX = max(point.x, maxX)
        minY = min(point.y, minY)
        maxY = max(point.y, maxY)
    }

    /**
     Expand bounds the given distance in every direction.

     - Parameter distance: The distance to extend the bounds by.
     */
    mutating func expandBy(distance: Float) {
        minX -= distance
        maxX += distance
        minY -= distance
        maxY += distance
    }
}
