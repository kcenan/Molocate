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
    
    //done da verileri yolla backde vazgeçsin yollama
    @IBAction func done(sender: AnyObject) {
        CaptionText = textField.text!
        (self.parentViewController as! capturePreviewController).caption.setTitle(CaptionText, forState: .Normal)
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            
        }
        
    }
    var dengueSymptoms = ["ali","veli","hüseyin","mehmet"]
    var arraynumber = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.layer.borderColor = UIColor.blackColor().CGColor
        textField.layer.borderWidth = 1.0;
        textField.layer.cornerRadius = 5.0;
        textField.keyboardDismissMode = .Interactive
        textField.keyboardType = .Default
        
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
        
        textField.text = "Yorumunu buraya ekleyebilirsin..."
        textField.textColor = UIColor.lightGrayColor()
        textField.returnKeyType = .Done
       // let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Yorumunu buraya ekleyebilirsin..."
            textView.textColor = UIColor.lightGrayColor()
        }
        CaptionText = textField.text
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    var numbers = [Int]()
    var checked = [Bool]() // Have an array equal to the number of cells in your table
    
    
  
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dengueSymptoms.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.font = UIFont(name: "Lato-Regular", size: 16)
        //cell.textLabel?.frame.origin.x = 200
       // self.tableView.indentationLevel = 50
       // cell.textLabel?.frame.origin.x = 200
        
        // Configure the cell...insert the special characters using edit > emoji on the menu
        cell.textLabel?.text = "◻️         " + dengueSymptoms[indexPath.row]
        return cell
    
    
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // get the cell and text of the tapped row
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let text = cell!.textLabel!.text!
        
       // cell?.textLabel!.font = UIFont(name: UIFont.fontNamesForFamilyName("Lato-Bold.ttf") , size: 20)
        
        // get the first character
        let index = text.startIndex.advancedBy(1)
        let firstChar = text.substringToIndex(index)
        
        // compare the first character
        let newChar: String
        let checkedSymptom: Bool
        
        // insert the special characters using edit > emoji on the menu
        // this is where the toggle magic happens!
        if firstChar == "◻️" {
            newChar = "✅         "
            checkedSymptom = true
            numbers.append(indexPath.row)
            print(numbers)
           
           
        } else {
            newChar = "◻️         "
            checkedSymptom = false
            var xAppears = false
            
            for number in numbers {
                if number == indexPath.row {
                    xAppears = true
                }
            }
            
            if xAppears {
                print("yes")
                let indexOfA = numbers.indexOf(indexPath.row)
                numbers.removeAtIndex(indexOfA!)
            } else {
                print("no")
            }
            print(numbers)
        }
        
        // change the cell and text of the tapped row with the new "checkbox"
        cell!.textLabel!.text = newChar + " " + dengueSymptoms[indexPath.row]
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
    func textViewShouldReturn(textField: UITextField!) -> Bool {
    textField.resignFirstResponder()
    return true
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
