//  SignUpAdvance.swift
//  Molocate
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


class SignUpAdvance: UIViewController , UITextFieldDelegate {
    let screenSize: CGSize = MolocateDevice.size
    let sendName :String = ""
    
    var username : UITextField!
    var usernameLabel : UILabel!
    var email : UITextField!
    var emailLabel : UILabel!
    var onay : UIButton!
    var message : UILabel!
    var message2 : UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var facebookfriends = MoleUserRelations()
    @IBOutlet var toolBar: UIToolbar!

    @IBOutlet var confirmButton: UIButton!
    
    @IBAction func back(_ sender: AnyObject) {
        //geri basarsa yeni username olmadığı için üye oluşmamış olucak
    }
    @IBOutlet var termsButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
       
        email.delegate = self
        email.autocapitalizationType = .none
        username.delegate = self
        username.autocapitalizationType = .none
       
        if(FaceMail != "not_valid"){email.text = FaceMail}
        
        UIApplication.shared.endIgnoringInteractionEvents()
        termsButton.titleLabel?.lineBreakMode = .byWordWrapping
        termsButton.titleLabel?.textAlignment = .center
        termsButton.setTitle("Kaydolarak, Koşullarımızı ve Gizlilik İlkemizi.\nkabul etmiş olursun.", for: UIControlState())
    }
    
    func initGui(){
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpAdvance.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
       
        toolBar.clipsToBounds = true
        toolBar.isTranslucent = false
        toolBar.barTintColor = swiftColor
        
        message = UILabel()
        message.frame = CGRect(x: screenSize.width / 2 - 90 , y: screenSize.height / 4 - 30 , width: 180, height: 40)
        message.textColor = swiftColor
        message.font = UIFont(name: "AvenirNext-Regular", size: 18)
        message.text = "HOŞGELDİN!"
        message.textAlignment = .center
        self.view.addSubview(message)
        
        message2 = UILabel()
        message2.frame = CGRect(x: screenSize.width / 2 - 125 , y: screenSize.height / 4 + 10 , width: 250 , height: 40)
        message2.textColor = swiftColor
        message2.font = UIFont(name: "AvenirNext-Regular", size: 16)
        message2.text = "Başlamak için son basamak:"
        message2.textAlignment = .center
        self.view.addSubview(message2)
        
        
        onay = UIButton()
        onay.frame = CGRect(x: screenSize.width / 2 - 90 ,y: screenSize.height / 2 + 90 , width: 180 , height: 50)
        onay.setTitleColor(UIColor.white, for: UIControlState())
        onay.contentHorizontalAlignment = .center
        onay.backgroundColor = swiftColor
        onay.setTitle("Onaylıyorum.", for: UIControlState())
        onay.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size:16)
        onay.addTarget(self, action: #selector(SignUpAdvance.pressedOnay(_:)), for:UIControlEvents.touchUpInside)
        self.view.addSubview(onay)
        
        usernameLabel = UILabel()
        usernameLabel.frame = CGRect(x: 20 , y: screenSize.height / 4 + 90 , width: 90 , height: 40)
        usernameLabel.textColor = swiftColor
        usernameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        usernameLabel.text = "Kullanıcı Adı:"
        usernameLabel.textAlignment = .right
        self.view.addSubview(usernameLabel)
        
        username = UITextField()
        username.frame = CGRect(x: 115  , y: screenSize.height / 4 + 90 , width: 180, height: 40 )
        username.textColor = UIColor.black
        username.keyboardType = .default
        username.font = UIFont(name: "AvenirNext-Regular", size: 14)
        let border = CALayer()
        let width = CGFloat(1.5)
        border.borderColor = swiftColor.cgColor
        border.frame = CGRect(x: 0, y: username.frame.size.height - width, width:  username.frame.size.width, height: username.frame.size.height )
        border.borderWidth = width
        
        username.layer.addSublayer(border)
        username.layer.masksToBounds = true
        username.placeholder = "Kullanıcı Adı"
        border.borderWidth = width
        username.layer.addSublayer(border)
        username.textAlignment = .left
        username.layer.masksToBounds = true
        self.view.addSubview(username)
        
        emailLabel = UILabel()
        emailLabel.frame = CGRect(x: 20 , y: screenSize.height / 4 + 140, width: 90, height: 40)
        emailLabel.textColor = swiftColor
        emailLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        emailLabel.text = "E-mail:"
        emailLabel.textAlignment = .right
        self.view.addSubview(emailLabel)
        
        email = UITextField()
        email.frame = CGRect(x: 115  , y: screenSize.height / 4 + 140 , width: 180 , height: 40 )
        email.textColor = UIColor.black
        email.keyboardType = .emailAddress
        email.font = UIFont(name: "AvenirNext-Regular", size: 14)
        let border2 = CALayer()
        border2.frame = CGRect(x: 0, y: email.frame.size.height - width, width:
            email.frame.size.width , height: email.frame.size.height )
        border2.borderColor = swiftColor.cgColor
        border2.borderWidth = width
        email.layer.addSublayer(border2)
        email.layer.masksToBounds = true
        email.placeholder = "E-Mail"
        email.layer.addSublayer(border2)
        email.textAlignment = .left
        email.layer.masksToBounds = true
        self.view.addSubview(email)
    }
    
    func pressedOnay(_ sender: UIButton) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if username.text?.characters.count < 4 {
            displayAlert("Hata", message: "Seçtiğiniz kullanıcı adı 4 ile 20 karakter arasında olmalıdır.")
        }else if !MolocateUtility.isValidEmail(email.text!){
            displayAlert("Tamam", message: "Lütfen geçerli bir mail adresi giriniz")
        }
        else{
            
            let uname = (username.text! as String).lowercased()
            let mail = (email.text! as String).lowercased()
            let token = FbToken
            let json = ["access_token": token , "username": uname, "email": mail]
            
            MolocateAccount.FacebookSignup(json as JSONParameters, completionHandler: { (data, response, error) in
                DispatchQueue.main.async(execute: {
                    if(data == "success"){
                        MolocateAccount.getCurrentUser({ (data, response, error) -> () in
                          
                        })
                        
                        
                        
                        MolocateAccount.getFacebookFriends(completionHandler: { (data, response, error, count, next, previous) in
                            DispatchQueue.main.async(execute: {
                                self.facebookfriends.relations += data.relations
                                
                                MolocateAccount.getSuggestedFriends(completionHandler: { (data, response, error, count, next, previous) in
                                    DispatchQueue.main.async(execute: {
                                        self.facebookfriends.relations  +=  data.relations
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                        self.performSegue(withIdentifier: "usernameAfter", sender: self)
                                    })
                                })
                          
                              
                                
                            })
                            
                        })
                    }else if (data != "error"){
                        self.displayAlert("Dikkat!", message: data!)
                    }else{
                        self.displayAlert("Hata", message: "Ooops! Lütfen tekrar deneyiniz.")
                    }
                })
            })
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let yourVC = segue.destination as? FacebookFriends{
            yourVC.userRelations = self.facebookfriends
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
        
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(_ title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: nil)))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       
    }
    
}
