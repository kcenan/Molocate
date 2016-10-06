//
//  changePassword.swift
//  Molocate
//
//  Created by MellonCorp on 3/10/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

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


class changePasswordd: UIViewController {

    let screenSize: CGRect = UIScreen.main.bounds
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func backButton(_ sender: AnyObject) {
        
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
    }
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var yenitekrar: UITextField!
    @IBOutlet var yeni: UITextField!
    @IBOutlet var eski: UITextField!
    @IBAction func onayButton(_ sender: UIButton) {
        activityIndicator.frame = sender.frame
        activityIndicator.center = sender.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        sender.isHidden = true
        if yeni.text == yenitekrar.text && yeni.text?.characters.count > 3 && yeni.text?.characters.count < 20{
          
            MolocateAccount.changePassword(eski.text!, new_password: yeni.text!, completionHandler: { (data, response, error) in
                DispatchQueue.main.async { () -> Void in
                sender.isHidden = false
                self.activityIndicator.stopAnimating()
                if data == "password_changed" {
                    
                    self.displayAlert("Tamam", message: "Parolanızı başarıyla değiştiridiniz")
                    
                }else if data == "password_wrong"{
                    self.displayAlert("Tamam", message: "Eski parolanızı yanlış girdiniz")
                 
                    
                }else{
                    self.displayAlert("Tamam", message: "Paralo değiştirmede bir hata oluştu!")
                
                }
                }
            })
            
        }
        else{
            sender.isHidden = false
            self.activityIndicator.stopAnimating()
            //displayAlert("Hata", message: "Yazdığınız şifreler uyuşmuyor, lütfen aynı şifreyi girin.")
            let alertController = UIAlertController(title: "Hata!", message:
                "Yazdığınız şifreler uyuşmuyor ve ya şifreniz çok kısa", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .default, handler: { (action) -> Void in
        //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.toolBar.clipsToBounds = true
//        self.toolBar.translucent = false
//        self.toolBar.barTintColor = swiftColor
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
