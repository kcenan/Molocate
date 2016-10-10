import UIKit
var mine = false

class profileOther: UIViewController , UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    //true ise kendi false başkası
   
    var leftButton = "side"
    var classUser = MoleUser()
    let AVc :Added =  Added(nibName: "Added", bundle: nil);
    let BVc :Tagged =  Tagged(nibName: "Tagged", bundle: nil);
    let names = ["AYARLAR","PROFİLİ DÜZENLE", "ÇIKIŞ YAP"]
    var isItMyProfile = true
    @IBOutlet var settings: UITableView!
    @IBOutlet var scrollView: UIScrollView!
  
    @IBOutlet weak var ProfileButton: UIButton!
    
    //errormessage: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var addedButton: UIButton!
    @IBOutlet var taggedButton: UIButton!
    @IBOutlet var followingsCount: UIButton!
    @IBOutlet var followersCount: UIButton!
    @IBOutlet var FollowButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
        if UIApplication.shared.isIgnoringInteractionEvents {
             UIApplication.shared.endIgnoringInteractionEvents()
        }
       
    }
    
    func initGui(){
        

       
        if(classUser.isFollowing){
            FollowButton.image = UIImage(named: "unfollow")
        }else if classUser.username == MoleCurrentUser.username{
            FollowButton.image = UIImage(named: "settings")
        }else{
            FollowButton.image = UIImage(named: "follow")
        }
        
        self.navigationItem.title = classUser.username
    

        
        username.text = classUser.username
        followingsCount.setTitle("\(classUser.following_count)", for: UIControlState())
        followersCount.setTitle("\(classUser.follower_count)", for: UIControlState())
        
        
        settings.layer.zPosition = 1
        settings.isHidden = true
        settings.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.width)
        settings.layer.cornerRadius = 0
        settings.tintColor = UIColor.clear
        profilePhoto.layer.borderWidth = 0.5
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = profileBackgroundColor.cgColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.backgroundColor = profileBackgroundColor
        profilePhoto.clipsToBounds = true
        if(classUser.profilePic?.absoluteString != ""){
            profilePhoto.sd_setImage(with: classUser.profilePic)
           
        }else{
            profilePhoto.image = UIImage(named: "profile")!
            ProfileButton.isEnabled = false
        }
        
        addedButton.backgroundColor = swiftColor
        addedButton.setTitleColor(UIColor.white, for: UIControlState())
        addedButton.setTitle("▶︎GÖNDERİ(\(classUser.post_count))", for: UIControlState())
        
        taggedButton.setTitleColor(UIColor.black, for: UIControlState())
        taggedButton.setTitle("@ETİKET(\(classUser.tag_count))", for: UIControlState())
        taggedButton.backgroundColor = swiftColor3
        
    
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        
  
        scrollView.frame.origin.y = 190
        scrollView.frame.size.height = MolocateDevice.size.height - 190
        
        AVc.classUser = classUser
        AVc.isItMyProfile = isItMyProfile
        AVc.view.frame.origin.x = 0
        AVc.view.frame.origin.y = 0
        AVc.view.frame.size.width = MolocateDevice.size.width
        AVc.view.frame.size.height = scrollView.frame.height
        self.addChildViewController(AVc);
        AVc.didMove(toParentViewController: self)
        
        var adminFrame :CGRect = AVc.view.frame;
        adminFrame.origin.x = MolocateDevice.size.width
        var deneme :CGRect = AVc.view.frame;
        deneme.origin.x = 0
        
        BVc.classUser = classUser
        BVc.isItMyProfile = isItMyProfile
        BVc.view.frame = adminFrame;
        self.addChildViewController(BVc);
        BVc.didMove(toParentViewController: self)
        
        scrollView.setContentOffset(deneme.origin, animated: true)
        scrollView.addSubview(AVc.view);
        scrollView.addSubview(BVc.view);
        scrollWidth = MolocateDevice.size.width*2
        scrollView.contentSize.width = scrollWidth
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
    }
    
    func RefreshGuiWithData(){
        addedButton.setTitle("▶︎GÖNDERİ(\(classUser.post_count))", for: UIControlState())
        taggedButton.setTitle("@ETİKET(\(classUser.tag_count))", for: UIControlState())
       
        if(classUser.profilePic?.absoluteString != ""){
            profilePhoto.sd_setImage(with: classUser.profilePic)
            ProfileButton.isEnabled = true
            
        }else{
            profilePhoto.image = UIImage(named: "profile")!
            ProfileButton.isEnabled = false
        }
        
  
            if(classUser.isFollowing){
                FollowButton.image = UIImage(named: "unfollow")
            }else if classUser.username == MoleCurrentUser.username{
                FollowButton.image = UIImage(named: "settings")
            }else{
                FollowButton.image = UIImage(named: "follow")
            }
     
        username.text = classUser.username
        
        followingsCount.setTitle("\(classUser.following_count)", for: UIControlState())
        followersCount.setTitle("\(classUser.follower_count)", for: UIControlState())
        
        
        AVc.classUser = classUser
        AVc.isItMyProfile = self.isItMyProfile
        BVc.isItMyProfile = self.isItMyProfile
        BVc.classUser = classUser
        AVc.getData()
        BVc.getData()

    }
    
    @IBAction func addedButton(_ sender: AnyObject) {
        var a :CGRect = AVc.view.frame;
        a.origin.x = 0
        scrollView.setContentOffset(a.origin, animated: true)
    }
    
    @IBAction func taggedButton(_ sender: AnyObject) {
        let b :CGRect = BVc.view.frame;
        scrollView.setContentOffset(b.origin, animated: true)
    }
    @IBAction func followingsButton(_ sender: AnyObject) {
        AVc.player2.stop()
        AVc.player1.stop()
        BVc.player2.stop()
        BVc.player1.stop()
        
        let controller:Followers = self.storyboard!.instantiateViewController(withIdentifier: "Followers") as! Followers
        controller.classUser = classUser
        controller.followersclicked = false
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func FollowButton(_ sender: AnyObject) {
      
        if(classUser.username == MoleCurrentUser.username){
            showTable() //Settings table
            scrollView.isUserInteractionEnabled = false // can be apply for search in maincontroller
        }else {
            if !classUser.isFollowing{
                FollowButton.image = UIImage(named: "unfollow")
                classUser.isFollowing = true
                classUser.follower_count+=1
                MoleCurrentUser.following_count += 1
                followersCount.setTitle("\(self.classUser.follower_count)", for: UIControlState())
                MolocateAccount.follow(classUser.username, completionHandler: { (data, response, error) -> () in
                    //IMP:if request is failed delete change
                })
            }else {
                let actionSheetController: UIAlertController = UIAlertController(title: "Takibi bırakmak istediğine emin misin?", message: nil, preferredStyle: .actionSheet)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .cancel) { action -> Void in}
                actionSheetController.addAction(cancelAction)
               
                let takePictureAction: UIAlertAction = UIAlertAction(title: "Takibi Bırak", style: .default)
                { action -> Void in
                    
                    self.FollowButton.image = UIImage(named: "follow")
                    self.classUser.isFollowing = false
                    self.classUser.follower_count -= 1
                    self.followersCount.setTitle("\(self.classUser.follower_count)", for: UIControlState())
                    MoleCurrentUser.following_count -= 1
                    
                    MolocateAccount.unfollow(self.classUser.username, completionHandler: { (data, response, error) -> () in
                        //IMP:if request is failed delete change
                        if let parentVC = self.parent {
                            if let parentVC = parentVC as? Followers{
                                MolocateAccount.getFollowings(username: MoleCurrentUser.username, completionHandler: { (data, response, error, count, next, previous) in
                                    DispatchQueue.main.async {
                                        parentVC.userRelations = data
                                        parentVC.myTable.reloadData()
                                    }
                                })
                            }
                        }
                    })
                }
                
                actionSheetController.addAction(takePictureAction)
                actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
                self.present(actionSheetController, animated: true, completion: nil)
            }
            
        }
    }
    

       
    @IBAction func followersButton(_ sender: AnyObject) {
        AVc.player2.stop()
        AVc.player1.stop()
        BVc.player2.stop()
        BVc.player1.stop()
        let controller:Followers = self.storyboard!.instantiateViewController(withIdentifier: "Followers") as! Followers
        controller.classUser = classUser
        controller.followersclicked = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x < BVc.view.frame.origin.x/2){
            
            BVc.player1.stop()
            BVc.player2.stop()
            AVc.player1.playFromCurrentTime()
            AVc.player2.playFromCurrentTime()
            if(classUser.post_count != 0 || classUser.tag_count != 0 ) {
                //errormessage.hidden = true
            }
            addedButton.backgroundColor = swiftColor
            taggedButton.backgroundColor = swiftColor3
            addedButton.titleLabel?.textColor = UIColor.white
            taggedButton.titleLabel?.textColor = UIColor.black
        }
        else{
            BVc.player1.playFromBeginning()
            BVc.player2.playFromCurrentTime()
            AVc.player1.stop()
            AVc.player2.stop()
            if(classUser.tag_count != 0  && classUser.post_count != 0) {
                //errormessage.hidden = true
            }
            addedButton.backgroundColor = swiftColor3
            taggedButton.backgroundColor = swiftColor
            taggedButton.titleLabel?.textColor = UIColor.white
            addedButton.titleLabel?.textColor = UIColor.black
            
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.addedButton.isEnabled = true
        self.taggedButton.isEnabled = true
        self.scrollView.isScrollEnabled = true
        //???What is doing that animation
        if((indexPath as NSIndexPath).row == 0){
            UIView.animate(withDuration: 0.75, animations: { () -> Void in
                self.scrollView.isUserInteractionEnabled = true
                self.scrollView.alpha = 1
                self.settings.isHidden = true
             
                self.navigationController?.isNavigationBarHidden = false


            }) 
        }
        if (indexPath as NSIndexPath).row == 1 {
            self.scrollView.isUserInteractionEnabled = true
            self.scrollView.alpha = 1
            self.performSegue(withIdentifier: "goEditProfile", sender: self)
            self.settings.isHidden = true
        }
        if (indexPath as NSIndexPath).row == 2 {
            MolocateAccount.unregisterDevice({ (data, response, error) in
            })
            UserDefaults.standard.set(nil, forKey: "userToken")
            sideClicked = false
            profileOn = 0
            category = "All"
            comments = [MoleVideoComment]()
            video_id = ""
            user = MoleUser()
            videoIndex = 0
            isUploaded = true
            choosedIndex = 2
            frame = CGRect()
            MoleCurrentUser = MoleUser()
            MoleUserToken = nil
            isRegistered = false
            MoleGlobalVideo = nil
          //  GlobalVideoUploadRequest = nil
           
            //navigationın düzelmesi sonrası bu böyle olucak
            //self.parentViewController!.parentViewController!.performSegueWithIdentifier("logOut", sender: self)
            self.parent!.parent!.performSegue(withIdentifier: "logout", sender: self)
        }
        
        
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0{
            return 90
        }
        else{
            return 60
        }
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = optionCell(style: UITableViewCellStyle.default, reuseIdentifier: "myIdentifier")
        
        if (indexPath as NSIndexPath).row == 0 {
            cell.nameOption.frame = CGRect(x: MolocateDevice.size.width / 2 - 50, y: 40 , width: 100, height: 30)
            cell.nameOption.textAlignment = .center
            cell.nameOption.textColor = UIColor.black
            cell.arrow.isHidden = true
            cell.cancelLabel.isHidden = false
        }else {
            cell.cancelLabel.isHidden = true
        }
        cell.nameOption.text = names[(indexPath as NSIndexPath).row]
        cell.backgroundColor = UIColor.white
        
        return cell
        
    }
    @IBAction func pressedPhoto(_ sender: AnyObject) {
        let controller:onePhoto = self.storyboard!.instantiateViewController(withIdentifier: "onePhoto") as! onePhoto
        controller.classUser = classUser
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func showTable(){
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.navigationController?.isNavigationBarHidden = true
            self.addedButton.isEnabled = false
            self.taggedButton.isEnabled = false
            self.scrollView.isScrollEnabled = false
            self.settings.isHidden = false
            self.settings.frame = CGRect(x: self.view.frame.origin.x,y: self.view.frame.origin.y,width: self.view.frame.width,height: self.view.frame.size.width)
            self.scrollView.alpha = 0.4
        }) 
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
            navigationController?.isNavigationBarHidden = false
           (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = false
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        AVc.player1.stop()
        AVc.player2.stop()
        BVc.player1.stop()
        BVc.player2.stop()
    }
    

    
}
