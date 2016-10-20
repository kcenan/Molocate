import UIKit
import SDWebImage

class likeVideo: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    let cellIdentifier = "cell5"
    var users = [MoleUser]()
    var activityIndicator = UIActivityIndicatorView()
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var tableView: UITableView!
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var pressedFollow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGui()
        //getData()
        
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func initGui(){
        self.automaticallyAdjustsScrollViewInsets = false
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.tintColor = UIColor.white
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Beğeniler güncelleniyor...")
        self.refreshControl.addTarget(self, action: #selector(likeVideo.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
   
    }
    
    
    func refresh(_ sender: AnyObject){
       getData()
    }
    
    
    func getData(){
        MolocateVideo.getLikes(video_id) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                self.users = data
                self.tableView.reloadData()
                
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }
            
        }

    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! likeVideoCell
            
            cell.username.setTitle("\(self.users[indexPath.row].username)", for: UIControlState())
            cell.username.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            cell.username.tag = indexPath.row
            cell.username.tintColor = swiftColor
            cell.username.addTarget(self, action: #selector(likeVideo.pressedProfile(_:)), for: UIControlEvents.touchUpInside)
            cell.profileImage.isHidden = false
           // cell.profileImage.layer.borderWidth = 0.1
          // cell.profileImage.layer.masksToBounds = false
        //cell.profileImage.layer.borderColor = UIColor.white.cgColor
         //   cell.profileImage.backgroundColor = profileBackgroundColor
        //cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
           //cell.profileImage.clipsToBounds = true
        
        cell.profileImage.addTarget(self, action: #selector(likeVideo.pressedProfile(_:)), for: UIControlEvents.touchUpInside)
        cell.profileImage.tag = indexPath.row
    if !pressedFollow {
                if(!users[indexPath.row].isFollowing && users[indexPath.row].username != MoleCurrentUser.username){
                    cell.followLike.isHidden = false
                }else{
                    cell.followLike.isHidden = true
                }
        }else{
            cell.followLike.isHidden = false
            //cell.followLike.enabled = false
            cell.followLike.setBackgroundImage(UIImage(named: "followTicked"), for: UIControlState())
        }
   
        if(users[indexPath.row].thumbnailPic != nil){
            
            cell.profileImage.setBackgroundImage(UIImage(named: "profile")!, for:
               UIControlState())
            cell.profileImage.sd_setBackgroundImage(with: users[indexPath.row].thumbnailPic!, for: UIControlState())
        }else{
            cell.profileImage.setBackgroundImage(UIImage(named: "profile")!, for:
                 UIControlState())
        }
        cell.profileImage.layer.borderWidth = 0.1
        cell.profileImage.layer.borderColor = UIColor.white.cgColor
        
        cell.profileImage.layer.masksToBounds = false
        cell.profileImage.layoutIfNeeded()
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
        cell.profileImage.clipsToBounds = true
        

            return cell
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func pressedProfile(_ sender: UIButton) {
        
        self.parent!.navigationController?.setNavigationBarHidden(false, animated: false)
        let buttonRow = sender.tag
      
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        if users[buttonRow].username != MoleCurrentUser.username{
            mine = false
        }else{
            mine = true
        }
        
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(users[buttonRow].username) { (data, response, error) -> () in
            DispatchQueue.main.async{
                //DBG: If it is mine profile?
                
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                
                //choosedIndex = 0
                self.activityIndicator.removeFromSuperview()
            }
        }
    }
  
    
    func pressedFollow(_ sender: UIButton) {
        //print("pressedfollow")
        pressedFollow = true
        let buttonRow = sender.tag
        
        users[buttonRow].isFollowing = true
        
        let index : IndexPath = IndexPath(row: buttonRow, section: 0)
        
        tableView.reloadRows(at: [index], with: UITableViewRowAnimation.automatic)
       
        MolocateAccount.follow(users[buttonRow].username, completionHandler: { (data, response, error) -> () in
            //DBG: Check if it is succeed
        })
        
        pressedFollow = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        
        navigationController?.popViewController(animated: true)
//        dispatch_async(dispatch_get_main_queue()) {
//            
//            self.willMoveToParentViewController(nil)
//            self.view.removeFromSuperview()
//            self.removeFromParentViewController()
//            
//            
//        }
        
    }
    
}
