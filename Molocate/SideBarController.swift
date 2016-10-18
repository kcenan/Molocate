

import UIKit

var choosedIndex = 2
let arkarenk = UIColor(netHex: 0x212429)

class SideBarController: UITableViewController {
    
    
    let foursquareLabel : UILabel = UILabel()
    let foursquareLabel2 : UILabel = UILabel()
    
    var menuArray = ["HABER","KEŞFET","BİLDİRİM","PROFİL"]
    var tableData: [String] = ["home", "explore", "notifications","avatar"]
    let cellIdentifier = "cell"
    var attractionImages = [String]()
    var profile_picture: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let  screenSize = MolocateDevice.size
        
        tableView.separatorStyle = .singleLineEtched
        self.tableView.separatorColor = UIColor.lightText
        self.tableView.backgroundColor = arkarenk
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        foursquareLabel.frame = CGRect( x: screenSize.width / 5 - 30   , y: 9 * screenSize.height / 10  , width: 60 , height: 15)
        foursquareLabel.font = UIFont(name: "AvenirNext-Regular", size: 8)
        foursquareLabel.textAlignment = .center
        foursquareLabel.text = "POWERED BY"
        foursquareLabel.textColor = UIColor.white
        self.tableView.addSubview(foursquareLabel)
        
        foursquareLabel2.frame = CGRect( x: screenSize.width / 5 - 30   , y: 9 * screenSize.height / 10  + 12 , width: 60 , height: 15)
        foursquareLabel2.font = UIFont(name: "AvenirNext-Regular", size: 8)
        foursquareLabel2.textAlignment = .center
        foursquareLabel2.text = "FOURSQUARE"
        foursquareLabel2.textColor = UIColor.white
        self.tableView.addSubview(foursquareLabel2)
        
        let imageName = "foursquare.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: screenSize.width / 5 - 11   , y: 9 * screenSize.height / 10 - 28 , width: 24 , height: 19.2 * 1.5)
        self.tableView.addSubview(imageView)
        
        
        
        
        MolocateAccount.getCurrentUser { (data, response, error) in
            DispatchQueue.main.async(execute: {
              self.tableView.reloadData()
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenSize: CGRect = UIScreen.main.bounds
        if indexPath.row == 0{
            
            return 86 + screenSize.size.width * 2 / 10
        }
        else{
            //let screenSize: CGRect = UIScreen.mainScreen().bounds
            var rowHeight:CGFloat = 0
            if is4s {
                rowHeight = screenSize.height / 7
            } else {
                rowHeight = screenSize.height / 8
            }
            return rowHeight}
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
            let cell =  sideProfilePic(style: UITableViewCellStyle.value1, reuseIdentifier: "customCell")
            
            if profile_picture != nil {
                cell.profilePhoto.image = profile_picture
                
            }else if let thumbnail = UserDefaults.standard.object(forKey: "thumbnail_url"){
                profile_picture = UIImage(data: thumbnail as! Data)
                cell.profilePhoto.image = profile_picture
            }else{
                cell.profilePhoto.sd_setImage(with: MoleCurrentUser.profilePic)
            }
            
            cell.username.text = MoleCurrentUser.username
            let bgColorView2 = UIView()
            
            bgColorView2.backgroundColor = UIColor.black
            cell.selectedBackgroundView = bgColorView2
            cell.backgroundColor = UIColor(netHex: 0x272B2F)
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! sideCell
            let bgColorView = UIView()
            
            bgColorView.backgroundColor = swiftColor
            
            cell.selectedBackgroundView = bgColorView
            cell.label?.text = self.menuArray[indexPath.row-1]
            cell.backgroundColor = arkarenk
            cell.imageFrame.image = UIImage(named: tableData[indexPath.row-1 ])
            cell.label.textColor = UIColor.white
            
            //print(choosedIndex)
            //print(indexPath.row)
            if choosedIndex == indexPath.row {
                cell.backgroundColor = swiftColor
            }else{
                //cell.backgroundColor = swiftColor2
            }
            return cell}
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        choosedIndex = indexPath.row
        
  
        self.parent?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedIndex = choosedIndex
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "closeSideBar"), object: nil )
        
        tableView.reloadData()
        
        switch (choosedIndex){
            
        case 0:
            
            if MoleUserToken != nil{
                MolocateAccount.getCurrentUser({ (data, response, error) in
                })
            }

        case 1: break
            //self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        case 2: break
            //self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        case 3: break
            
            //self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()

        default:
            break;
        }
        
        
    }
    
    
    
    
  
    
}
