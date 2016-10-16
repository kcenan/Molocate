import UIKit
import Foundation
import CoreLocation

class NotificationsViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate, CLLocationManagerDelegate  {
    
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var location:CLLocation!
    var bestEffortAtLocation:CLLocation!
    var notificationArray = [MoleUserNotifications]()
    let refreshControl:UIRefreshControl = UIRefreshControl()
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGui()
        getData()
        
        //DBG: What should we do when error occurs
        MolocateAccount.resetBadge { (data, response, error) in
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationsViewController.scrollToTop), name: NSNotification.Name(rawValue: "scrollToTop"), object: nil)
     
        self.refreshControl.attributedTitle = NSAttributedString(string: "Bildirimler güncelleniyor...")
        self.refreshControl.addTarget(self, action: #selector(NotificationsViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        //DBG: Delete unnecessary endIgnoringEvents
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    func refresh(_ sender: AnyObject){
        MolocateNotifications.getNotifications(nil) { (data, response, error) -> () in
            DispatchQueue.main.async{
                self.notificationArray = data!
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func getData(){
        //DBG: What should we do when error occurs
        MolocateNotifications.getNotifications(nil) { (data, response, error) -> () in
            DispatchQueue.main.async{
                self.notificationArray = data!
                self.tableView.reloadData()
            }
        }
    }
    func initGui(){
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.lightGray
        tabBarController?.tabBar.isHidden = true
        
        self.navigationController?.isNavigationBarHidden = false
        
        
        // self.view.backgroundColor = swiftColor
    }
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! molocateNotificationCell
        
        cell.fotoButton.addTarget(self, action: #selector(NotificationsViewController.pressedProfilePhoto(_:)), for: UIControlEvents.touchUpInside)
        cell.fotoButton.layer.borderWidth = 0.1
        cell.fotoButton.layer.masksToBounds = false
        cell.fotoButton.layer.borderColor = profileBackgroundColor.cgColor
        cell.fotoButton.backgroundColor = profileBackgroundColor
        cell.fotoButton.layer.cornerRadius = cell.fotoButton.frame.height/2
        cell.fotoButton.clipsToBounds = true
        cell.fotoButton.tag = (indexPath as NSIndexPath).row
        
        if(notificationArray[(indexPath as NSIndexPath).row].picture_url?.absoluteString != ""){
            cell.fotoButton.sd_setImage(with: notificationArray[indexPath.row].picture_url, for: UIControlState.normal)
        } else {
            cell.fotoButton.setImage(UIImage(named: "profile"), for: UIControlState())
        }
        
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSForegroundColorAttributeName] = swiftColor2
        multipleAttributes[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 14.0)
        let usernameAttributedString =  NSMutableAttributedString(string:  notificationArray[(indexPath as NSIndexPath).row].actor , attributes: multipleAttributes)
        
        var multipleAttributes2 = [String : NSObject]()
        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 12.0)
        multipleAttributes2[NSForegroundColorAttributeName] = UIColor.black
        let notificationAttributedString = NSAttributedString(string:  notificationArray[(indexPath as NSIndexPath).row].sentence, attributes:  multipleAttributes2)
        usernameAttributedString.append(notificationAttributedString)
        
        var multipleAttributes3 = [String : NSObject]()
        multipleAttributes3[NSFontAttributeName] =  UIFont(name: "AvenirNext-Medium", size: 10.0)
        multipleAttributes3[NSForegroundColorAttributeName] = UIColor.darkGray
        let timeAttributedString = NSAttributedString(string:  "  " + notificationArray[(indexPath as NSIndexPath).row].date  , attributes:  multipleAttributes3)
        usernameAttributedString.append(timeAttributedString)
        
        cell.myLabel.textAlignment = .left
        cell.myLabel.attributedText = usernameAttributedString
        cell.myLabel.tag = (indexPath as NSIndexPath).row
        let labeltap = UITapGestureRecognizer(target: self, action:#selector(NotificationsViewController.labelTapped(_:) ));
        labeltap.numberOfTapsRequired = 1
        cell.myLabel.addGestureRecognizer(labeltap)
        
        return cell
    }
    
    
    @IBAction func openCamera(_ sender: AnyObject) {
        
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
            displayAlert("Tamam", message: "Konum servisleriniz aktif değil.")
        }
    }
    
    func pressedProfilePhoto(_ sender: UIButton) {
        let buttonRow = sender.tag
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        mine = false
        
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(notificationArray[buttonRow].actor) { (data, response, error) -> () in
            DispatchQueue.main.async{
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                self.activityIndicator.removeFromSuperview()
            }
        }
        
    }
    
    
    func pressedUsername(_ sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
      
        
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        
        self.navigationController?.pushViewController(controller, animated: true)
        
        MolocateAccount.getUser(notificationArray[buttonRow].actor) { (data, response, error) -> () in
            DispatchQueue.main.async{
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                self.activityIndicator.removeFromSuperview()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }
    
    
    func pressedCell(_ sender: UITapGestureRecognizer){
        let buttonRow = sender.view?.tag
        //print(notificationArray[buttonRow!].action )
        if notificationArray[buttonRow!].action != "follow" &&  notificationArray[buttonRow!].action != "friend" {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            mine = false
            
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let controller:oneVideo = self.storyboard!.instantiateViewController(withIdentifier: "oneVideo") as! oneVideo
            
            self.navigationController?.pushViewController(controller, animated: true)
            
            
            
            MolocateVideo.getVideo(notificationArray[buttonRow!].target, completionHandler: { (data, response, error) in
                DispatchQueue.main.async{
                    MoleGlobalVideo = data!
                    controller.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            })
            
        }else {
            pressedUsername(sender)
        }
        
    }
    
    
    
    func labelTapped(_ sender: UITapGestureRecognizer){
        //print("play")
        let buttonRow = sender.view!.tag
        
        var multipleAttributes2 = [String : NSObject]()
        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Medium", size: 14.0)
        
        let sizeLabel = UILabel()
        let text=notificationArray[buttonRow].actor
        
        sizeLabel.attributedText = NSAttributedString(string: text , attributes: multipleAttributes2)
        
        let touchPoint = sender.location(in: sender.view)
        
        let validFrame = CGRect(x: 0, y: 0, width: sizeLabel.intrinsicContentSize.width, height: 25);
        
        if validFrame.contains(touchPoint){
            pressedUsername(sender)
        }else{
            pressedCell(sender)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "closeSideBar"), object: nil)
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
    
    
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = true

    }
    
}
