//
//  ViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.11.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation




var origin:CGFloat = 0.0
var frame:CGRect = CGRect()

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var loginActive = true
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var registeredText: UILabel!
    @IBOutlet var loginBut: UIButton!
    @IBOutlet var signupBut: UIButton!
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var forgotButton: UIButton!
    @IBOutlet var orText: UILabel!
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    
    @IBAction func forgotButton(sender: AnyObject) {
        print("user forgot password")
    }
    
    //for alert
    
    
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        
        
        if(textField==username){
            let maxLength = 20
            let aSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPRSTUVYZXWQabcdefghijklmnoprstuvyzxwq_-.").invertedSet
            let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            let currentString: NSString = textField.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            
            if(string == numberFiltered && newString.length <= maxLength){
                return true
            }else{
                return false
            }
            
        }else{
            return true
        }
    }
    
    
    
    
    @IBAction func loginButton(sender: AnyObject) {
        if(MolocateDevice.isConnectedToNetwork()){
            choosedIndex = 1
            if username.text == "" || password.text == "" {
                displayAlert("Hata", message: "lütfen kullanıcı adı ve parola giriniz.")
            }
                //uyarı çıkıyor error varsa
            else {
                
                activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                
                
                if loginActive == true {
                    
                    let uname: String = (username.text?.lowercaseString)!
                    let pwd: String = password.text!
                    let json = ["username": uname, "password": pwd]
                    
                    
                    do {
                        
                        let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                        // print(NSString(data: jsonData, encoding: NSUTF8StringEncoding))
                        
                        // create post request
                        let url = NSURL(string: MolocateBaseUrl + "api-token-auth/")!
                        let request = NSMutableURLRequest(URL: url)
                        request.HTTPMethod = "POST"
                        
                        // insert json data to the request
                        
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        //request.addValue("application/json", forHTTPHeaderField: "Accept")
                        request.HTTPBody = jsonData
                        
                        
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                            // print(response)
                            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                            dispatch_async(dispatch_get_main_queue(), {
                                if error != nil{
                                    print("Error -> \(error)")
                                    
                                    return
                                }
                                
                                do {
                                    
                                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                                    
                                    
                                    print("Result -> \(result)")
                                    let dictionary : NSDictionary = result as! NSDictionary
                                    if(dictionary.objectForKey("token") != nil){
                                        MoleUserToken = result["token"] as? String
                                        MolocateAccount.getCurrentUser({ (data, response, error) -> () in
                                            
                                        })
                                        self.performSegueWithIdentifier("login", sender: self)
                                        
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        
                                    } else {
                                        self.displayAlert("Hata", message: "Kullanıcı Adı ya da Parola Yanlış!")
                                        self.activityIndicator.stopAnimating()
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    }
                                    
                                } catch {
                                    print("Error -> \(error)")
                                }
                            })
                        }
                        
                        task.resume()
                        
                        
                        
                        
                    } catch {
                        print(error)
                        
                        
                    }
                    
                }
                    
                else {
                    
                    let uname: String = username.text!.lowercaseString
                    let pwd: String = password.text!
                    let mail: String = email.text!.lowercaseString
                    
                    let json = ["username": uname, "password": pwd, "email": mail]
                    
                    
                    do {
                        
                        let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                        // print(NSString(data: jsonData, encoding: NSUTF8StringEncoding))
                        
                        // create post request
                        let url = NSURL(string: MolocateBaseUrl + "account/register/")!
                        let request = NSMutableURLRequest(URL: url)
                        request.HTTPMethod = "POST"
                        
                        // insert json data to the request
                        
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        //request.addValue("application/json", forHTTPHeaderField: "Accept")
                        request.HTTPBody = jsonData
                        
                        
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                            //print(response)
                            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                if error != nil{
                                    print("Error -> \(error)")
                                    
                                    //return
                                }
                                
                                do {
                                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                                    
                                    //print("Result -> \(result)")
                                    if(result.count > 1){
                                        MoleUserToken = result["access_token"] as? String
                                        self.performSegueWithIdentifier("login", sender: self)
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        //print("dsfasfdsadsfa")
                                        
                                    } else{
                                        let error = result["result"] as! String
                                        var errorString = ""
                                        switch (error){
                                        case "user_exist":
                                            errorString = "Lütfen daha önce kullanılmamış bir email seçiniz."
                                            break
                                        case "not_valid":
                                            errorString = "Lütfen geçerli bir email adresi giriniz."
                                            break
                                        default:
                                            break
                                            
                                        }
                                        self.displayAlert("Hata", message: errorString)
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        self.activityIndicator.stopAnimating()
                                        self.activityIndicator.hidesWhenStopped = true
                                    }
                                    
                                    
                                    
                                    
                                } catch {
                                    print("Error -> \(error)")
                                    
                                }
                                
                            })
                        }
                        
                        
                        task.resume()
                        
                        
                        
                        
                    } catch {
                        print(error)
                        
                        
                    }
                    
                    
                }
            }
        }else{
            self.displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
        
    }
    
    
    
    
    @IBAction func signupButton(sender: AnyObject) {
        
        //signup butonuna basınca login ve signup yer değiştirip işlevi yer değiştiriyor
        
        if loginActive == true{
            
            
            email.hidden = false
            
            signupBut.setTitle("Giriş yap", forState: UIControlState.Normal)
            
            registeredText.text = "Zaten üye misin?"
            
            loginBut.setTitle("Üye ol", forState: UIControlState.Normal)
            
            loginActive = false
            
            
            
        } else {
            
            email.hidden = true
            
            signupBut.setTitle("Üye ol", forState: UIControlState.Normal)
            
            registeredText.text = "Hala kayıtlı değil misin?"
            
            loginBut.setTitle("Giriş yap", forState: UIControlState.Normal)
            
            loginActive = true
            
        }
    }
    
    
    @IBAction func facebooklogin(sender: AnyObject) {
        if(MolocateDevice.isConnectedToNetwork()){
            fbLoginInitiate()
        }else{
            displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
    }
    
    func fbLoginInitiate() {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile", "email","user_birthday", "user_friends"], handler: {(Result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            
            if (error != nil) {
                // Process error
                self.removeFbData()
            } else if Result.isCancelled {
                // User Cancellation
                print("Error in fbLoginInitiate")
                self.removeFbData()
            } else {
                //Success
                print("success")
                let fbAccessToken: String = FBSDKAccessToken.currentAccessToken().tokenString
                
                let json = ["access_token":fbAccessToken]
                FbToken = fbAccessToken
                print(json)
                do {
                    
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                    
                    let url = NSURL(string: MolocateBaseUrl + "/account/facebook_login/")!
                    let request = NSMutableURLRequest(URL: url)
                    request.HTTPMethod = "POST"
                    
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.HTTPBody = jsonData
                    
                    
                    let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                        //  print(response)
                        print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            
                            let nsError = error
                            
                            do {
                                let resultJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                                
                                print("Result -> \(resultJson)")
                                
                                if (resultJson["logged_in"] as! Int == 1) {
                                    
                                    
                                    MoleUserToken = resultJson["access_token"] as! String
                                    MolocateAccount.getCurrentUser({ (data, response, error) in
                                        
                                    })
                                    
                                    self.performSegueWithIdentifier("login", sender: self)
                                    
                                } else {
                                    
                                    FaceMail = resultJson["email_validation"] as! String
                                    FaceUsername = resultJson["suggested_username"] as! String
                                    self.performSegueWithIdentifier("facebookLogin", sender: self)
                                }
                                
                            } catch{
                                print("Error:: in mole.follow()")
                            }
                            
                        }}
                    task.resume()
                    
                    
                } catch {
                    print(error)
                }
                
                
                if Result.grantedPermissions.contains("email") {
                    //Do work
                    self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
                    self.activityIndicator.center = self.view.center
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                    self.view.addSubview(self.activityIndicator)
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.startAnimating()
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                    
                    self.fetchFacebookProfile()
                } else {
                    //Handle error
                    
                }
            }
        })
    }
    func removeFbData() {
        //Remove FB Data
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    func fetchFacebookProfile()
    {
        if FBSDKAccessToken.currentAccessToken() != nil {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if ((error) != nil) {
                    //Handle error
                } else {
                    //Handle Profile Photo URL String
                    let userId =  result["id"] as! String
                    _ = "https://graph.facebook.com/\(userId)/picture?type=large"
                    
                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    _ = ["accessToken": accessToken, "user": result]
                }
            })
        }
    }
    
    //        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name,public_profile,email,user_birthday,user_location"])
    //              graphRequest.startWithCompletionHandler( {
    //
    //                    (connection, result, error) -> Void in
    //
    //                    if error != nil {
    //
    //                        print(error)
    //
    //                    } else if let result = result {
    //
    //                        //  var myToken = FBSDKAccessToken.currentAccessToken().tokenString
    //                        //                  print(myToken)
    //
    //
    //
    //            if let error = error {
    //
    //                print(error)
    //
    //            } else {
    //                print("uservar")
    //
    //
    //                        }
    //
    //                }
    //
    //                })
    //    }
    //
    
    //
    //                if let user = user {
    //
    //                    var myToken = FBSDKAccessToken.currentAccessToken().tokenString
    //                    print(myToken)
    //                    // izinler burada belirleniyo, facebookda izin alabilceğin şeylerin listesi string olarak var
    //                   let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name"])
    //
    //                    // Send request to Facebook
    //                    graphRequest.startWithCompletionHandler {
    //
    //                        (connection, result, error) in
    //
    //                        if error != nil {
    //                            // Some error checking here
    //                        }
    //                        else if let result = result as? [String:AnyObject] {
    //
    //                            // Access user data
    //
    //                            let userId = result["id"] as! String
    //
    //                            let PFUser.currentUser()?["name"] = result["name"]  as? String
    //                            kc foto burdan facebookdan alınıyo linkin sonunu değiştirerek fotonun hangi boyutta olacağını ayarlayabiliriz
    //                            let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
    //
    //                                        if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
    //
    //                                               if let data = NSData(contentsOfURL: fbpicUrl) {
    //
    //
    //
    //                                            let imageFile:PFFile = PFFile(data: data)!
    //
    //                                               //parse a burdan atıyor
    //                                                    PFUser.currentUser()?["image"] = imageFile
    //
    //
    //                        }
    //  }
    
    //      self.performSegueWithIdentifier("signUp", sender: self)
    
    
    //  }
    
    
    
    override func viewDidAppear(animated: Bool) {
        if(MolocateDevice.isConnectedToNetwork()){
            if NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil {
                MoleUserToken = NSUserDefaults.standardUserDefaults().objectForKey("userToken") as! String
                self.view.hidden = true
                MolocateAccount.getCurrentUser({ (data, response, error) in
                    dispatch_async(dispatch_get_main_queue()){
                        self.performSegueWithIdentifier("login", sender: self)
                        user = MoleCurrentUser
                    }
                })
                
            }
        }else{
            displayAlert("Hata", message: "Internet bağlantınızı kontrol ediniz")
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width
        loginBut.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
        loginBut.layer.shadowOffset = CGSizeMake(0.0, 0.7)
        loginBut.layer.shadowOpacity = 1.0
        loginBut.layer.shadowRadius = 1.0
        loginBut.layer.masksToBounds = false
        loginBut.layer.cornerRadius = 4.0
        let imageName = "Logo.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        _ = (screenHeight * 80)
        imageView.frame = CGRectMake((screenWidth / 2 ) - (screenHeight * 80), 10, (screenHeight  / 9) , (screenHeight  / 9))
        
        
        view.addSubview(imageView)
        username.delegate = self
        password.delegate = self
        
        // logoImage.frame.origin.y = (screenHeight * 80 ) / 450
        username.frame.origin.y = (screenHeight * 135) / 450
        password.frame.origin.y = (screenHeight * 170) / 450
        email.frame.origin.y = (screenHeight * 205 ) / 450
        loginBut.frame.origin.y = (screenHeight * 240) / 450
        orText.frame.origin.y = (screenHeight * 290) / 450
        facebookButton.frame.origin.y = (screenHeight * 325) / 450
        forgotButton.frame.origin.y = (screenHeight * 375 ) / 450
        registeredText.frame.origin.y = (screenHeight * 410) / 450
        
        //logoImage.frame.size.height = (screenHeight * 100 ) / 450
        //logoImage.frame.size.width = logoImage.frame.size.height
        username.frame.size.height = (screenHeight * 25) / 450
        password.frame.size.height = (screenHeight * 25) / 450
        email.frame.size.height = (screenHeight * 25 ) / 450
        loginBut.frame.size.height = (screenHeight * 40) / 450
        orText.frame.size.height = (screenHeight * 25) / 450
        facebookButton.frame.size.height = (screenHeight * 40) / 450
        forgotButton.frame.size.height = (screenHeight * 25 ) / 450
        registeredText.frame.size.height = (screenHeight * 25) / 450
        username.layer.borderColor = UIColor.whiteColor().CGColor
        password.layer.borderColor = UIColor.whiteColor().CGColor
        email.layer.borderColor = UIColor.whiteColor().CGColor
        
        
        
        
        
        //all frames
        loginBut.layer.cornerRadius = 5
        loginBut.layer.borderWidth = 1
        loginBut.layer.borderColor = swiftColor.CGColor
        
        
        origin = self.view.frame.width
        frame = self.view.frame
        email.hidden = true
        
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            print("Not loged in..")
        } else {
            print("Loged in...")
            
        }
        
        
        
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        scrollWidth = 3 * self.view.frame.size.width
        scrollHeight  = self.view.frame.size.height
        adjustViewLayout(UIScreen.mainScreen().bounds.size)
        // Do any additional setup after loading the view, typically from a nib.
        //print(scrollWidth)
        
        
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        
        if error == nil
        {
            print("login completed...")
            
        }
        else
        {
            
            print(error.localizedDescription)
        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.view.endEditing(true)   // ...
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustViewLayout(size)
    }
    
    func adjustViewLayout(size: CGSize) {
        
        
        switch(size.width, size.height) {
        case (480, 320):
            break                        // iPhone 4S in landscape
            
        case (320, 480):
            is4s = true                    // iPhone 4s pportrait
            break
        case (414, 736):                        // iPhone 6 Plus in portrait
            
            break
        case (736, 414):                        // iphone 6 Plus in landscape
            
            break
        default:
            break
        }
    }
    
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

