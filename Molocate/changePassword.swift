//
//  changePassword.swift
//  Molocate
//
//  Created by MellonCorp on 3/10/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class changePasswordd: UIViewController {

    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    @IBAction func backButton(sender: AnyObject) {
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
    }
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var yenitekrar: UITextField!
    @IBOutlet var yeni: UITextField!
    @IBOutlet var eski: UITextField!
    @IBAction func onayButton(sender: AnyObject) {
        
        if yeni.text == yenitekrar.text{
            
            //eski şifre doğru mu kontrol et değilse allert ekle
            //doğruysa yeni şifreyi gönder (yeni yazan)
            
        }
        else{
            //displayAlert("Hata", message: "Yazdığınız şifreler uyuşmuyor, lütfen aynı şifreyi girin.")
            let alertController = UIAlertController(title: "Hata!", message:
                "Yazdığınız şifreler uyuşmuyor, lütfen aynı şifreyi girin.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .Default, handler: { (action) -> Void in
        //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
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
