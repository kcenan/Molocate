//
//  tagComment.swift
//  Molocate
//
//  Created by Kagan Cenan on 16.03.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class tagComment: UIViewController, UITextViewDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextView!
    @IBOutlet var toolBar: UIToolbar!
    
    
    @IBAction func done(sender: AnyObject) {
    }
    
    @IBAction func backButton(sender: AnyObject) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.layer.borderColor = UIColor.blackColor().CGColor
        textField.layer.borderWidth = 1.0;
        textField.layer.cornerRadius = 5.0;
        
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
   
    func dismissKeyboard() {
        view.endEditing(true)
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 300
        let currentString: NSString = textField.text!
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: currentString as String)
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
