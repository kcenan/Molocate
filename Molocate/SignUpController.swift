
import UIKit
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


class signUpController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var termsButton: UIButton!
    @IBOutlet var email: UITextField!
    
    @IBOutlet var toolBar: UIToolbar!
    //locationManagerlı şeyi eklemedim
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var password: UITextField!
    var loginActive = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
    
    @IBAction func termsButton(_ sender: AnyObject) {
       // print("arkadaş termleri merak etti")
        //termleri okuma tuşuna bastı
    }
    
    
    func displayAlert(_ title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .default, handler: { (action) -> Void in
            self.activityIndicator.stopAnimating()
        })))
        self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func signUpButton(_ sender: AnyObject) {
        
        if(MolocateDevice.isConnectedToNetwork()){
            choosedIndex = 2
            if username.text == "" || password.text == "" || email.text == ""{
                displayAlert("Hata", message: "lütfen bilgileri doldurunuz.")
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
                let mail: String = email.text!
                
                let emailValidation = MolocateUtility.isValidEmail(mail)
                
                if username.text?.characters.count > 3 && emailValidation {
                    let mail: String = email.text!.lowercased()
                    
                    MolocateAccount.SignUp(uname, password: pwd, email: mail, completionHandler: { (data, response, error) in
                        DispatchQueue.main.async(execute: {
                            if(data == "success"){
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "signUp", sender: self)
                                }
                                if UIApplication.shared.isIgnoringInteractionEvents {
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                                
                            } else{
                                self.displayAlert("Hata oluştu.", message: data)
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
                    self.displayAlert("Hata", message: "Lütfen geçerli bir mail adresi giriniz.")
                }
            }}
        else{
            self.displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
        
    }
    
    override func viewDidLoad() {
        
        
       
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.clear.cgColor
        
        view.backgroundColor = swiftColor
//        self.navigationController?.navigationBar.barTintColor = swiftColor
//        self.navigationController?.navigationBar.translucent = false
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        username.delegate = self
        email.delegate = self
        password.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        //navigationItem.backBarButtonItem = backItem
        termsButton.titleLabel?.lineBreakMode = .byWordWrapping
        termsButton.titleLabel?.textAlignment = .center
        termsButton.setTitle("Kaydolarak, Koşullarımızı ve Gizlilik İlkemizi.\nkabul etmiş olursun.", for: UIControlState())
        
        //navigationController?.navigationBar.hidden = true
        
      
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
     
        adjustViewLayout(MolocateDevice.size)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            self.view.endEditing(true)   // ...
        }
        super.touchesBegan(touches, with:event)
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
