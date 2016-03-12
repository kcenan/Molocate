//
//  SignUpAdvance.swift
//  Molocate
//
//  Created by Kagan Cenan on 15.12.2015.
//  Copyright © 2015 MellonApp. All rights reserved.

//


import UIKit

class SignUpAdvance: UIViewController , UITextFieldDelegate {

    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var username : UITextField!
    var usernameLabel : UILabel!
    @IBOutlet var toolBar: UIToolbar!
    let sendName :String = ""
    @IBOutlet var confirmButton: UIButton!
    
    @IBAction func back(sender: AnyObject) {
        //geri basarsa yeni username olmadığı için üye oluşmamış olucak
    }
    @IBAction func confirmButton(sender: AnyObject) {
        
        if username.text?.characters.count < 4 {
            let alertController = UIAlertController(title: "Hata", message:
                "Seçtiğiniz kullanıcı adı 4 ile 20 karakter arasında olmalıdır.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else{
        
            if sendName==username.text{
                //burada username i atamasına tekrar gerek var mı?
                performSegueWithIdentifier("usernameAfter", sender: .None)
            }
            else{
                // check et username exist mi diye exist değilse database e kaydetip yolla existse alert koy
                
                
                //let alertController = UIAlertController(title: "Üzgünüz", message:
//                "Seçtiğiniz kullanıcı adı daha önce alınmış, başka bir kullanıcı adı deneyin", preferredStyle: UIAlertControllerStyle.Alert)
//                alertController.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.Default,handler: nil))
//                
//                self.presentViewController(alertController, animated: true, completion: nil)
                
                
            }
        }
        
       
        
    }
    
       override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        
        usernameLabel = UILabel()
        usernameLabel.frame = CGRectMake(screenSize.width / 2 - 75 , screenSize.height / 4 + 34, 150, 44)
        usernameLabel.textColor = swiftColor
        usernameLabel.font = UIFont(name: "Lato-Regular.tff", size: 14)
        usernameLabel.text = "Kullanıcı Adı"
        usernameLabel.textAlignment = .Center
        view.addSubview(usernameLabel)
        
        username = UITextField()
        username.frame = CGRectMake(screenSize.width / 2 - 90  , screenSize.height / 4 - 22 , 180, 44 )
        username.textColor = swiftColor
        username.keyboardType = .Default
        username.font = UIFont(name: "Lato-Regular.tff", size: 14)
        let border = CALayer()
        let width = CGFloat(2)
        border.borderColor = swiftColor.CGColor
        border.frame = CGRect(x: 0, y: username.frame.size.height - 0.1 , width:  username.frame.size.width, height: username.frame.size.height)
        //burada bize çağatay atanan username i gönderecek onu  yazıcaz
        // a diye atıyorum bunu butonun aksiyonunda çek edicez değişmişse username değiştirme yollıcaz
        var sendName = "kcenan"
        username.text = sendName
        border.borderWidth = width
        username.layer.addSublayer(border)
        username.textAlignment = .Center
        username.layer.masksToBounds = true
        view.addSubview(username)
        
        self.username.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
   
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 20
        let currentString: NSString = textField.text!
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
        
    }
        override func didReceiveMemoryWarning() {
            
            
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
