//
//  commentController.swift
//  Molocate
//
//  Created by MellonCorp on 3/15/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class commentController: UIViewController,UITableViewDelegate , UITableViewDataSource, UITextViewDelegate{

    
    //bu viewda commentin yazısı arttıkça büyümesi düzenlenicek
    
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
      
        self.removeFromParentViewController()
    }
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func sendButton(sender: AnyObject) {
        var mycomment = comment()
        mycomment.text = newComment.text
        mycomment.photo = currentUser.profilePic
        mycomment.username = currentUser.username
        comments.append(mycomment)
        tableView.reloadData()
        Molocate.commentAVideo(video_id, comment: newComment.text) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                 self.newComment.text = ""
                (self.parentViewController as! MainController).videoArray[videoIndex].commentCount += 1
                (self.parentViewController as! MainController).tableView.reloadRowsAtIndexPaths(
                    [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            }
        }
    }
    
    @IBOutlet var newComment: UITextView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        newComment.text = "Yorumunu buradan yazabilirsin"
        newComment.textColor = UIColor.lightGrayColor()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
       // newComment.becomeFirstResponder()
        
//        newComment.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
        tableView.estimatedRowHeight = 68
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardNotification2:"), name:UIKeyboardWillHideNotification, object: nil);
        //topConstraint.priority = 999
        self.sendButton.layer.zPosition = 3
        self.newComment.layer.zPosition = 2
        self.tableView.layer.zPosition = 1
        self.newComment.returnKeyType = .Done
      

     
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textViewShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func keyboardNotification(notification: NSNotification) {
        
        let isShowing = notification.name == UIKeyboardWillShowNotification
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomConstraint?.constant = isShowing ? endFrameHeight : 0.0
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            
            
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    func keyboardNotification2(notification: NSNotification) {
        
        let isShowing = notification.name == UIKeyboardWillShowNotification
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomConstraint?.constant = isShowing ? endFrameHeight : 0
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    

    

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        if updatedText.isEmpty {
            newComment.text = "Yorumunu buradan yazabilirsin"
            newComment.textColor = UIColor.lightGrayColor()
            newComment.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            return false
        }
    
           
        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if self.newComment.text == "Yorumunu buradan yazabilirsin"{
        newComment.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! commentCell
    
        cell.username.setTitle(comments[indexPath.row].username, forState: .Normal)
        cell.comment.text = comments[indexPath.row].text
        cell.username.contentHorizontalAlignment = .Left
        cell.username.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside )
        cell.profilePhoto.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside )
        if(comments[indexPath.row].photo.absoluteString != ""){
            cell.profilePhoto.setBackgroundImage(UIImage(named: "profilepic.png")!, forState:
                UIControlState.Normal)
            
            cell.profilePhoto.sd_setImageWithURL(comments[indexPath.row].photo, forState: UIControlState.Normal)
//            
//            Molocate.getDataFromUrl(comments[indexPath.row].photo, completion: { (data, response, error) -> Void in
//                dispatch_async(dispatch_get_main_queue()){
//                    
//                    cell.profilePhoto.setBackgroundImage(UIImage(data: data!)!, forState:
//                        UIControlState.Normal)
//                    
//                }
//            })
            //photo.image = UIImage(data: data!)!
        }else{
            cell.profilePhoto.setBackgroundImage(UIImage(named: "profilepic.png")!, forState:
                UIControlState.Normal)
        }
        return cell
    }
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        
        Molocate.getUser(comments[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                //controller.ANYPROPERTY=THEVALUE // If you want to pass value
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                controller.username.text = data.username
                controller.followingsCount.setTitle("\(data.following_count)", forState: .Normal)
                controller.followersCount.setTitle("\(data.follower_count)", forState: .Normal)
            }
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        comments.removeAll()
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
