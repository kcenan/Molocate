import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation


var scrollWidth: CGFloat = 0.0
var scrollHeight: CGFloat = 0.0

class firstController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var logInButton: UIButton!
   
    @IBOutlet var facebookButton: UIButton!
    
    @IBOutlet var imageMole: UIImageView!
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
   
    @IBAction func facebookButton(_ sender: AnyObject) {
        if(MolocateDevice.isConnectedToNetwork()){
            fbLoginInitiate()
        }else{
            displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
    }
    
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustViewLayout(size)
    }
    
    func adjustViewLayout(_ size: CGSize) {
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
    
    
    func stuckedVideoConfiguration(){
        if UserDefaults.standard.bool(forKey: "isStuck"){
            MolocateVideo.decodeGlobalVideo()
        }
    }
    
    
    func displayAlert(_ title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .default, handler: { (action) -> Void in
            self.activityIndicator.stopAnimating()
        })))
        self.present(alert, animated: true, completion: nil)
    }
    
    func removeFbData() {
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
    }
    
    func fbLoginInitiate() {
        choosedIndex = 2

        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email","user_birthday", "user_friends"],from:self,handler: { (loginresult, error) -> Void in
            
            if (error != nil) {
                self.removeFbData()
            } else if (loginresult?.isCancelled)! {
                //print("Error in fbLoginInitiate")
                self.removeFbData()
            } else {
                //print("success")
                FbToken = FBSDKAccessToken.current().tokenString
                let json = ["access_token":FbToken]
                
              //  print(FbToken)
                
                MolocateAccount.FacebookLogin(json as JSONParameters, completionHandler: { (data, response, error) in
                    if (data == "success") {
                        MolocateAccount.getCurrentUser({ (data, response, error) in
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "autoLogin", sender: self)
                            }
                        })
                        
                        
                    } else if (data == "signup") {
                        DispatchQueue.main.async {
                             self.performSegue(withIdentifier: "facebookSignUp", sender: self)
                         //   print("face de oldu")
                        }
                    }
                    
                })
                
                
                if (loginresult?.grantedPermissions.contains("email"))! {
                    //Do work
                    self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                    self.activityIndicator.center = self.view.center
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
                    self.view.addSubview(self.activityIndicator)
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    // self.fetchFacebookProfile()
                } else {
                    //Handle error
                }
                
            }
        })
    }
    
    override func viewDidLoad() {
        
        logInButton.layer.cornerRadius = 5
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.clear.cgColor
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.clear.cgColor
        
        facebookButton.layer.cornerRadius = 5
        facebookButton.layer.borderWidth = 1
        facebookButton.layer.borderColor = UIColor.clear.cgColor
        
        navigationController?.navigationBar.isHidden = true
        
      
        //gerek var mı?
        dictionary.removeAllObjects()
        myCache.removeAll()
        stuckedVideoConfiguration()
        //bunlara?
    }
    override func viewWillAppear(_ animated: Bool) {
        
                adjustViewLayout(MolocateDevice.size)
        
                if(MolocateDevice.isConnectedToNetwork()){
                    if UserDefaults.standard.object(forKey: "userToken") != nil {
                        MoleUserToken = UserDefaults.standard.object(forKey: "userToken") as? String
                        self.view.isHidden = true
                        MolocateAccount.getCurrentUser({ (data, response, error) in
                            DispatchQueue.main.async{
                                self.performSegue(withIdentifier: "autoLogin", sender: self)
                               // print("üye var lan girdi")
                                user = MoleCurrentUser
                            }
                        })
        
                    }
                }else{
                    displayAlert("Hata", message: "Internet bağlantınızı kontrol ediniz")
                }
                
        
    }
    
    //buna bakmak lazım
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        adjustViewLayout(size)
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
