//
//  FlarePhysicsViewController.swift
//  Flare
//
//  Created by Halston v on 12/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import UIKit


extension FlareViewController {
    
    
    
    
    @IBAction func handlePan(_ recognizer:UIPanGestureRecognizer) {
        if self.flareTitle.text != "" {
            let translation = recognizer.translation(in: self.view)
            if let view = recognizer.view {
                view.center = CGPoint(x:view.center.x + 0,
                                      y:view.center.y + translation.y)
            }
            recognizer.setTranslation(CGPoint.zero, in: self.view)
            if recognizer.state == UIGestureRecognizerState.ended {
                let velocity = recognizer.velocity(in: self.view)
                let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
                let slideMultiplier = magnitude / 2000
                let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
                let finalPoint = CGPoint(x:recognizer.view!.center.x + (0),
                                         y:recognizer.view!.center.y + (velocity.y * slideFactor))
                
                UIView.animate(withDuration: Double(slideFactor * 2),
                               delay: 0,
                               options: UIViewAnimationOptions.curveEaseOut,
                               animations: {recognizer.view!.center = finalPoint },
                               completion: nil
                )
                if self.onSwipe() {
                    let seconds = 0.8
                    let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                    let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                        self.performSegue(withIdentifier: "cancelToMapView", sender: self)
                    })
                }
            }
        } else {
            self.displayAlertMessage("Please enter a title")
        }
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if self.onSwipe() {
            self.performSegue(withIdentifier: "cancelToMapView", sender: self)
        }
    }
}
