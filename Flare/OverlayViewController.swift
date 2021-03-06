//
//  OverlayViewController.swift
//  Flare
//
//  Created by Halston van der Sluys on 12/9/16.
//  Copyright © 2016 appflare. All rights reserved.
//


import Foundation
import MapKit
import Firebase

extension MapViewController {
    
    func plotBoosts(_ friendsBoostOverlays: [MKCircle], publicBoostOverlays: [MKCircle]) {
        self.mapView.delegate = self
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        self.mapView.addOverlays(friendsBoostOverlays)
        self.mapView.addOverlays(publicBoostOverlays)
        
    }
    
    func createBoostArrayAndPlot(friendsArray: [String]) {
        getFriendsBoostCountsFromDatabase(friendsArray) {
            (result: [MKCircle]) in
            self.getPublicBoostCountsFromDatabase(friendsArray, friendsBoostArray: result) {
                (result: [MKCircle], friendsBoostArray: [MKCircle]) in
                self.plotBoosts(friendsBoostArray, publicBoostOverlays: result)
            }
        }
    }
    
    func getFriendsBoostCountsFromDatabase(_ friendsArray: [String], completion: @escaping (_ result: [MKCircle]) -> ()) {
        getFlareTime()
        let flareRef = self.ref.child("flares").queryOrdered(byChild: "timestamp").queryStarting(atValue: activeFlareTime)
        var handle: UInt = 0
        
        handle = flareRef.observe(.value, with: { (snapshot) in
            var boostOverlays = [MKCircle]()
            for item in snapshot.children {
                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                if (friendsArray.contains(data["facebookID"] as! String) || data["facebookID"] as! String == self.uid!) {
                    let flare = (item as! FIRDataSnapshot).value! as! [String : AnyObject]
                    
                    var boostCount = flare["boostCount"] as? Int ?? 0
                    if boostCount > 5 {
                        boostCount = 5
                    }
                    
                    let latitude = flare["latitude"] as! String
                    let longitude = flare["longitude"] as! String
                    if boostCount != 0 {
                        for index in 1...(boostCount) {
                            let radius: CLLocationDistance
                            radius = CLLocationDistance(index*75)
                            let newBoostOverlay = MKCircle(center: CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!), radius: radius)
                            newBoostOverlay.title = "friends"
                            boostOverlays.append(newBoostOverlay)
                        }
                    }
                }
            }
            flareRef.removeObserver(withHandle: handle)
            completion(boostOverlays)
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getPublicBoostCountsFromDatabase(_ friendsArray: [String], friendsBoostArray: [MKCircle], completion: @escaping (_ result: [MKCircle], _ friendsBoostArray: [MKCircle]) -> ()) {
        getFlareTime()
        let friendsBoostArray = friendsBoostArray
        
        let flareRef = self.ref.child("flares").queryOrdered(byChild: "timestamp").queryStarting(atValue: activeFlareTime)
        var handle: UInt = 0
        
        handle = flareRef.observe(.value, with: { (snapshot) in
            var boostOverlays = [MKCircle]()
            for item in snapshot.children {
                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                if (data["isPublic"] as! Bool) && !(friendsArray.contains(data["facebookID"] as! String) || data["facebookID"] as! String == self.uid!) {
                    let flare = (item as! FIRDataSnapshot).value! as! [String : AnyObject]
                    var boostCount = flare["boostCount"] as? Int ?? 0
                    if boostCount > 5 {
                        boostCount = 5
                    }
                    let latitude = flare["latitude"] as! String
                    let longitude = flare["longitude"] as! String
                    if boostCount != 0 {
                        for index in 1...(boostCount) {
                            let radius: CLLocationDistance
                            radius = CLLocationDistance(index*75)
                            let newBoostOverlay = MKCircle(center: CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!), radius: radius)
                            newBoostOverlay.title = "public"
                            boostOverlays.append(newBoostOverlay)
                        }
                    }
                }
            }
            flareRef.removeObserver(withHandle: handle)
            completion(boostOverlays, friendsBoostArray)
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc(mapView:viewForOverlay:) func mapView(_ mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self){
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            if overlay.title! == "friends" {
                circleRenderer.fillColor = UIColor.orange.withAlphaComponent(0.15)
            } else {
                circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.1)
                
            }
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
}
