import UIKit
import Foundation
import CoreLocation
import QuadratTouch
import MapKit
import SDWebImage
import Haneke
import AVFoundation

//video caption ve süre eklenecek, report send edilecek
var sideClicked = false
var profileOn = 0
var category = "All"
let swiftColor = UIColor(netHex: 0xEB2B5D)
let swiftColor2 = UIColor(netHex: 0xC92451)
let greyColor1 = UIColor(netHex: 0xCCCCCC)
let swiftColor3 = UIColor(red: 249/255, green: 223/255, blue: 230/255, alpha: 1)
var comments = [MoleVideoComment]()
var video_id: String = ""
var user: MoleUser = MoleUser()
var videoIndex = 0
var isUploaded = true
var myViewController = "MainController"
var thePlace:MolePlace = MolePlace()
var pressedFollow = false
var selectedCell = 0
var viewBool = false
var isfiltersUp = false
var filters = [filter]()

class MainController: UIViewController, UITableViewDelegate , UITableViewDataSource, UICollectionViewDelegate,CLLocationManagerDelegate, UICollectionViewDataSource, UISearchBarDelegate, TimelineControllerDelegate, UITextFieldDelegate{
    
    
    @IBOutlet var venueTable: UITableView!
    @IBOutlet var collectionView: UICollectionView!

    var isSearching = false
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var session: Session!
    var venues: [MolePlace]!
    var searchedUsers:[MoleUser]!
    let distanceFormatter = MKDistanceFormatter()
    var currentTask: Task?
    var venueoruser: Bool = false
    var bestEffortAtLocation : CLLocation!
    var venueButton2: UIButton!
    var usernameButton2: UIButton!
    var lineLabel: UILabel!
    var redLabel: UILabel!
    var linee: UILabel!
    var on = true
    var findfriendsVenue: UIButton!
    let lineColor = UIColor(netHex: 0xCCCCCC)
    var searchText:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: MolocateDevice.size.width/2, height: 36))
    var refreshURL = URL(string: "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/video/api/explore/?category=all")
    var categories = ["HEPSİ","EĞLENCE","YEMEK","GEZİ","MODA" , "GÜZELLİK", "SPOR","ETKİNLİK","KAMPÜS","YAKINDA","TREND"]
    var categoryImagesWhite : [String]  = [ "all" , "fun", "food", "travel", "fashion", "beauty", "sport", "event", "campus", "nearby", "trend"]
    var categoryImagesBlack : [String]  = [ "allb" , "funb", "foodb", "travelb", "fashionb", "beautyb", "sportb", "eventb", "campusb", "nearbyb", "trendb"]
    var isBarOnView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = true
        navigationController?.navigationBar.barTintColor = swiftColor
        navigationController?.navigationBar.isTranslucent = false
        
        selectedCell = 0
        
        //tableController.tableView.makeoN
        //venueTable.layer.zPosition = 10
       
        tabBarController?.tabBar.isHidden = true
        
        searchText.layer.borderWidth = 0
        searchText.layer.cornerRadius = 5
        searchText.layer.borderColor = UIColor.white.cgColor
        searchText.searchBarStyle = .minimal
        searchText.returnKeyType = UIReturnKeyType.done
        let bartextField = searchText.value(forKey: "searchField") as! UITextField
        bartextField.backgroundColor = swiftColor2
        bartextField.font = UIFont(name: "AvenirNext-Regular", size: 14)
        bartextField.textColor = UIColor.white
        bartextField.attributedPlaceholder =  NSAttributedString(string: "Ara", attributes: [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 14)! ])
        
        let magnifyingGlass = bartextField.leftView as! UIImageView
        magnifyingGlass.image = magnifyingGlass.image?.withRenderingMode(.alwaysTemplate)
        magnifyingGlass.tintColor = UIColor.white
        
        //searchText.barTintColor = UIColor.whiteColor()
        let clearButton = bartextField.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white

        searchText.delegate = self

        
        navigationItem.titleView = searchText
        
        venueTable.separatorColor = UIColor.lightGray
        venueTable.tableFooterView = UIView()
        venueTable.isHidden = true
        session = Session.sharedSession()
        session.logger = ConsoleLogger()

        findfriendsVenue = UIButton()
        findfriendsVenue.frame = CGRect(x: self.view.center.x-70, y: self.view.frame.height*0.2, width: 140, height: 40)
        findfriendsVenue.backgroundColor = UIColor.blue
        findfriendsVenue.setTitle("Arkadaş bul", for: .normal)
        findfriendsVenue.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
        findfriendsVenue.addTarget(self, action: #selector(MainController.pressedFindFriend(_:)), for: .touchUpInside)
        findfriendsVenue.isHidden = true

        usernameButton2 = UIButton()
        usernameButton2.frame = CGRect(x: MolocateDevice.size.width / 2  , y: 2 , width: MolocateDevice.size.width / 2 , height: 40)
        usernameButton2.setTitleColor(lineColor, for: UIControlState())
        usernameButton2.contentHorizontalAlignment = .center
        usernameButton2.setTitle("KONUMLAR", for: UIControlState())
        usernameButton2.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size:14)
        usernameButton2.addTarget(self, action: #selector(MainController.pressedUsernameButton(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(usernameButton2)
        
        venueButton2 = UIButton()
        venueButton2.frame = CGRect(x: 0 ,y: 2 , width: MolocateDevice.size.width/2, height: 40)
        venueButton2.setTitleColor(swiftColor, for: UIControlState())
        venueButton2.contentHorizontalAlignment = .center
        venueButton2.setTitle("KİŞİLER", for: UIControlState())
        venueButton2.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size:14)
        
        venueButton2.addTarget(self, action: #selector(MainController.pressedVenue(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(venueButton2)
        venueButton2.isHidden = true
        usernameButton2.isHidden = true
        
        lineLabel = UILabel()
        lineLabel.frame = CGRect( x: 0 , y: 43.5 , width: MolocateDevice.size.width , height: 0.5)
        lineLabel.backgroundColor = lineColor
        view.addSubview(lineLabel)
        
        redLabel = UILabel()
        redLabel.frame = CGRect( x: 0 , y: 43 , width: MolocateDevice.size.width / 2 , height: 1.5)
        redLabel.backgroundColor = swiftColor
        view.addSubview(redLabel)
        lineLabel.isHidden = true
        redLabel.isHidden = true

        let rectShape3 = CAShapeLayer()
        rectShape3.bounds = self.findfriendsVenue.frame
        rectShape3.position = self.findfriendsVenue.center
        rectShape3.path = UIBezierPath(roundedRect: self.findfriendsVenue.bounds, byRoundingCorners: [.bottomRight , .topRight , .bottomLeft , .topLeft ] , cornerRadii: CGSize(width: 8, height: 8)).cgPath
        rectShape3.borderWidth = 1.0
        rectShape3.borderColor = swiftColor.cgColor
        
        self.findfriendsVenue.layer.backgroundColor = swiftColor.cgColor
        //Here I'm masking the textView's layer with rectShape layer
        self.findfriendsVenue.layer.mask = rectShape3
        collectionView!.backgroundColor = UIColor.clear
        //collectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:0, right: 0)

        MolocateVideo.getFilters { (data, response, error) in
            DispatchQueue.main.async{
                filters = data!
                self.collectionView.reloadData()
            }
            
        }
        
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        self.venueTable.addSubview(findfriendsVenue)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.showNavigationMain), name: NSNotification.Name(rawValue: "showNavigationMain"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.reloadMain), name:NSNotification.Name(rawValue: "reloadMain"), object: nil)
        
    }
    
    private func toggleNavigationBar(direction: Bool) {
        navigationController?.setNavigationBarHidden(direction, animated: true)
    }
    
    
    
    func pressedVenue(_ sender: UIButton) {
        
        venueoruser = false
        self.venueButton2.setTitleColor(swiftColor, for: UIControlState())
        self.usernameButton2.setTitleColor(lineColor, for: UIControlState())
        self.redLabel.frame.origin.x = 0
        self.usernameButton2.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size:14)
        self.venueButton2.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size:14)
        self.usernameButton2.setTitleColor(lineColor, for: UIControlState())
        self.venueButton2.setTitleColor(swiftColor, for: UIControlState())
        self.findfriendsVenue.setTitle("Arkadaşlarını Bul", for: UIControlState())
        if self.venueTable.numberOfRows(inSection: 0) > 0 {
            self.venueTable.reloadData()
        }
        self.findfriendsVenue.removeTarget(self, action: #selector(MainController.pressedFindVenue(_:)), for: .touchUpInside)
        self.findfriendsVenue.addTarget(self, action: #selector(MainController.pressedFindFriend(_:)), for: .touchUpInside)
    }
    
    func pressedUsernameButton(_ sender: UIButton) {
        venueoruser = true
        self.venueButton2.setTitleColor(swiftColor, for: UIControlState())
        self.usernameButton2.setTitleColor(lineColor, for: UIControlState())
        self.usernameButton2.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size:14)
        self.venueButton2.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size:14)
        self.redLabel.frame.origin.x = MolocateDevice.size.width / 2
        self.usernameButton2.setTitleColor(swiftColor, for: UIControlState())
        self.venueButton2.setTitleColor(lineColor, for: UIControlState())
        self.findfriendsVenue.setTitle("Yakın Konumları Bul", for: UIControlState())
        self.findfriendsVenue.removeTarget(self, action: #selector(MainController.pressedFindFriend(_:)), for: .touchUpInside)
        
        self.findfriendsVenue.addTarget(self, action: #selector(MainController.pressedFindVenue(_:)), for: .touchUpInside)
        
        if self.venueTable.numberOfRows(inSection: 0) > 0 {
            self.venueTable.reloadData()  }
    }
    
    func showNavigationMain() {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchText.resignFirstResponder()
        //   Timelinecontrollerx da Main icin hide navigation bar farkli olmali
    }
    
    
    func tableView(_ atableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if !venueoruser {
            let rowHeight : CGFloat = 54
            return rowHeight
        }
        
        return 60
        
    }
    
    
    
    
    func tableView(_ atableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if venueoruser {
            if let venues = self.venues {
                return venues.count}
        }
        else {
            if let searchedUsers = self.searchedUsers {
                return searchedUsers.count
            }
        }
        return 0
    }
    
    func tableView(_ atableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if venueoruser {
            let cell = searchVenue(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            //            let cell = venueTable.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let venue = venues[indexPath.row]
            cell.addressNameLabel.text = venue.address
            cell.nameLabel.text = venue.name
            cell.distanceLabel.text = venue.distance
            return cell
        } else {
            let cell = searchUsername(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            if searchedUsers[indexPath.row].isFollowing {
                cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), for: UIControlState())
                cell.followButton.addTarget(self, action: #selector(MainController.pressedUnfollowSearch(_:)), for: .touchUpInside)
            } else {
                cell.followButton.setBackgroundImage(UIImage(named: "follow"), for: UIControlState())
                cell.followButton.addTarget(self, action: #selector(MainController.pressedFollowSearch(_:)), for: .touchUpInside)
            }
            cell.usernameLabel.text = "@\(searchedUsers[indexPath.row].username)"
            if searchedUsers[indexPath.row].first_name == "" {
                cell.nameLabel.text = "\(searchedUsers[indexPath.row].username)"
            }
            else{
                cell.nameLabel.text = "\(searchedUsers[indexPath.row].first_name) \(searchedUsers[indexPath.row].last_name)"
            }
            if(searchedUsers[indexPath.row].profilePic?.absoluteString != ""){
                cell.profilePhoto.sd_setImage(with: searchedUsers[indexPath.row].profilePic, for: UIControlState.normal)
            }else{
                cell.profilePhoto.setImage(UIImage(named: "profile"), for: UIControlState())
            }
            
            cell.profilePhoto.addTarget(self, action: #selector(MainController.pressedProfileSearch(_:)), for: UIControlEvents.touchUpInside)
            //cell.followButton.addTarget(self, action: Selector("pressedFollowSearch"), forControlEvents: .TouchUpInside)
            cell.followButton.tag = indexPath.row
            cell.profilePhoto.tag = indexPath.row
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //DBG::Searchde push view controller yapmaliyiz
        if venueoruser {
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            navigationController?.setNavigationBarHidden(false, animated: false)
            
            let controller:profileVenue = self.storyboard!.instantiateViewController(withIdentifier: "profileVenue") as! profileVenue
            
            self.navigationController?.pushViewController(controller, animated: true)
            MolocatePlace.getPlace(self.venues[indexPath.row].id) { (data, response, error) -> () in
                DispatchQueue.main.async{
                    thePlace = data
                    controller.classPlace = data
                    controller.RefreshGuiWithData()
                }
            }
            
            
            
            self.searchText.resignFirstResponder()
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! searchUsername
            pressedProfileSearch(cell.profilePhoto)
            
        }
    }
    
    
    
    
    func pressedProfileSearch(_ sender:UIButton){
        
        let username = searchedUsers[sender.tag].username
        
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        if username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        controller.classUser.username = username
        controller.classUser.profilePic =  searchedUsers[sender.tag].profilePic
        controller.classUser.isFollowing = searchedUsers[sender.tag].isFollowing
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(username) { (data, response, error) -> () in
            DispatchQueue.main.async{
                //DBG: If it is mine profile?
                
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
        self.searchText.resignFirstResponder()
    }
    
    func pressedFollowSearch(_ sender: UIButton) {
        
        let buttonRow = sender.tag
        pressedFollow = true
        self.searchedUsers[buttonRow].isFollowing = true
        var indexes = [IndexPath]()
        let index = IndexPath(row: buttonRow, section: 0)
        indexes.append(index)
        self.venueTable.reloadRows(at: indexes, with: .none)
        
        MolocateAccount.follow(self.searchedUsers[buttonRow].username){ (data, response, error) -> () in
            MoleCurrentUser.following_count += 1
            
        }
        
        pressedFollow = false
        
        
    }
    
    
    func pressedUnfollowSearch(_ sender: UIButton) {
        
        let buttonRow = sender.tag
        pressedFollow = false
        self.searchedUsers[buttonRow].isFollowing = false
        var indexes = [IndexPath]()
        let index = IndexPath(row: buttonRow, section: 0)
        indexes.append(index)
        self.venueTable.reloadRows(at: indexes, with: .none)
        
        MolocateAccount.unfollow(self.searchedUsers[buttonRow].username){ (data, response, error) -> () in
            MoleCurrentUser.following_count -= 1
            
        }
        
        pressedFollow = true
        
        
    }
    
    func changeView() {
        
    }
    
    
    func pressedFindVenue(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                let message = NSLocalizedString("Molocate'in konum servislerini kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
                let alertController = UIAlertController(title: "Molocate Konum", message: message, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.default) {action in
                    UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                }
                alertController.addAction(settingsAction)
                self.present(alertController, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse:
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                let controller:findVenueController = self.storyboard!.instantiateViewController(withIdentifier: "findVenueController") as! findVenueController
                self.searchText.resignFirstResponder()
                self.navigationController?.pushViewController(controller, animated: true)
                // /rint(self.bestEffortAtLocation.coordinate.latitude)
                let lat = Float(self.bestEffortAtLocation.coordinate.latitude)
                let lon = Float(self.bestEffortAtLocation.coordinate.longitude)
                MolocatePlace.getNearbyPlace(lat, placeLon: lon) { (data, response, error) in
                    DispatchQueue.main.async{
                        controller.venues = data
                        controller.tableView.reloadData()
                    }
                }
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            }
        } else {
            displayAlert(title: "Tamam", message: "Konum servisleriniz aktif değil.")
            
            
        }
        
        
    }
    
    
    func pressedFindFriend(_ sender: UIButton) {
        
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let controller:findFriendController = self.storyboard!.instantiateViewController(withIdentifier: "findFriendController") as! findFriendController
        self.searchText.resignFirstResponder()
        self.navigationController?.pushViewController(controller, animated: true)
        
        
        if MoleCurrentUser.isFaceUser {
            MolocateAccount.getFacebookFriends(completionHandler: { (data, response, error, count, next, previous) in
                DispatchQueue.main.async(execute: {
                    controller.userRelations = data
                    controller.tableView.reloadData()
                    controller.userRelationsFace = data
                    
                    
                })
            })
            MolocateAccount.getSuggestedFriends { (data, response, error, count, next, previous) in
                DispatchQueue.main.async(execute: {
                    controller.userRelationsRandom = data
                })
            }
            
            
        } else {
            MolocateAccount.getSuggestedFriends { (data, response, error, count, next, previous) in
                DispatchQueue.main.async(execute: {
                    controller.userRelations = data
                    controller.userRelationsRandom = data
                    controller.tableView.reloadData()
                })
            }
        }
        
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        
    }
    
    func pressedUsername(_ username: String, profilePic: URL?, isFollowing: Bool) {
        
        
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
    
    
    func pressedPlace(_ placeId: String, Row: Int) {
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let controller:profileVenue = self.storyboard!.instantiateViewController(withIdentifier: "profileVenue") as! profileVenue
        self.navigationController?.pushViewController(controller, animated: true)
        
        MolocatePlace.getPlace(placeId) { (data, response, error) -> () in
            DispatchQueue.main.async{
                thePlace = data
                controller.classPlace = data
                controller.RefreshGuiWithData()
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
        
        
        
        
    }
    
    func pressedComment(_ videoId: String, Row: Int) {
        
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        video_id = videoId
        videoIndex = Row
        myViewController = "MainController"
        
        
        let controller:commentController = self.storyboard!.instantiateViewController(withIdentifier: "commentController") as! commentController
        
        comments.removeAll()
        MolocateVideo.getComments(videoId) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                comments = data
                controller.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func pressedLikeCount(_ videoId: String, Row: Int) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        video_id = videoId
        videoIndex = Row
        
        let controller:likeVideo = self.storyboard!.instantiateViewController(withIdentifier: "likeVideo") as! likeVideo
        
        MolocateVideo.getLikes(videoId) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                controller.users = data
                controller.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
            
        }
        
        //DBG: Burda  likeları çağır,
        //Her gectigimiz ekranda activity indicatorı goster
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared().clearMemory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeSideBar"), object: nil)
        if venues != nil {
            self.venues.removeAll()
        }
        if searchedUsers != nil {
            self.searchedUsers.removeAll()
        }
        self.venueTable.reloadData()
        
    }
    @IBAction func sideBar(_ sender: AnyObject) {
        if(sideClicked == false){
            sideClicked = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "openSideBar"), object: nil)
        } else {
            sideClicked = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeSideBar"), object: nil)
        }
    }
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBAction func openCamera(_ sender: AnyObject) {
        
        if (isUploaded) {
            CaptionText = ""
            if isSearching != true {
                if CLLocationManager.locationServicesEnabled() {
                    switch(CLLocationManager.authorizationStatus()) {
                    case .notDetermined, .restricted, .denied:
                        let message = NSLocalizedString("Molocate'in konum servislerini kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
                        let alertController = UIAlertController(title: "Molocate Konum", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.default) {action in
                            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                        }
                        alertController.addAction(settingsAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    case .authorizedAlways, .authorizedWhenInUse:
                        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                        activityIndicator.center = self.view.center
                        activityIndicator.hidesWhenStopped = true
                        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                        view.addSubview(activityIndicator)
                        activityIndicator.startAnimating()
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        self.parent!.parent!.performSegue(withIdentifier: "goToCamera", sender: self.parent)
                        
                    }
                } else {
                    displayAlert(title: "Tamam", message: "Konum servisleriniz aktif değil.")
                    
                    
                }
                
            } else {
                
                self.cameraButton.image = UIImage(named: "newcamera")
                self.cameraButton.title = nil
                self.searchText.text = ""
                self.searchText.placeholder = "Ara"
                self.isSearching = false
                self.venueButton2.isHidden = true
                self.lineLabel.isHidden = true
                self.redLabel.isHidden = true
                self.usernameButton2.isHidden = true
                self.collectionView.isHidden = false
                self.venueTable.isHidden = true
                self.findfriendsVenue.isHidden = true
                self.searchText.resignFirstResponder()
                if searchedUsers != nil {
                    searchedUsers.removeAll()
                    self.venueTable.reloadData()
                }
                if venues != nil {
                    venues.removeAll()
                    self.venueTable.reloadData()
                    
                }
                
            }
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell : myCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! myCollectionViewCell
        myCell.categoryImage.sd_setImage(with: filters[indexPath.row].thumbnail_url)
        let backgroundView = UIView()
        backgroundView.backgroundColor = swiftColor
        return myCell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let controller:FilterController = self.storyboard!.instantiateViewController(withIdentifier: "FilterController") as! FilterController
        controller.filter_raw = filters[indexPath.row].raw_name
        controller.filter_name = filters[indexPath.row].name
        
        if filters[indexPath.row].raw_name == "nearby" {
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted, .denied:
                    let message = NSLocalizedString("Molocate'in konum servislerini kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
                    let alertController = UIAlertController(title: "Molocate Konum", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.default) {action in
                        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                    }
                    alertController.addAction(settingsAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    let lat = Float(self.bestEffortAtLocation.coordinate.latitude)
                    let lon = Float(self.bestEffortAtLocation.coordinate.longitude)
                    controller.classLat = lat
                    controller.classLon = lon
                    
                }
            } else {
                displayAlert(title: "Tamam", message: "Konum servisleriniz aktif değil.")
                
                
            }
            
        }
        self.navigationController?.pushViewController(controller, animated: true)
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation:CLLocation = locations.last!
        let locationAge = newLocation.timestamp.timeIntervalSinceNow
        
        //print(locationAge)
        if locationAge > 5 {
            return
        }
        
        if (bestEffortAtLocation == nil) || (bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
            self.bestEffortAtLocation = newLocation
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = true
        
        DispatchQueue.main.async {
            
            
            // The search bar is hidden when the view becomes visible the first time
            
            
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            let seconds = 5.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                
                self.locationManager.stopUpdatingLocation()
                
            })
            
        }
        self.collectionView.reloadData()
        //self.collectionView.setContentOffset(self.currentOffset, animated: false)
        if isBarOnView {
            
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        MolocateVideo.getFilters { (data, response, error) in
            DispatchQueue.main.async {
                var newFilters = data!
                if filters.count == newFilters.count {
                    for i in 0..<filters.count {
                        if filters[i].name != newFilters[i].name {
                            filters = newFilters
                            self.collectionView.collectionViewLayout.invalidateLayout()
                            self.collectionView.reloadData()
                        }
                    }
                } else {
                    filters = newFilters
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.reloadData()
                }
            }
        }
        
        
        
        
    }
    
    
    func reloadMain() {
        
        DispatchQueue.main.async {
            
            
            // The search bar is hidden when the view becomes visible the first time
            
            
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            let seconds = 5.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                
                self.locationManager.stopUpdatingLocation()
                
            })
            
        }
        MolocateVideo.getFilters { (data, response, error) in
            DispatchQueue.main.async {
                var newFilters = data!
                if filters.count == newFilters.count {
                    for i in 0..<filters.count {
                        if filters[i].name != newFilters[i].name {
                            filters = newFilters
                            self.collectionView.collectionViewLayout.invalidateLayout()
                            self.collectionView.reloadData()
                        }
                    }
                } else {
                    filters = newFilters
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.reloadData()
                }
            }
        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        //self.tableView.removeFromSuperview()
        //SDImageCache.sharedImageCache().cleanDisk()
        //self.tableController.isOnView = false
        if isSearching == true {
            self.cameraButton.image = UIImage(named: "newcamera")
            self.cameraButton.title = nil
            self.isSearching = false
            self.venueTable.isHidden = true
            self.findfriendsVenue.isHidden = true
            self.venueButton2.isHidden = true
            self.lineLabel.isHidden = true
            self.redLabel.isHidden = true
            self.usernameButton2.isHidden = true
            self.collectionView.isHidden = false
            self.searchText.resignFirstResponder()
        }
        
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        
        isSearching = true
        cameraButton.image = nil
        cameraButton.title = "Vazgeç"
        venueTable.isHidden = false
        findfriendsVenue.isHidden = false
        self.pressedVenue(venueButton2)
        
        venueButton2.isHidden = false
        self.lineLabel.isHidden = false
        self.redLabel.isHidden = false
        usernameButton2.isHidden = false
        collectionView.isHidden = true
        
        
        self.view.layer.addSublayer(venueTable.layer)
        self.view.layer.addSublayer(venueButton2.layer)
        
        
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.venueTable.isHidden = false
        findfriendsVenue.isHidden = true
        self.venueButton2.isHidden = false
        self.usernameButton2.isHidden = false
        self.lineLabel.isHidden = false
        self.redLabel.isHidden = false
        self.collectionView.isHidden = true
        let whitespaceCharacterSet = CharacterSet.symbols
        let strippedString = searchText.text!.trimmingCharacters(in: whitespaceCharacterSet) + text
        
        
        if venueoruser {
            locationManager.startUpdatingLocation()
            if self.bestEffortAtLocation == nil {
                let message = NSLocalizedString("Molocate'in konum servislerini kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
                let alertController = UIAlertController(title: "Molocate Konum", message: message, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                // Provide quick access to Settings.
                let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.default) {action in
                    UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                    
                }
                alertController.addAction(settingsAction)
                self.present(alertController, animated: true, completion: nil)
                
                return true
            }
            let lat = Float(self.bestEffortAtLocation.coordinate.latitude)
            let lon = Float(self.bestEffortAtLocation.coordinate.longitude)
            MolocatePlace.searchPlace(strippedString, placeLat: lat, placeLon: lon, completionHandler: { (data, response, error) in
                DispatchQueue.main.async{
                    self.venues = data
                    self.venueTable.reloadData()
                }
            })
            
            
            
        } else {
            
            if (searchText.text?.characters.count)! > 1 {
                MolocateAccount.searchUser(strippedString, completionHandler: { (data, response, error) in
                    DispatchQueue.main.async{
                        self.searchedUsers = data
                        self.venueTable.reloadData()
                    }
                    
                })
            }
        }
        
        return true
    }
    
    private func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        textField.resignFirstResponder()
        return true
    }
    
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
