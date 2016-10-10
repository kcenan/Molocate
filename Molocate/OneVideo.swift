//  oneVideo.swift
//  Molocate


import UIKit

class oneVideo: UIViewController,PlayerDelegate {
    
    var player = Player()
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var likeHeart = UIImageView()
    let screenSize: CGRect = UIScreen.main.bounds

    @IBOutlet var tableView: UITableView!
    @IBAction func backButton(_ sender: AnyObject) {
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIApplication.shared.isIgnoringInteractionEvents{
        UIApplication.shared.endIgnoringInteractionEvents()
        }
        initGui()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func initGui(){
        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0

        tableView.allowsSelection = false
        
        player = Player()
        player.delegate = self
        player.playbackLoops = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if (MoleGlobalVideo == nil){
            MoleGlobalVideo = MoleVideoInformation()
        }
        if !pressedLike && !pressedFollow {
            
            let cell = videoCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
            
            cell.initialize((indexPath as NSIndexPath).row, videoInfo:  MoleGlobalVideo)
            
            cell.Username.addTarget(self, action: #selector(oneVideo.pressedUsername(_:)), for: UIControlEvents.touchUpInside)
            cell.placeName.addTarget(self, action: #selector(oneVideo.pressedPlace(_:)), for: UIControlEvents.touchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(oneVideo.pressedUsername(_:)), for: UIControlEvents.touchUpInside)
            cell.commentCount.addTarget(self, action: #selector(oneVideo.pressedComment(_:)), for: UIControlEvents.touchUpInside)
            if(MoleGlobalVideo.isFollowing==0 && MoleGlobalVideo.username != MoleCurrentUser.username){
                cell.followButton.addTarget(self, action: #selector(oneVideo.pressedFollow(_:)), for: UIControlEvents.touchUpInside)
            }else{
                cell.followButton.isHidden = true
            }
            
            cell.likeButton.addTarget(self, action: #selector(oneVideo.pressedLike(_:)), for: UIControlEvents.touchUpInside)
            
            cell.likeCount.setTitle("\(MoleGlobalVideo.likeCount)", for: UIControlState())
            cell.commentCount.setTitle("\(MoleGlobalVideo.commentCount)", for: UIControlState())
            cell.commentButton.addTarget(self, action: #selector(oneVideo.pressedComment(_:)), for: UIControlEvents.touchUpInside)
            cell.reportButton.addTarget(self, action: #selector(oneVideo.pressedReport(_:)), for: UIControlEvents.touchUpInside)
            cell.likeCount.addTarget(self, action: #selector(oneVideo.pressedLikeCount(_:)), for: UIControlEvents.touchUpInside)
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            let playtap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)
            
            playtap.require(toFail: tap)
            
            if(MoleGlobalVideo.urlSta.absoluteString != ""){
                self.player.setUrl(MoleGlobalVideo.urlSta)
                self.player.playFromBeginning()
                
            }
            
            self.player.view.frame = cell.newRect
            
            cell.contentView.addSubview(self.player.view)
            
            
            return cell
        }else{
            let cell = tableView.cellForRow(at: indexPath) as! videoCell
            if pressedLike {
                pressedLike = false
                cell.likeCount.setTitle("\(MoleGlobalVideo.likeCount)", for: UIControlState())
                
                if(MoleGlobalVideo.isLiked == 0) {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeunfilled"), for: UIControlState())
                }else{
                    cell.likeButton.setBackgroundImage(UIImage(named: "likefilled"), for: UIControlState())
                    cell.likeButton.tintColor = UIColor.white
                }
            }else if pressedFollow{
                pressedFollow = true
                
                cell.followButton.isHidden = MoleGlobalVideo.isFollowing == 1 ? true:false
                
            }
            return cell
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return screenSize.width + 150
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func pressedUsername(_ sender: UIButton) {
        navigationController?.isNavigationBarHidden = false
    
        //////////print("username e basıldı at index path: \(buttonRow)")
        player.stop()
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        if MoleGlobalVideo.username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(MoleGlobalVideo.username) { (data, response, error) -> () in
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

        func playTapped(_ sender: UITapGestureRecognizer) {
        if player.playbackState.description == "Playing"{
            player.stop()
        }else if player.playbackState.description == "Stopped"{
            player.playFromCurrentTime()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = false
    }
    func pressedPlace(_ sender: UIButton) {
       
        
        player.stop()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.navigationController?.isNavigationBarHidden = false
        
        
        let controller:profileVenue = self.storyboard!.instantiateViewController(withIdentifier: "profileVenue") as! profileVenue
        self.navigationController?.pushViewController(controller, animated: true)
        
        
        MolocatePlace.getPlace(MoleGlobalVideo.locationID) { (data, response, error) -> () in
            DispatchQueue.main.async{
                thePlace = data
                controller.classPlace = data
                controller.RefreshGuiWithData()
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        
    }
    
    
    func pressedLikeCount(_ sender: UIButton) {
        navigationController?.isNavigationBarHidden = false
        player.stop()
        video_id = MoleGlobalVideo.id
  
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        let controller:likeVideo = self.storyboard!.instantiateViewController(withIdentifier: "likeVideo") as! likeVideo
        
        MolocateVideo.getLikes(video_id) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                controller.users = data
                controller.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
            
        }
        
        //DBG: Burda  likeları çağır,
        //Her gectigimiz ekranda activity indicatorı goster
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func pressedComment(_ sender: UIButton) {
        navigationController?.isNavigationBarHidden = false
      
        
        player.stop()
        
      
        video_id = MoleGlobalVideo.id
        
        myViewController = "HomeController"
        
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let controller:commentController = self.storyboard!.instantiateViewController(withIdentifier: "commentController") as! commentController
        comments.removeAll()
        MolocateVideo.getComments(MoleGlobalVideo.id) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                comments = data
                controller.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }

    func pressedFollow(_ sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        //print("followa basıldı at index path: \(buttonRow) ")
        MoleGlobalVideo.isFollowing = 1
        var indexes = [IndexPath]()
        let index = IndexPath(row: buttonRow, section: 0)
        indexes.append(index)
        self.tableView.reloadRows(at: indexes, with: .none)
        
        MolocateAccount.follow(MoleGlobalVideo.username){ (data, response, error) -> () in
            //print(data)
        }
        pressedFollow = false
    }
    
    
        func doubleTapped(_ sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        // print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = IndexPath(row: buttonRow, section: 0)
        let  cell = tableView.cellForRow(at: indexpath)
        likeHeart.center = (cell?.contentView.center)!
        likeHeart.layer.zPosition = 100
        let imageSize = likeHeart.image?.size.height
        likeHeart.frame = CGRect(x: likeHeart.center.x-imageSize!/2 , y: likeHeart.center.y-imageSize!/2, width: imageSize!, height: imageSize!)
        cell?.addSubview(likeHeart)
        MolocateUtility.animateLikeButton(heart: &likeHeart)
        
        var indexes = [IndexPath]()
        indexes.append(indexpath)
        
        if(MoleGlobalVideo.isLiked == 0){
            
            MoleGlobalVideo.isLiked=1
            MoleGlobalVideo.likeCount+=1
            
            
            self.tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
            
            MolocateVideo.likeAVideo(MoleGlobalVideo.id) { (data, response, error) -> () in
                DispatchQueue.main.async{
                   // print(data)
                }
            }
        }else{
            
            
            MoleGlobalVideo.isLiked=0
            MoleGlobalVideo.likeCount-=1
            self.tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
            
            
            MolocateVideo.unLikeAVideo(MoleGlobalVideo.id){ (data, response, error) -> () in
                DispatchQueue.main.async{
                    //print(data)
                }
            }
        }
        pressedLike = false
    }
    func pressedLike(_ sender: UIButton) {
        let buttonRow = sender.tag
        //print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = IndexPath(row: buttonRow, section: 0)
        var indexes = [IndexPath]()
        indexes.append(indexpath)
        
        if(MoleGlobalVideo.isLiked == 0){
            sender.isHighlighted = true
            
            MoleGlobalVideo.isLiked=1
            MoleGlobalVideo.likeCount+=1
            self.tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
            
            MolocateVideo.likeAVideo(MoleGlobalVideo.id) { (data, response, error) -> () in
                DispatchQueue.main.async{
                 //   print(data)
                }
            }
        }else{
            sender.isHighlighted = false
            
            MoleGlobalVideo.isLiked=0
            MoleGlobalVideo.likeCount-=1
            self.tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
            
            
            MolocateVideo.unLikeAVideo(MoleGlobalVideo.id){ (data, response, error) -> () in
                DispatchQueue.main.async{
                  //  print(data)
                }
            }
        }
        pressedLike = false
    }
    
    func pressedReport(_ sender: UIButton) {
        _ = sender.tag
        player.stop()
        
        MolocateVideo.reportAVideo(MoleGlobalVideo.id) { (data, response, error) -> () in
           // print(data)
        }
        //print("pressedReport at index path: \(buttonRow)")
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Report the Video", style: .default) { action -> Void in
            
            //print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    func playerReady(_ player: Player) {
        //self.player.playFromBeginning()
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
