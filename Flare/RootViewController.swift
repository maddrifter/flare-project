//
//  RootViewController.swift
//  Flare
//
//  Created by Halston v on 08/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class RootViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var loginButton = FBSDKLoginButton()
    var googleSignButton = UIButton()
    var annoyButton = UIButton()
    var signType    = 0 // 0: facebook, 1: annonymous, 2: Google
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Must implement this delegate for google sign
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        self.loginButton.isHidden = false
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.saveUserToDatabase()
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let mapViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "mapView")
                self.present(mapViewController, animated: true, completion: nil)
            } else {
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self
                self.view.addSubview(self.loginButton)
                self.loginButton.isHidden = false
                
                self.addGoogleSign()
             //   self.addAnnoymous()
            }
        }
    }
    
    //GOOGLE SIGN IN
    private func addGoogleSign(){
        self.view.addSubview(self.googleSignButton)
        self.googleSignButton.setTitle("Sign in with Google", for: UIControlState.normal)
        self.googleSignButton.backgroundColor = UIColor.green
        self.googleSignButton.translatesAutoresizingMaskIntoConstraints = false
        self.googleSignButton.widthAnchor.constraint(equalTo: self.loginButton.widthAnchor).isActive = true
        self.googleSignButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.googleSignButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.googleSignButton.topAnchor.constraint(equalTo: self.loginButton.bottomAnchor, constant: 10).isActive = true
        self.googleSignButton.addTarget(self, action: #selector(RootViewController.googleSign), for: UIControlEvents.touchUpInside)
    }
    
    //Anonymous Sign In
    private func addAnnoymous(){
        self.view.addSubview(self.annoyButton)
        self.annoyButton.setTitle("Anonymous", for: UIControlState.normal)
        self.annoyButton.backgroundColor = UIColor.gray
        self.annoyButton.translatesAutoresizingMaskIntoConstraints = false
        self.annoyButton.widthAnchor.constraint(equalTo: self.loginButton.widthAnchor).isActive = true
        self.annoyButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.annoyButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.annoyButton.topAnchor.constraint(equalTo: self.googleSignButton.bottomAnchor, constant: 10).isActive = true
        self.annoyButton.addTarget(self, action: #selector(RootViewController.annonymousSign), for: UIControlEvents.touchUpInside)
    }
    
    func annonymousSign()  {
        self.signType = 1

        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            
        })
    }
    
    func googleSign()  {
        GIDSignIn.sharedInstance().signIn()

    }
    
    //MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        // ...
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    
    func saveUserToDatabase() {
        let facebook = Facebook()
        let ref = FIRDatabase.database().reference()
        facebook.getFacebookID()
        if let user = FIRAuth.auth()?.currentUser, let token = FIRInstanceID.instanceID().token() {
            let userRef = ref.child("users/\(user.uid)")
            
            
            let newUser: [String: Any]
            if self.signType == 0 {
                 newUser = ["facebookID": facebook.uid! as String, "tokenID": token as String, "fullname": user.displayName! as String, "email": user.email! as String, "profileURL": String(describing: user.photoURL!) as String] as [String : Any]
                
                userRef.setValue(newUser)

            } else if self.signType == 1{
                 newUser = ["facebookID": "","tokenID": token as String, "fullname": user.uid as String, "email": "", "profileURL": ""] as [String : Any]
                
                userRef.setValue(newUser)

            }
           
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        self.loginButton.isHidden = true
        if(error != nil) {
            self.loginButton.isHidden = false
        } else if(result.isCancelled) {
            self.loginButton.isHidden = false
        } else {
            self.signType = 0

            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                if error != nil{
                    return
                }
                
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "endUserAgreementSegue" {
            if let ivc = segue.destination as? EndUserAgreementViewController {
                ivc.route = "rootView"
            }
        }
    }
    
}
