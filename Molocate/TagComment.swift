//  tagComment.swift
//  Molocate


import UIKit

class tagComment: UIViewController, UITextViewDelegate {

    var relationNextUrl: String?
    var userRelations = MoleUserRelations()
    var numbers = [Int]()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextView!
    @IBOutlet var toolBar: UIToolbar!

    //done da verileri yolla backde vazgeçsin yollama
    @IBAction func done(_ sender: AnyObject) {
        CaptionText = textField.text!
        let parent =  (self.parent as! capturePreviewController)
        
        var textstring = " "
        
        for i in numbers{
            parent.taggedUsers.append(userRelations.relations[i].username)
            textstring +=  "@" + userRelations.relations[i].username
        }
        
       
        
        var multipleAttributes2 = [String : NSObject]()
        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 14)
        multipleAttributes2[NSForegroundColorAttributeName] = UIColor.black
        
        let commentext = NSMutableAttributedString(string: CaptionText, attributes:  multipleAttributes2)
        
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSForegroundColorAttributeName] = swiftColor2
        multipleAttributes[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 14)
        
        let tags =  NSAttributedString(string: textstring, attributes: multipleAttributes)
        
        commentext.append(tags)
        parent.caption.setAttributedTitle(commentext, for: UIControlState())
        parent.numbers = numbers
        
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    var arraynumber = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0;
        textField.layer.cornerRadius = 5.0;
        textField.keyboardDismissMode = .interactive
        textField.keyboardType = .default
        
        toolBar.barTintColor = swiftColor
        toolBar.isTranslucent = false
        toolBar.clipsToBounds = true
        
        if(CaptionText == "Yorum ve arkadaş ekle") {
            textField.text = "Yorum ve arkadaş ekle"
        }else{
            textField.text = CaptionText
        }
        textField.textColor = UIColor.lightGray
        textField.returnKeyType = .done
        
        MolocateAccount.getFollowers(username:MoleCurrentUser.username) { (data, response, error, count, next, previous) -> () in
             DispatchQueue.main.async{
                self.relationNextUrl = next
                self.userRelations = data
                self.tableView.reloadData()
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel!.font = UIFont(name: "Lato-Regular", size: 16)
        
        if numbers.contains((indexPath as NSIndexPath).row) {
        cell.textLabel?.text = "⚫         " + userRelations.relations[(indexPath as NSIndexPath).row].username
        }else{
        cell.textLabel?.text = "⚪         " + userRelations.relations[(indexPath as NSIndexPath).row].username
        }
            return cell
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if(((indexPath as NSIndexPath).row%50 == 35)&&(relationNextUrl != nil)){
            MolocateAccount.getFollowers(relationNextUrl!, username: MoleCurrentUser.username, completionHandler: { (data, response, error, count, next, previous) in
                if next != nil {
                    self.relationNextUrl = next!
                }
                DispatchQueue.main.async{
                    for item in data.relations{
                        self.userRelations.relations.append(item)
                        let newIndexPath = IndexPath(row: self.userRelations.relations.count-1, section: 0)
                        tableView.insertRows(at: [newIndexPath], with: .bottom)
                        
                    }
                }
            })
   
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        // get the cell and text of the tapped row
        let cell = self.tableView.cellForRow(at: indexPath)
        let text = cell!.textLabel!.text!
        
       // cell?.textLabel!.font = UIFont(name: UIFont.fontNamesForFamilyName("Lato-Bold.ttf") , size: 20)
        
        // get the first character
        let index = text.characters.index(text.startIndex, offsetBy: 1)
        let firstChar = text.substring(to: index)
        
        // compare the first character
        let newChar: String
        //let checkedSymptom: Bool
        
        // insert the special characters using edit > emoji on the menu
        // this is where the toggle magic happens!
        if firstChar == "⚪" {
            newChar = "⚫         "
           //checkedSymptom = true
            numbers.append((indexPath as NSIndexPath).row)
            //print(numbers)
           
           
        } else {
            newChar = "⚪         "
            //let checkedSymptom = false
            var xAppears = false
            
            for number in numbers {
                if number == (indexPath as NSIndexPath).row {
                    xAppears = true
                }
            }
            
            if xAppears {
                //print("yes")
                let indexOfA = numbers.index(of: (indexPath as NSIndexPath).row)
                numbers.remove(at: indexOfA!)
            } else {
                //print("no")
            }
            //print(numbers)
        }
        
        // change the cell and text of the tapped row with the new "checkbox"
        cell!.textLabel!.text = newChar + " " + userRelations.relations[(indexPath as NSIndexPath).row].username
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ""
            textView.textColor = UIColor.lightGray
        }
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRelations.relations.count
    }
    
    func textViewShouldReturn(_ textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 120
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: currentString as String) as NSString
        return newString.length <= maxLength
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    

 

}
