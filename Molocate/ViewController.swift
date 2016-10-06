import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


var frame:CGRect = CGRect()

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var loginActive = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
        
        stuckedVideoConfiguration()
        myCache.removeAll()
        dictionary.removeAllObjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        scrollWidth = 3 * self.view.frame.size.width
        scrollHeight  = self.view.frame.size.height
        adjustViewLayout(MolocateDevice.size)
        
        if(MolocateDevice.isConnectedToNetwork()){
            if UserDefaults.standard.object(forKey: "userToken") != nil {
                MoleUserToken = UserDefaults.standard.object(forKey: "userToken") as? String
                self.view.isHidden = true
                MolocateAccount.getCurrentUser({ (data, response, error) in
                    DispatchQueue.main.async{
                        self.performSegue(withIdentifier: "login", sender: self)
                        user = MoleCurrentUser
                    }
                })
                
            }
        }else{
            displayAlert("Hata", message: "Internet bağlantınızı kontrol ediniz")
        }
        
    }
    
    func initGui(){
        
        let screenHeight = MolocateDevice.size.height
        let screenWidth = MolocateDevice.size.width
        
        loginBut.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        loginBut.layer.shadowOffset = CGSize(width: 0.0, height: 0.7)
        loginBut.layer.shadowOpacity = 1.0
        loginBut.layer.shadowRadius = 1.0
        loginBut.layer.masksToBounds = false
        loginBut.layer.cornerRadius = 5
        loginBut.layer.borderWidth = 1
        loginBut.layer.borderColor = swiftColor.cgColor
        
        let imageView = UIImageView(image: UIImage(named: "Logo.png"))
        imageView.frame = CGRect(x: (screenWidth / 2 ) - (screenHeight * 80), y: 10, width: (screenHeight  / 9) , height: (screenHeight  / 9))
        self.view.addSubview(imageView)
        
  
        username.frame.origin.y = (screenHeight * 135) / 450
        password.frame.origin.y = (screenHeight * 170) / 450
        email.frame.origin.y = (screenHeight * 205 ) / 450
        loginBut.frame.origin.y = (screenHeight * 240) / 450
        orText.frame.origin.y = (screenHeight * 290) / 450
        facebookButton.frame.origin.y = (screenHeight * 325) / 450
        forgotButton.frame.origin.y = (screenHeight * 375 ) / 450
        registeredText.frame.origin.y = (screenHeight * 410) / 450
        
        username.frame.size.height = (screenHeight * 25) / 450
        password.frame.size.height = (screenHeight * 25) / 450
        email.frame.size.height = (screenHeight * 25 ) / 450
        loginBut.frame.size.height = (screenHeight * 40) / 450
        orText.frame.size.height = (screenHeight * 25) / 450
        facebookButton.frame.size.height = (screenHeight * 40) / 450
        forgotButton.frame.size.height = (screenHeight * 25 ) / 450
        registeredText.frame.size.height = (screenHeight * 25) / 450
        username.layer.borderColor = UIColor.white.cgColor
        password.layer.borderColor = UIColor.white.cgColor
        email.layer.borderColor = UIColor.white.cgColor
        email.isHidden = true
        
        username.attributedPlaceholder = NSAttributedString(string:"Kullanıcı Adı",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.white])
        email.attributedPlaceholder = NSAttributedString(string:"E-mail",
                                                         attributes:[NSForegroundColorAttributeName: UIColor.white])
        password.attributedPlaceholder = NSAttributedString(string:"Şifre",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.white])
        username.delegate = self
        password.delegate = self
        
        username.autocapitalizationType = .none
        email.autocapitalizationType = .none
        
        frame = self.view.frame
    }
    
    
    func stuckedVideoConfiguration(){
       if UserDefaults.standard.bool(forKey: "isStuck"){
            MolocateVideo.decodeGlobalVideo()
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButton(_ sender: AnyObject) {
        if(MolocateDevice.isConnectedToNetwork()){
            choosedIndex = 2
            if username.text == "" || password.text == "" {
                displayAlert("Hata", message: "lütfen kullanıcı adı ve parola giriniz.")
            }else {
                activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                let uname: String = (username.text?.lowercased())!
                let pwd: String = password.text!
                
                if loginActive {
                    
                    MolocateAccount.Login(uname, password: pwd, completionHandler: { (data, response, error) in
                        DispatchQueue.main.async(execute: {
                            if( data == "success" ){
                                self.performSegue(withIdentifier: "login", sender: self)
                                if UIApplication.shared.isIgnoringInteractionEvents {
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                                self.activityIndicator.stopAnimating()
                            }else{
                                self.displayAlert("Hata", message: "Kullanıcı Adı ya da Parola Yanlış!")
                                self.activityIndicator.stopAnimating()
                                if UIApplication.shared.isIgnoringInteractionEvents {
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                            }
                        })
                    })
                    
                    
                }else {
                    
                    let emailValidation = MolocateUtility.isValidEmail(email.text!)
                    //print(emailValidation)
                    if username.text?.characters.count > 3 && emailValidation{
                        let mail: String = email.text!.lowercased()
                        
                        MolocateAccount.SignUp(uname, password: pwd, email: mail, completionHandler: { (data, response, error) in
                            DispatchQueue.main.async(execute: {
                                if(data == "success"){
                                    self.performSegue(withIdentifier: "login", sender: self)
                                    if UIApplication.shared.isIgnoringInteractionEvents {
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                    }
                                    
                                } else{
                                    self.displayAlert("Hata", message: data)
                                    if UIApplication.shared.isIgnoringInteractionEvents {
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                    }
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.hidesWhenStopped = true
                                }
                                
                            })
                            
                        })
                        
                        
                    }else if username.text?.characters.count < 4 {
                        self.displayAlert("Hata", message: "Lütfen kullanıcı adınız için 3 karakterden fazlasını giriniz.")
                    }else if !emailValidation{
                        //self.displayAlert("Hata", message: "Lütfen geçerli bir mail adresi giriniz.")
                    }
                }
                
            }
        }else{
            self.displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
        
    }
    
    
    
    
    @IBAction func signupButton(_ sender: AnyObject) {
        //signup butonuna basınca login ve signup yer değiştirip işlevi yer değiştiriyor
        
        if loginActive == true{
            email.isHidden = false
            signupBut.setTitle("Giriş yap", for: UIControlState())
            registeredText.text = "Zaten üye misin?"
            loginBut.setTitle("Üye ol", for: UIControlState())
            loginActive = false
        } else {
            email.isHidden = true
            signupBut.setTitle("Üye ol", for: UIControlState())
            registeredText.text = "Hala kayıtlı değil misin?"
            loginBut.setTitle("Giriş yap", for: UIControlState())
            loginActive = true
        }
    }
    
    
    @IBAction func facebooklogin(_ sender: AnyObject) {
        if(MolocateDevice.isConnectedToNetwork()){
            fbLoginInitiate()
        }else{
            displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
    }
    
    @IBAction func forgotButton(_ sender: AnyObject) {
      //  print("user forgot password")
    }
  
    
    func fbLoginInitiate() {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email","user_birthday", "user_friends"],from:self,handler: { (Result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            
            if (error != nil) {
                self.removeFbData()
            } else if Result.isCancelled {
               // print("Error in fbLoginInitiate")
                self.removeFbData()
            } else {
               // print("success")
                FbToken = FBSDKAccessToken.current().tokenString
                let json = ["access_token":FbToken]
                
               // print(FbToken)
                
                MolocateAccount.FacebookLogin(json, completionHandler: { (data, response, error) in
                    if (data == "success") {
                        MolocateAccount.getCurrentUser({ (data, response, error) in
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "login", sender: self)
                            }
                        })
                        
                        
                    } else if (data == "signup") {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "facebookLogin", sender: self)
                        }
                    }
                    
                })
                
                
                if Result.grantedPermissions.contains("email") {
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
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil{
           // print("login completed...")
        }else{
           // print(error.localizedDescription)
        }
    }
    
    func removeFbData() {
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrent(nil)
    }
    
    
    func displayAlert(_ title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .default, handler: { (action) -> Void in
            self.activityIndicator.stopAnimating()
        })))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            self.view.endEditing(true)   // ...
        }
        super.touchesBegan(touches, with:event)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == username){
            username.attributedPlaceholder = nil
        }else if(textField == email){
            email.attributedPlaceholder = nil
        }else if(textField == password){
            
            password.attributedPlaceholder = nil
        }
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(username.text == ""){
            username.attributedPlaceholder = NSAttributedString(string:"Kullanıcı Adı",
                                                                attributes:[NSForegroundColorAttributeName: UIColor.white])
        }
        
        if(email.text == ""){
            email.attributedPlaceholder = NSAttributedString(string:"E-mail",
                                                             attributes:[NSForegroundColorAttributeName: UIColor.white])
        }
        if(password.text == ""){
            password.attributedPlaceholder = NSAttributedString(string:"Şifre",
                                                                attributes:[NSForegroundColorAttributeName: UIColor.white])
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField==username){
            let maxLength = 20
            let aSet = CharacterSet(charactersIn:"ABCDEFGHIJKLMNOPRSTUVYZXWQabcdefghijklmnoprstuvyzxwq1234567890_-.").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            
            if(string == numberFiltered && newString.length <= maxLength){
                return true
            }else{
                return false
            }
            
        }else{
            return true
        }
    }
    
    

}



