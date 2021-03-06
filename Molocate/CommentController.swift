import UIKit

class commentController: UIViewController,UITableViewDelegate , UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate{
    
    var mentionAreas = [NSRange]()
    var mentionedUsers = [String]()
    var isInTheMentionMode = false
    var mentionModeIndex = 0
    var searchResults = [MoleUser]()
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
//    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var tagView: UITableView!
    @IBOutlet var sendImage: UIImageView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newComment: UITextView!
    var activityIndicator = UIActivityIndicatorView()
    let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initGui()
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        //comments.removeAll()
    }
    
    
    
    func initGui(){
        self.automaticallyAdjustsScrollViewInsets = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.tintColor = UIColor.white
        newComment.text = "Yorumunu buradan yazabilirsin"
        newComment.textColor = UIColor.lightGray
        newComment.layer.cornerRadius = 5
        newComment.layer.borderWidth = 1
        newComment.layer.borderColor = UIColor.white.cgColor
        newComment.returnKeyType = .done
        newComment.delegate = self
        
        tagView.isHidden = true
        tagView.tableFooterView = UIView()
        tagView.layer.zPosition = 10
        tagView.allowsSelection = true
//        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(commentController.dismissKeyboard))
//        self.view.addGestureRecognizer(tap)
        
        sendImage.layer.zPosition = 3
        sendButton.layer.zPosition = 2
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = swiftColor.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(commentController.keyboardNotification(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(commentController.keyboardNotification2(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        tableView.estimatedRowHeight = 68
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        tableView.layer.zPosition = 0
        
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Yorumlar güncelleniyor...")
        self.refreshControl.addTarget(self, action: #selector(commentController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
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
        if self.newComment.text == "Yorumunu buradan yazabilirsin"{
            newComment.text = ""
        }
        self.view.backgroundColor = UIColor.lightGray
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if tagView.isHidden {
            self.view.endEditing(true)
        }
    }
    
    
    
    func refresh(_ sender: AnyObject){
        MolocateVideo.getComments(video_id) { (data, response, error, count, next, previous) in
            DispatchQueue.main.async{
                comments=data
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tagView{
            let cell = searchUsername(style: UITableViewCellStyle.default, reuseIdentifier: "mentionCell")
            
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
                    cell.profilePhoto.sd_setImage(with: searchResults[indexPath.row].profilePic, for: UIControlState.normal)
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
            

        
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! commentCell
            
            cell.username.setTitle(comments[indexPath.row].username, for: UIControlState())
            cell.username.tintColor = swiftColor
        
     
            
            cell.username.contentHorizontalAlignment = .left
            cell.username.tag = indexPath.row
            
           // cell.videoComment.frame = CGRectMake( 55 , 28 , 292 , 26)
            
            cell.comment.customize { label in
                label.textAlignment = .left
                label.numberOfLines = 0
                label.textColor = arkarenk
                label.font = UIFont(name: "AvenirNext-Medium", size: 12.5)
                label.lineBreakMode = .byWordWrapping
                label.mentionColor = swiftColor
                label.hashtagColor = UIColor(red: 90, green: 200, blue: 250)
                
            }
            
            cell.comment.handleMentionTap { userHandle in  self.pressedMention(userHandle, profilePic: URL(string: "")!, isFollowing: false)}

            cell.comment.text = comments[indexPath.row].text
           
    
            
            cell.deleteSupport.tag = indexPath.row
            cell.deleteSupport.addTarget(self, action: #selector(commentController.pressedReport(_:)), for: UIControlEvents.touchUpInside)
    
            cell.profilePhoto.tag = indexPath.row
            cell.profilePhoto.addTarget(self, action: #selector(commentController.pressedUsername(_:)), for: UIControlEvents.touchUpInside )
            
            cell.username.addTarget(self, action: #selector(commentController.pressedUsername(_:)), for: UIControlEvents.touchUpInside)
            
   
            
            if(comments[indexPath.row].photo?.absoluteString != ""){
                cell.profilePhoto.sd_setImage(with: comments[indexPath.row].photo, for: UIControlState.normal, placeholderImage: UIImage(named: "profile")!)
            }else{
                cell.profilePhoto.setImage(UIImage(named: "profile")!, for:
                    UIControlState())
            }
            cell.profilePhoto.layer.borderWidth = 0.1
            cell.profilePhoto.layer.borderColor = UIColor.white.cgColor
            cell.profilePhoto.layer.masksToBounds = false
            cell.profilePhoto.backgroundColor = UIColor.lightGray
            cell.profilePhoto.layoutIfNeeded()
            cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.height/2
            cell.profilePhoto.clipsToBounds = true
            
            return cell
        }
    }
    
    func pressedMention(_ username: String, profilePic: URL, isFollowing:Bool){
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        
        if username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        
        controller.classUser.username = username
        controller.classUser.profilePic = profilePic
        controller.classUser.isFollowing = isFollowing
        
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(username) { (data, response, error) -> () in
            DispatchQueue.main.async{
                //DBG: If it is mine profile?
                
                if data.username != "" {
                    user = data
                    controller.classUser = data
                    controller.RefreshGuiWithData()
                }
                
                //choosedIndex = 0
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tagView{
             return 60
        }else{
            return 68
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tagView {
            return searchResults.count+1
        }else{
            return comments.count
        }

    }
    
    @IBAction func sendButton(_ sender: AnyObject) {
        if !tagView.isHidden{
            updateSearch("")
        }
        
        if(newComment.text.characters.count >= 1 && newComment.text != "Yorumunu buradan yazabilirsin"){
            
            sendButton.isEnabled = false
            
            var mycomment = MoleVideoComment()
            mycomment.text = newComment.text
            mycomment.photo = MoleCurrentUser.profilePic!
            mycomment.username = MoleCurrentUser.username
            mycomment.deletable = true
            newComment.text = ""
         
            comments.append(mycomment)
            tableView.reloadData()
            
            sendButton.isEnabled = true

            MolocateVideo.commentAVideo(video_id, comment: mycomment.text, mentioned_users:  mentionedUsers) { (data, response, error) -> () in
                DispatchQueue.main.async{
                    //self.updateParentController(true)
                    
                    if data != "fail" {
                        if comments.count > 0 {
                            comments[comments.endIndex-1].id = data!
                        }else{
                            //DBG: do somthing
                        }
                    } else {
                        //DBG:display alert
                    }
                    
                }
            }
            
            
        }
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func pressedReport(_ sender: UIButton) {
        
        let buttonRow = sender.tag

        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
        if( (buttonRow < comments.count) && comments[buttonRow].deletable){
            
            let deleteVideo: UIAlertAction = UIAlertAction(title: "Yorumu Sil", style: .default) { action -> Void in
                let index = IndexPath(row: buttonRow, section: 0)
                
                MolocateVideo.deleteAComment(comments[buttonRow].id, completionHandler: { (data, response, error) in
                        DispatchQueue.main.async{
                           // self.updateParentController(false)
                        }
                    
                })
                
                
                
                comments.remove(at: (index as NSIndexPath).row)
                self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
                self.tableView.reloadData()
            }
            
            actionSheetController.addAction(deleteVideo)
        }
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Rapor Et", style: .default) { action -> Void in
        }
        
        actionSheetController.addAction(reportVideo)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    func pressedUsername(_ sender: UIButton) {
        self.parent!.navigationController?.setNavigationBarHidden(false, animated: false)
        let buttonRow = sender.tag
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
     
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        
        if comments[buttonRow].username != MoleCurrentUser.username{
             controller.isItMyProfile  = false
        }else{
             controller.isItMyProfile = true
        }
        
       
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(comments[buttonRow].username) { (data, response, error) -> () in
            DispatchQueue.main.async{
                //DBG: If it is mine profile?
                
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                
                //choosedIndex = 0
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
   
    
    func updateParentController(_ plus: Bool){
        let i = plus ? 1:-1
        
        if(myViewController == "MainController"){
            
        }else if myViewController == "HomeController"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableController.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableController.tableView.reloadRows(
                at: [IndexPath(row: videoIndex, section: 0)], with: UITableViewRowAnimation.left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableController.player1?.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableController.player2?.stop()
            //(navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.player2.stop()
        }else if myViewController == "MyAdded"{
//            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).AVc.videoArray[videoIndex].commentCount += i
//            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).AVc.tableView.reloadRowsAtIndexPaths(
//                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
//            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).AVc.player1.stop()
//            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).AVc.player2.stop()
        }else if myViewController == "MyTagged"{
//            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).BVc.videoArray[videoIndex].commentCount += i
//            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).BVc.tableView.reloadRowsAtIndexPaths(
//                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
//            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).BVc.player1.stop()
//            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).BVc.player2.stop()
//            
        }else if myViewController == "Added"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileUser).AVc.videoArray?[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileUser).AVc.tableView?.reloadRows(
                at: [IndexPath(row: videoIndex, section: 0)], with: UITableViewRowAnimation.left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileUser).AVc.player1?.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileUser).AVc.player2?.stop()
        }else if myViewController == "Tagged"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileUser).BVc.videoArray?[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileUser).BVc.tableView?.reloadRows(
                at: [IndexPath(row: videoIndex, section: 0)], with: UITableViewRowAnimation.left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileUser).BVc.player1?.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileUser).BVc.player2?.stop()
            
        }else if myViewController == "profileVenue"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileVenue).tableController.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileVenue).tableController.tableView.reloadRows(
                at: [IndexPath(row: videoIndex, section: 0)], with: UITableViewRowAnimation.left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileVenue).tableController.player1?.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileVenue).tableController.player2?.stop()
        }else if myViewController == "oneVideo"{
            MoleGlobalVideo.commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! oneVideo).tableView.reloadRows(
                at: [IndexPath(row: videoIndex, section: 0)], with: UITableViewRowAnimation.left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! oneVideo).player.stop()
        }
        
    }


 
    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        
//        let currentText:NSString = textView.text
//        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
//        if updatedText.isEmpty {
//            newComment.text = "Yorumunu buradan yazabilirsin"
//            newComment.textColor = UIColor.lightGrayColor()
//            newComment.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
//            return false
//        }else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
//            textView.text = nil
//            textView.textColor = UIColor.blackColor()
//        }
//        
//        return true
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tagView {
            
         //   let cell = tableView.cellForRowAtIndexPath(indexPath) as! searchUsername
            
            if indexPath.row<searchResults.count {
                
                let username = searchResults[indexPath.row].username
                var captiontext = newComment.attributedText.string
                if mentionAreas[mentionModeIndex].location == 0 {
                    captiontext = captiontext.substring(to: captiontext.characters.index(captiontext.startIndex, offsetBy: mentionAreas[mentionModeIndex].location+1)) + username + " "
                }else{
                    captiontext = captiontext.substring(to: captiontext.characters.index(captiontext.startIndex, offsetBy: mentionAreas[mentionModeIndex].location+2)) + username + " "
                }
                
                
                newComment.attributedText = NSAttributedString(string: captiontext)
                
                newComment.attributedText = NSAttributedString(string: captiontext)
                mentionAreas[mentionModeIndex].length = username.characters.count + 2
                mentionedUsers[mentionModeIndex] = username
                
                textViewDidChange(newComment)
                isInTheMentionMode = false
                tagView.isHidden = true
                searchResults.removeAll()
                
                
            }
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        let new = (textView.attributedText.string as NSString).replacingCharacters(in: range, with: text)
        
        let textRange = NSRange(location: 0, length: new.characters.count )
        
        let mentions = RegexParser.getMentions(fromText: new, range: textRange)
        
        
        mentionAreas.removeAll()
        mentionedUsers.removeAll()
        
        for mention in mentions where mention.range.length > 1{
            //print(mention.range.location)
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
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false;
        }
    
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
        //print("word::",word)
        if word == ""{
            tagView.isHidden = true
            tagView.isUserInteractionEnabled = false
            tableView.isUserInteractionEnabled = true
            searchResults.removeAll()
        }else{
            
            
            MolocateAccount.searchUser(word, completionHandler: { (data, response, error) in
                DispatchQueue.main.async{
                    if data.count > 0 {
                        self.searchResults = data
                        self.tagView.reloadData()
                    }
                }
            })
            tagView.isHidden = false
            tagView.isUserInteractionEnabled = true
            tableView.isUserInteractionEnabled = false
            
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
    
    func keyboardNotification(_ notification: Notification) {
        
        let isShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
        
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomConstraint?.constant = isShowing ? endFrameHeight : 0.0
            
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    func keyboardNotification2(_ notification: Notification) {
        
        let isShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
        
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomConstraint?.constant = isShowing ? endFrameHeight : 0
    
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }


 

}
