//
//  SMPhotoViewer.swift
//  element3
//
//  Created by Zignuts Technolab on 01/08/19.
//  Copyright © 2019 Zignuts Technolab. All rights reserved.
//

import Foundation
import UIKit
class SMPhotoViewer{
    class func showPhoto(toView delegate:UIViewController, imageinfo:GSImageInfo, transition:GSTransitionInfo?){
        var imageViewer:GSImageViewerController
        if let trans = transition{
              imageViewer = GSImageViewerController(imageInfo: imageinfo, transitionInfo: trans)
        }else{
            imageViewer = GSImageViewerController(imageInfo: imageinfo)
        }
        delegate.present(imageViewer, animated: true, completion: nil)
    }
    
    static func showImage(toView delegate:UIViewController, image:UIImage, fromView:UIView?){
        
        var imageViewer:GSImageViewerController
        let imageInfo = GSImageInfo(image: image, imageMode: GSImageInfo.ImageMode.aspectFit)
        
        if let trans = fromView{
            let transition = GSTransitionInfo(fromView: trans)
            imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transition)
        }else{
            imageViewer = GSImageViewerController(imageInfo: imageInfo)
        }
        delegate.present(imageViewer, animated: true, completion: nil)
    }
}

