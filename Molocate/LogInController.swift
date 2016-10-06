//
//  logInController.swift
//  Molocate
//
//  Created by Kagan Cenan on 1.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//
//  logInController.swift
//  Molocate
//
//  Created by Kagan Cenan on 30.05.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class logInController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var toolBar: UIToolbar!
    var loginActive = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
    @IBAction func passwordForgotButton(_ sender: AnyObject) {
        
        //print("user şifreyi unutmuş")
    }
    
    func displayAlert(_ title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .default, handler: { (action) -> Void in
            self.activityIndicator.stopAnimating()
        })))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func loginButton(_ sender: AnyObject) {
        
        
        let uname: String = (username.text?.lowercased())!
        let pwd: String = password.text!
        choosedIndex = 2
        if(MolocateDevice.isConnectedToNetwork()){
        MolocateAccount.Login(uname, password: pwd, completionHandler: { (data, response, error) in
            DispatchQueue.main.async(execute: {
                if( data == "success" ){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "logIn", sender: self)
                    }
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
        }) } else {
            self.displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
        
        

    
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
    
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
   
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        //navigationItem.backBarButtonItem = backItem
        
        view.backgroundColor = swiftColor
        //navigationController?.navigationBar.hidden = true
        username.delegate = self
        password.delegate = self
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.clear.cgColor
        
    
        
        let screenSize: CGRect = UIScreen.main.bounds
        let imageView = UIImageView(image: UIImage(named: "Logo.png"))
        imageView.frame = CGRect(x: (screenSize.width / 2 ) - (screenSize.height * 80), y: 10, width: (screenSize.height  / 9) , height: (screenSize.height  / 9))
        self.view.addSubview(imageView)
        
        if is4s {
        loginButton.frame.origin.y = screenSize.height / 2 + 30
        }
           }
    
  
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    
    
    
    
    //okey
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
