import UIKit

class Followers: UIViewController ,  UITableViewDataSource, UITableViewDelegate{
    
    var activityIndicator = UIActivityIndicatorView()
    var followerCount = 0
    var followingCount = 0
    var classUser = MoleUser()
    var classPlace = MolePlace()
    var userRelations = MoleUserRelations()
    var myTable: UITableView!
    var follower = true
    var relationNextUrl = ""
    var followersclicked: Bool = true
    let refreshControl: UIRefreshControl = UIRefreshControl()
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet var toolBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
        getData(followersclicked, userOrClass:  classPlace.name == "" ? true:false )
    }
    
    func initGui(){
        
        self.navigationController?.navigationBar.isHidden = false
        
        myTable =   UITableView()
        myTable.frame =  CGRect(x: 0, y: 0, width: MolocateDevice.size.width, height: MolocateDevice.size.height);
        myTable.tableFooterView = UIView()
        myTable.allowsSelection = true
        myTable.delegate      =   self
        myTable.dataSource    =   self
        self.view.addSubview(myTable)

        if followersclicked {
            navigationController?.topViewController?.title = "Takipçi"
            self.refreshControl.attributedTitle = NSAttributedString(string: "Takipçileriniz güncelleniyor...")
        }else{
            self.refreshControl.attributedTitle = NSAttributedString(string: "Takip listeniz güncelleniyor...")
            navigationController?.topViewController?.title = "Takip"
            
        }
        
   
        self.refreshControl.addTarget(self, action: #selector(NotificationsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.myTable.addSubview(refreshControl)
        
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    
    
    func refresh(_ sender: AnyObject){
         getData(followersclicked, userOrClass:  classPlace.name == "" ? true:false )
    }
    func getData(_ followers:Bool, userOrClass: Bool){
        
        if followers {
            if userOrClass{
                MolocateAccount.getFollowers(username: classUser.username) { (data, response, error, count, next, previous) -> () in
                    if next != nil {
                        self.relationNextUrl = next!
                    }
                    DispatchQueue.main.async{
                        self.userRelations = data
                        self.myTable.reloadData()
                        self.classUser.follower_count = data.totalCount
                        if self.refreshControl.isRefreshing{
                            self.refreshControl.endRefreshing()
                        }
                    }
                    
                }
            }else{
                MolocatePlace.getFollowers(placeId: thePlace.id) { (data, response, error, count, next, previous) -> () in
                    if next != nil {
                        self.relationNextUrl = next!
                    }
                    DispatchQueue.main.async{
                        self.userRelations = data
                        self.myTable.reloadData()
                        self.classPlace.follower_count = data.totalCount
                        if self.refreshControl.isRefreshing{
                            self.refreshControl.endRefreshing()
                        }
                    }
                    
                }
            }
        }else{
          
            MolocateAccount.getFollowings(username: classUser.username) { (data, response, error, count, next, previous) -> () in
                if next != nil {
                    self.relationNextUrl = next!
                }
                DispatchQueue.main.async{
                    self.userRelations = data
                    self.myTable.reloadData()
                    self.classUser.following_count = data.totalCount
                    if self.refreshControl.isRefreshing{
                        self.refreshControl.endRefreshing()
                    }
                }
                
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        //let cell = TableViewCellFollowerFollowing(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier2")
        let cell = searchUsername(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.profilePhoto.tag = (indexPath as NSIndexPath).row
        cell.nameLabel.tag = (indexPath as NSIndexPath).row
        cell.followButton.tag = (indexPath as NSIndexPath).row
        cell.usernameLabel.tag = (indexPath as NSIndexPath).row
        cell.usernameLabel.text = userRelations.relations[(indexPath as NSIndexPath).row].username
        cell.nameLabel.text = userRelations.relations[(indexPath as NSIndexPath).row].name
        
       
        //bak bunaaaa  cell.nameLabel.text = userRelations.relations[indexPath.row]
       
        if(userRelations.relations[(indexPath as NSIndexPath).row].picture_url?.absoluteString != ""){
            cell.profilePhoto.sd_setImage(with: userRelations.relations[indexPath.row].picture_url, for: UIControlState.normal)
        }else{
            cell.profilePhoto.setImage(UIImage(named: "profile"), for: UIControlState())
        }
        
       cell.profilePhoto.addTarget(self, action: #selector(Followers.pressedProfile(_:)), for: .touchUpInside)

        if(!userRelations.relations[(indexPath as NSIndexPath).row].is_following){
            cell.followButton.setBackgroundImage(UIImage(named: "follow"), for: UIControlState())
        } else {
            cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), for: UIControlState())
        }
        cell.followButton.addTarget(self, action: #selector(Followers.pressedFollow(_:)), for: .touchUpInside)

//        if followersclicked {
//        
//               }else{
//            
//            if classUser.username == MoleCurrentUser.username {
//                
//                cell.followButton.hidden = true
//                cell.followButton.enabled = false
//                
//            }else{
//                
//                if(!userRelations.relations[indexPath.row].is_following){
//                    cell.followButton.hidden = false
//                    cell.followButton.enabled = true
//                    cell.followButton.addTarget(self, action: #selector(Followers.pressedFollow(_:)), forControlEvents: .TouchUpInside)
//                    
//                    
//                } else {
//                    cell.followButton.hidden = true
//                    cell.followButton.enabled = false
//                }
//                
//            }
//  
//        }
        //                cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        
        
//        if followersclicked {
//    
//            if(classUser.username == MoleCurrentUser.username && !userRelations.relations[indexPath.row].is_following){
//                cell.myLabel1.hidden = false
//                cell.myLabel1.enabled = true
//                cell.myLabel1.addTarget(self, action: #selector(Followers.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            }
//            
//            cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            
//        } else {
        //                cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
      
        if(userRelations.relations[(indexPath as NSIndexPath).row].username == MoleCurrentUser.username){
            cell.followButton.isHidden = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       

            tableView.deselectRow(at: indexPath, animated: true)
            self.parent!.navigationController?.setNavigationBarHidden(false, animated: false)
        
            activityIndicator.startAnimating()
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            
            let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
            
            if userRelations.relations[(indexPath as NSIndexPath).row].username  != MoleCurrentUser.username{
                controller.isItMyProfile = false
            }else{
                controller.isItMyProfile = true
            }
        
            controller.classUser.username =  userRelations.relations[(indexPath as NSIndexPath).row].username
            controller.classUser.profilePic = userRelations.relations[(indexPath as NSIndexPath).row].picture_url!
            controller.classUser.isFollowing = userRelations.relations[(indexPath as NSIndexPath).row].is_following
            
            self.navigationController?.pushViewController(controller, animated: true)
            MolocateAccount.getUser(userRelations.relations[(indexPath as NSIndexPath).row].username) { (data, response, error) -> () in
                DispatchQueue.main.async{
                    //DBG: If it is mine profile?
                    if data.username != ""{
                        user = data
                        controller.classUser = data
                        controller.RefreshGuiWithData()
                    }
                    
                    UIApplication.shared.endIgnoringInteractionEvents()
                        //choosedIndex = 0
                    self.activityIndicator.stopAnimating()
                
                }
            }
        
        }
        

    

    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(((indexPath as NSIndexPath).row%50 == 35)&&(relationNextUrl != "")){
            
            if(followersclicked){
                MolocateAccount.getFollowers(relationNextUrl, username: classUser.username, completionHandler: { (data, response, error, count, next, previous) in
                    
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
            }else{
                MolocateAccount.getFollowings(relationNextUrl, username: classUser.username, completionHandler: { (data, response, error, count, next, previous) in
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
        
    }
    
    
    
    func pressedFollow(_ sender: UIButton) {
        
        let buttonRow = sender.tag
        
        if !userRelations.relations[buttonRow].is_following{
            classUser.isFollowing = true
            self.userRelations.relations[buttonRow].is_following = true
            MolocateAccount.follow(userRelations.relations[buttonRow].username){ (data, response, error) -> () in
                
            }
            
        }else {
                self.classUser.isFollowing = false
                self.userRelations.relations[buttonRow].is_following = false
            MolocateAccount.unfollow(userRelations.relations[buttonRow].username){ (data, response, error) -> () in
                
            }
            
    }
        let index = IndexPath(row: buttonRow, section: 0)
        self.myTable.reloadRows(at: [index], with: .none)
        
        
        
    }
    
    func pressedProfile(_ sender: UIButton) {
        let row = sender.tag
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        
        if userRelations.relations[row].username  != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        
        controller.classUser.username =  userRelations.relations[row].username
        controller.classUser.profilePic = userRelations.relations[row].picture_url!
        controller.classUser.isFollowing = userRelations.relations[row].is_following
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(userRelations.relations[row].username) { (data, response, error) -> () in
            DispatchQueue.main.async{
                //DBG: If it is mine profile?
                if data.username != ""{
                    user = data
                    controller.classUser = data
                    controller.RefreshGuiWithData()
                }
                
                UIApplication.shared.endIgnoringInteractionEvents()
                //choosedIndex = 0
                self.activityIndicator.stopAnimating()
                
            }
        }
    }
    
 
    override func viewDidDisappear(_ animated: Bool) {
       // userRelations.relations.removeAll()
        //myTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight : CGFloat = 60
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRelations.relations.count
    }
    
    


}
