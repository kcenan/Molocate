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
    var email : UITextField!
    var emailLabel : UILabel!
    var onay : UIButton!
    var message : UILabel!
    var message2 : UILabel!
    @IBOutlet var toolBar: UIToolbar!
    let sendName :String = ""
    @IBOutlet var confirmButton: UIButton!
    
    @IBAction func back(sender: AnyObject) {
        //geri basarsa yeni username olmadığı için üye oluşmamış olucak
    }
    
       override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        
        
        message = UILabel()
        message.frame = CGRectMake(screenSize.width / 2 - 90 , screenSize.height / 4 - 30 , 180, 40)
        message.textColor = swiftColor
        message.font = UIFont(name: "AvenirNext-Regular", size: 18)
        message.text = "HOŞGELDİN!"
        message.textAlignment = .Center
        view.addSubview(message)
        
        message2 = UILabel()
        message2.frame = CGRectMake(screenSize.width / 2 - 125 , screenSize.height / 4 + 10 , 250 , 40)
        message2.textColor = swiftColor
        message2.font = UIFont(name: "AvenirNext-Regular", size: 16)
        message2.text = "Başlamak için son basamak:"
        message2.textAlignment = .Center
        view.addSubview(message2)
        
        
        onay = UIButton()
        onay.frame = CGRectMake(screenSize.width / 2 - 90 ,screenSize.height / 2 + 90 , 180 , 50)
       // onay.titleLabel?.sizeToFit()
        onay.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        onay.contentHorizontalAlignment = .Center
        onay.backgroundColor = swiftColor
        onay.setTitle("Onaylıyorum.", forState: .Normal)
        onay.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size:16)
        onay.addTarget(self, action: #selector(SignUpAdvance.pressedOnay(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        view.addSubview(onay)
        
        usernameLabel = UILabel()
        usernameLabel.frame = CGRectMake(20 , screenSize.height / 4 + 90 , 90 , 40)
        usernameLabel.textColor = swiftColor
        usernameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        usernameLabel.text = "Kullanıcı Adı:"
        usernameLabel.textAlignment = .Right
        view.addSubview(usernameLabel)
        
        
        
        username = UITextField()
        username.frame = CGRectMake(115  , screenSize.height / 4 + 90 , 180, 40 )
        username.textColor = UIColor.blackColor()
        username.keyboardType = .Default
        username.font = UIFont(name: "AvenirNext-Regular", size: 14)
        let border = CALayer()
        let width = CGFloat(1.5)
        border.borderColor = swiftColor.CGColor
        border.frame = CGRect(x: 0, y: username.frame.size.height - width, width:  username.frame.size.width, height: username.frame.size.height )
        border.borderWidth = width
        username.layer.addSublayer(border)
        username.layer.masksToBounds = true
        //burada bize çağatay atanan username i gönderecek onu  yazıcaz
        // a diye atıyorum bunu butonun aksiyonunda çek edicez değişmişse username değiştirme yollıcaz
      
        username.placeholder = "Kullanıcı Adı"
        border.borderWidth = width
        username.layer.addSublayer(border)
        username.textAlignment = .Left
        username.layer.masksToBounds = true
        view.addSubview(username)
        
        self.username.delegate = self
        
        emailLabel = UILabel()
        emailLabel.frame = CGRectMake(20 , screenSize.height / 4 + 140, 90, 40)
        emailLabel.textColor = swiftColor
        emailLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        emailLabel.text = "E-mail:"
        emailLabel.textAlignment = .Right
        view.addSubview(emailLabel)
        
        email = UITextField()
        email.frame = CGRectMake(115  , screenSize.height / 4 + 140 , 180 , 40 )
        email.textColor = UIColor.blackColor()
        email.keyboardType = .EmailAddress
        email.font = UIFont(name: "AvenirNext-Regular", size: 14)
        let border2 = CALayer()
        border2.frame = CGRect(x: 0, y: email.frame.size.height - width, width:  email.frame.size.width , height: email.frame.size.height )
        border2.borderColor = swiftColor.CGColor
        border2.borderWidth = width
        email.layer.addSublayer(border2)
        email.layer.masksToBounds = true
        //burada bize çağatay atanan username i gönderecek onu  yazıcaz
        // a diye atıyorum bunu butonun aksiyonunda çek edicez değişmişse username değiştirme yollıcaz
        
        email.placeholder = "E-Mail"
        email.layer.addSublayer(border2)
        email.textAlignment = .Left
        email.layer.masksToBounds = true
        view.addSubview(email)
        
        
        self.email.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpAdvance.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if(faceMail != "not_valid"){
            email.text = faceMail
        } else {
            
        }
    }
    func pressedOnay(sender: UIButton) {
        
        if username.text?.characters.count < 4 {
            let alertController = UIAlertController(title: "Hata", message:
                "Seçtiğiniz kullanıcı adı 4 ile 20 karakter arasında olmalıdır.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            
            var uname = username.text! as String
            var mail = email.text! as String
            var token = fbToken
            let json = ["access_token": token , "username": uname, "email": mail]
            
            
            do {
                
                let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                
                // create post request
                let url = NSURL(string: "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/account/facebook_login/")!
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
                            
                            
                                //print("dsfasfdsadsfa")
                                
                            if result["username"] != nil {
                                let usernameExist: Bool = (result["username"] as! String == "username_exist")
                                let emailNotValid: Bool = (result["email"] as! String == "not_valid")
                                if (usernameExist && emailNotValid){
                                    self.displayAlert("Dikkat!", message: "Kullanıcı adınız ve e-mailiniz daha önce alındı.")
                                } else {
                                    if usernameExist {
                                        self.displayAlert("Dikkat!", message: "Kullanıcı adı daha önce alındı.")
                                        
                                    } else {
                                        self.displayAlert("Dikkat!", message: "Lütfen e-mailinizi değiştirin.")
                                    }
                                }
                            } else {
                                userToken = result["access_token"] as? String
                                Molocate.getCurrentUser({ (data, response, error) -> () in
                                    
                                })
                            }
//                                self.displayAlert("Hata", message: result["result"] as! String)
//                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                                self.activityIndicator.stopAnimating()
//                                self.activityIndicator.hidesWhenStopped = true
                            
                            
                            
                            
                            
                        } catch {
                            print("Error -> \(error)")
                            
                        }
                        
                    })
                }
                
                
                task.resume()
                
                
                
                
            } catch {
                print(error)
                
                
            }

            
//            if sendName==username.text{
//                //burada username i atamasına tekrar gerek var mı?
//                performSegueWithIdentifier("usernameAfter", sender: .None)
//            }
//            else{
//                // check et username exist mi diye exist değilse database e kaydetip yolla existse alert koy
//                
//                
//                //let alertController = UIAlertController(title: "Üzgünüz", message:
//                //                "Seçtiğiniz kullanıcı adı daha önce alınmış, başka bir kullanıcı adı deneyin", preferredStyle: UIAlertControllerStyle.Alert)
//                //                alertController.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.Default,handler: nil))
//                //
//                //                self.presentViewController(alertController, animated: true, completion: nil)
//                
//                
//            }
        }
        
        
        

        
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == username {
        let maxLength = 20
        let currentString: NSString = username.text!
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
        
            return newString.length <= maxLength
        
        }
        else{
            return true
        }
    }
        override func didReceiveMemoryWarning() {
            
            
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        print("Hoca")
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
