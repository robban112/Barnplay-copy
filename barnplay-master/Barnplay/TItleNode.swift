//
//  TItleNode.swift
//  Barnplay
//
//  This class hold everything for a node in the cloud view
//
//  Created by Jonas Wedin on 2016-05-03.
//  Copyright © 2016 Bolibompagänget. All rights reserved.
//

import SceneKit
import UIKit
import QuartzCore

class TitleNode: SCNNode {
    //child nodes
    var titleObject: Title
    var cloudBackgroundNode: SCNNode?
    var focusRingNode: SCNNode?
    //Measurments
    let charImgBoxWidthHeight: CGFloat   = 5.0
    let focusRingBoxWidthHeight: CGFloat = 6.0
    let cloudBoxWidth: CGFloat           = 11.0
    let cloudBoxHeight: CGFloat          = 9.0
    let charImgPosZ: Float               = 0.0
    let focusRingPosZ: Float             = -0.1
    let cloudPosZ: Float                 = -0.2
    //Statics for finding nodes by name
    // just title id is a char img
    // cloud is "\(title.id)-cloud"
    // focusRing is "\(title.id)-focusRing"
    static let cloudNameIdent = "-cloud"
    static let focusRingIdent = "-focusRing"
    //
    var imageLoaded = false


    init(title: Title, position: SCNVector3) {
        self.titleObject = title
        super.init()
        self.name = "\(self.titleObject.id)"
        self.position = SCNVector3(x: position.x, y:position.y, z: self.charImgPosZ)

        let charImgPlane = SCNPlane(width: self.charImgBoxWidthHeight, height: self.charImgBoxWidthHeight)
        //Anything above width or height / 2 will make it round
        charImgPlane.cornerRadius = self.charImgBoxWidthHeight / 2
        self.geometry = charImgPlane

        //Create the cloud
        let cloudBox = SCNPlane(width: cloudBoxWidth, height: cloudBoxHeight)
        let cloudNode = SCNNode(geometry: cloudBox)
        cloudNode.name = "\(self.titleObject.id)\(TitleNode.cloudNameIdent)"
        let randCloud = random() % 3; //we have 3 different clouds to choose from!
        cloudNode.geometry!.firstMaterial!.diffuse.contents = UIImage(imageLiteral: "cloud0\(randCloud)")
        cloudNode.position = SCNVector3(x: 0, y: 0, z: self.cloudPosZ)
        //add the node
        self.addChildNode(cloudNode)
        self.cloudBackgroundNode = cloudNode
        //Create the focus ring
        let focusRing = SCNPlane(width: self.focusRingBoxWidthHeight, height: self.focusRingBoxWidthHeight)
        focusRing.cornerRadius = self.focusRingBoxWidthHeight / 2
        focusRing.firstMaterial?.transparency = 0

        focusRing.firstMaterial?.diffuse.contents = UIColor.greenColor()
        let focusRingNode = SCNNode(geometry: focusRing)
        focusRingNode.name = "\(self.titleObject.id)\(TitleNode.focusRingIdent)"
        focusRingNode.position = SCNVector3(x: 0, y: 0, z: self.focusRingPosZ)
        self.addChildNode(focusRingNode)
        self.focusRingNode = focusRingNode

    }

    func loadImage() {
        if self.imageLoaded { return }
        self.imageLoaded = true
        let tempImageView = UIImageView()
        if let imageUrl = NSURL(string: self.titleObject.characterImage!) {
            tempImageView.kf_setImageWithURL(imageUrl, placeholderImage: nil, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                //Async success function that sets the image
                if image != nil {
                    self.geometry!.firstMaterial?.diffuse.contents = image!
                } else {
                    self.imageLoaded = false
                }
            })
        }
    }

    var inFocus: Bool {
        get { return self.focusRingNode?.geometry?.firstMaterial?.transparency == 1 }
        set { self.focusRingNode?.geometry?.firstMaterial?.transparency = newValue ? 1 : 0 }
    }

    //Xcode needs this for some reason
    required init?(coder aDecoder: NSCoder) {
        fatalError("aDecoder has not been implemented for TitleNode class")
    }

}
