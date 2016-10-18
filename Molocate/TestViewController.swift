//
//  TestViewController.swift
//  Molocate
//
//  Created by Ekin Akyürek on 30/06/16.
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class TestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{
    
    @IBOutlet var captionView: UITextView!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var mentionTable: UITableView!
    @IBOutlet var photoHeightLayoutConstraint: NSLayoutConstraint?
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    var mentionAreas = [NSRange]()
    var mentionedUsers = [String]()
    var isInTheMentionMode = false
    var mentionModeIndex = 0
    var searchResults = [MoleUser]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MoleCurrentUser = MoleUser()
        MoleUserToken = "91cdabf16a61915bd99c7403b3a3c2c08fdf9be7"
        captionView.delegate = self
        captionView.layer.borderColor = UIColor.blue.cgColor
        captionView.layer.borderWidth = 1.0;
        captionView.layer.cornerRadius = 5.0;
        mentionTable.isHidden = true
        mentionTable.tableFooterView = UIView()
        profilePhoto.backgroundColor = UIColor.lightGray
        profilePhoto.image = UIImage(named: "profile")
        self.view.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(self.keyboardNotification(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                                         object: nil)
        
        //        let image = UIImage(named: "logoVectorel")
        //        var fileData: NSData = UIImageJPEGRepresentation(image!, 0.5)!
        //
        //
        //        let json = [
        //            "video_id": "test_id",
        //            "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/testurl",
        //            "caption": "test_caption",
        //            "category": "test_category",
        //            "tagged_users": ["test_user1","test_user2"],
        //            "location": [
        //                [
        //                    "id": "location_id",
        //                    "latitude": "latitude",
        //                    "longitude": "longitude",
        //                    "name": "name",
        //                    "address": "address"
        //                ]
        //            ]
        //        ]
        //
        //
        //        S3Upload.sendThumbnailandData(fileData, info: json) { (data, thumbnailUrl, response, error) in
        //
        //        }
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func keyboardNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame?.origin.y >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
                self.photoHeightLayoutConstraint?.constant = 10.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
                self.photoHeightLayoutConstraint?.constant = endFrame?.size.height ?? 10.0
                
            }
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let attributed = NSMutableAttributedString(string: textView.text)
        
        for mention in mentionAreas {
            attributed.addAttributes([NSForegroundColorAttributeName: swiftColor], range: mention)
        }
        textView.attributedText = attributed
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.backgroundColor = UIColor.white
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.view.backgroundColor = UIColor.lightGray
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        let new = (textView.attributedText.string as NSString).replacingCharacters(in: range, with: text)
        
        let textRange = NSRange(location: 0, length: new.characters.count )
        
        let mentions = RegexParser.getMentions(fromText: new, range: textRange)
        
        
        mentionAreas.removeAll()
        mentionedUsers.removeAll()
        
        for mention in mentions where mention.range.length > 1{
            print(mention.range.location)
            if mention.range.length > 2 {
                
                var word = new.substring(with:mention.range.location+1..<mention.range.location + mention.range.length-1)
                
                if word.hasPrefix("@") {
                    word.remove(at: word.startIndex)
                }
                
                mentionedUsers.append(word)
                mentionAreas.append(mention.range)
            }else if mention.range.location == 0{
                
                // print("mentionn range location")
                var word = new.substring(with:mention.range.location..<mention.range.location + mention.range.length-1)
                
                if word.hasPrefix("@") {
                    word.remove(at: word.startIndex)
                }
                
                mentionedUsers.append(word)
                mentionAreas.append(mention.range)
            }
            
        }
        
        let info = isTheRangeInMentionZone(range, text: text)
        
        if info.0{
            isInTheMentionMode = true
            mentionModeIndex = info.1
            updateSearch(mentionedUsers[mentionModeIndex])
        }else{
            isInTheMentionMode = false
            mentionModeIndex = 0
            updateSearch("")
        }
        
        //
        //
        //            //mention mode da iken silme islemi yaptigimizda @ isaretini sildik mi
        //        if isInTheMentionMode && text == "" && range.location<mentionAreas[mentionModeIndex].location{
        //            isInTheMentionMode=false
        //            mentionAreas.removeAtIndex(mentionModeIndex)
        //            mentionModeIndex = 0
        //            updateSearch("")
        //            //mentiondayken silme islemi yapip @ tayi gecmediyse
        //        }else if isInTheMentionMode && text == "" && range.location >= mentionAreas[mentionModeIndex].location{
        //            mentionAreas[mentionModeIndex].length =  range.location - mentionAreas[mentionModeIndex].location
        //            let current = textView.text as NSString
        //            let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //            updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //            //mention moddayken kelime girip bosluga bastiysa ya da table dan username sectiyse
        //        }else if isInTheMentionMode  && text.characters.count>0 && text[text.characters.count-1]==" " {
        //            isInTheMentionMode = false
        //            mentionModeIndex = 0
        //            updateSearch("")
        //            //Captionın başına @ ya da ortasinda _@ girildigi durumu tespit ediyoruz
        //        }else if isInTheMentionMode && text.characters.count>0{
        //            mentionAreas[mentionModeIndex].length = range.location - mentionAreas[mentionModeIndex].location+1
        //            let current = textView.text as NSString
        //            let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //            updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //        }else if !isInTheMentionMode && range.length==0 && text == "@" && (textView.text.characters.count == 0 || textView.text[textView.text.characters.count-1]==" "){
        //
        //            var newMention = NSRange()
        //            newMention.length = 0
        //            newMention.location = textView.text.characters.count+1
        //            mentionAreas.append(newMention)
        //
        //            isInTheMentionMode = true
        //            mentionModeIndex = mentionAreas.endIndex-1
        //
        //        }else if !isInTheMentionMode{
        //            let info = isTheRangeInMentionZone(range)
        //            if info.0{
        //                isInTheMentionMode = true
        //                mentionModeIndex = info.1
        //                mentionAreas[mentionModeIndex].length = range.location - mentionAreas[mentionModeIndex].location
        //
        //                let current = textView.text as NSString
        //                let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //                updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //            }
        //        }
        
        //character limit
        return text.characters.count+(text.characters.count-range.length) <= 140
    }
    
    func isTheRangeInMentionZone(_ range: NSRange, text: String) -> (Bool, Int){
        for i in 0..<mentionAreas.count{
            let mention = mentionAreas[i]
            if text != "" {
                if mention.location <= range.location && mention.location+mention.length > range.location{
                    return (true, i)
                }
            }else{
                if mention.location <= range.location && mention.location+mention.length >= range.location{
                    return (true, i)
                }
            }
        }
        return (false,0)
    }
    
    func updateSearch(_ word: String){
        print("word::",word)
        if word == ""{
            mentionTable.isHidden = true
            searchResults.removeAll()
        }else{
            
            
            MolocateAccount.searchUser(word, completionHandler: { (data, response, error) in
                DispatchQueue.main.async{
                    if data.count > 0 {
                        self.searchResults = data
                        self.mentionTable.reloadData()
                    }
                }
            })
            mentionTable.isHidden = false
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count+1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchUsername(style: UITableViewCellStyle.default, reuseIdentifier: "mention")
        
        if indexPath.row < searchResults.count {
            cell.followButton.isHidden = true
            cell.usernameLabel.text = "@\(searchResults[indexPath.row].username)"
            if searchResults[indexPath.row].first_name == "" {
                cell.nameLabel.text = "\(searchResults[indexPath.row].username)"
            }
            else{
                cell.nameLabel.text = "\(searchResults[indexPath.row].first_name) \(searchResults[indexPath.row].last_name)"
            }
            if(searchResults[indexPath.row].profilePic?.absoluteString != ""){
                cell.profilePhoto.sd_setImage(with: searchResults[indexPath.row].profilePic, for: .normal)
            }else{
                cell.profilePhoto.setImage(UIImage(named: "profile"), for: UIControlState())
            }
            
            cell.profilePhoto.addTarget(self, action: #selector(MainController.pressedProfileSearch(_:)), for: UIControlEvents.touchUpInside)
            //cell.followButton.addTarget(self, action: Selector("pressedFollowSearch"), forControlEvents: .TouchUpInside)
            cell.followButton.tag = indexPath.row
            cell.profilePhoto.tag = indexPath.row
            
            return cell
            
        }else{
            cell.usernameLabel.text = "Kullanicilar araniyor"
            cell.followButton.isHidden = true
            cell.profilePhoto.isHidden = true
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row<searchResults.count {
            
            let username = searchResults[indexPath.row].username
            var captiontext = captionView.attributedText.string
            if mentionAreas[mentionModeIndex].location == 0 {
                captiontext = captiontext.substring(to: captiontext.characters.index(captiontext.startIndex, offsetBy: mentionAreas[mentionModeIndex].location+1)) + username + " "
            }else{
                captiontext = captiontext.substring(to: captiontext.characters.index(captiontext.startIndex, offsetBy: mentionAreas[mentionModeIndex].location+2)) + username + " "
            }
            
            
            captionView.attributedText = NSAttributedString(string: captiontext)
            mentionAreas[mentionModeIndex].length = username.characters.count + 2
            mentionedUsers[mentionModeIndex] = username
            
            textViewDidChange(captionView)
            isInTheMentionMode = false
            mentionTable.isHidden = true
            searchResults.removeAll()
            
         
         
            
            
        }
        
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
