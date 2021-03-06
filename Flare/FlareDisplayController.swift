import Foundation
import Firebase
import MapKit
import FBSDKLoginKit
import CoreLocation
import SwiftyJSON

extension MapViewController {
    
    func getFlareTime() {
        let currentTimeInMilliseconds = Date().timeIntervalSince1970 * 1000
        let flareTimeLimitInMinutes = 240
        let flareTimeLimitInMiliseconds = Double(flareTimeLimitInMinutes * 60000)
        self.activeFlareTime = (currentTimeInMilliseconds - flareTimeLimitInMiliseconds)
    }
    
    func getPublicFlaresFromDatabase(_ friendsArray: [String], completion: @escaping (_ result: [Flare], _ friendsArray: [String]) -> ()) {
        getFlareTime()
        getFacebookID()
        let flareRef = ref.child("flares")
        flareRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: activeFlareTime).observe(.value, with: { (snapshot) in
            var newItems = [Flare]()
            for item in snapshot.children {
                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                if ((data["isPublic"] as! Bool) && !(friendsArray.contains(data["facebookID"] as! String))) && !(data["facebookID"] as! String == self.uid!)  {
                    let flare = Flare(snapshot: item as! FIRDataSnapshot)
                    flare.imageName = "friendsPin"
                    newItems.insert(flare, at: 0)
                }
            }
            completion(newItems, friendsArray)
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFacebookID() {
        if let user = FIRAuth.auth()?.currentUser {
            for profile in user.providerData {
                self.uid = profile.uid;  // Provider-specific UID
            }
        }
    }
    
    func getFriendsFlaresFromDatabase(_ friendsArray: [String], completion: @escaping (_ result: [Flare], _ friendsarray: [String]) -> ()) {
        getFlareTime()
        getFacebookID()
        let flareRef = ref.child("flares")
        flareRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: activeFlareTime).observe(.value, with: { (snapshot) in
            var newItems = [Flare]()
            for item in snapshot.children {
                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
                var recipients = [String]()
                if data["recipients"] != nil {
                    recipients = data["recipients"] as! [String]
                }
                if data["facebookID"] as! String == self.uid! || recipients.contains(self.uid!) || (data["isPublic"] as! Bool == true && friendsArray.contains(data["facebookID"] as! String)) {
                    let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                    newFlare.imageName = "publicPin"
                    newItems.insert(newFlare, at: 0)
                }
            }
            completion(newItems, friendsArray)
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func findBoostCount(flareId: String, completion: @escaping (_ result: String) -> ())  {
       self.ref.child("flares/\(flareId)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let flare = snapshot.value as? NSDictionary
            let count = flare?["boostCount"]
            var countString: String
            if count == nil {
                countString = "0"
            } else {
                countString = String(describing: count!)
            }
            completion(countString)
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func plotFlares(_ flares: [Flare]) {
        self.mapView.delegate = self
        self.mapView.addAnnotations(flares)
    }
    
}
