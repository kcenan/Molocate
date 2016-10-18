//
//  FacebookFriends.swift
//  Molocate
//
//  Created by Ekin Akyürek on 17/06/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class FacebookFriends: UIViewController {

    var userRelations = MoleUserRelations()
    var continueButton = UIButton()
    var facebookInfo = UILabel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        MolocateUtility.setStatusBarBackgroundColor(swiftColor)
 
        tableView.frame = CGRect(x: 0, y: 60, width: MolocateDevice.size.width, height: MolocateDevice.size.height-60-(self.navigationController?.navigationBar.frame.height)!)
        
        facebookInfo.frame = CGRect(x: 0, y: 16, width: MolocateDevice.size.width, height: 44)
        facebookInfo.textAlignment = .center
        facebookInfo.textRect(forBounds: CGRect(x: 0, y: 20, width: MolocateDevice.size.width, height: 20), limitedToNumberOfLines: 1)
        facebookInfo.textColor = UIColor.white
        facebookInfo.font = UIFont(name: "AvenirNext-DemiBold.ttf", size: 17)
        facebookInfo.backgroundColor = swiftColor
        facebookInfo.text = "Önerilen kişiler"
        self.view.addSubview(facebookInfo)
        
        
        continueButton.frame = CGRect(x: 0, y: MolocateDevice.size.height-44, width: MolocateDevice.size.width, height: 44)
        continueButton.setTitleColor(UIColor.white, for: UIControlState())
        continueButton.backgroundColor = arkarenk
        continueButton.setTitle("Devam Et", for: UIControlState())
        continueButton.addTarget(self, action: #selector(FacebookFriends.pressedContinue(_:)), for: .touchUpInside)
        
        self.view.addSubview(continueButton)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    

    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRelations.relations.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
       
        let cell = searchUsername(style: UITableViewCellStyle.default, reuseIdentifier: "cellface")
        
        cell.profilePhoto.tag = indexPath.row
        cell.nameLabel.tag = indexPath.row
        cell.followButton.tag = indexPath.row
        cell.usernameLabel.tag = indexPath.row
        cell.usernameLabel.text = userRelations.relations[indexPath.row].username
        cell.nameLabel.text = userRelations.relations[indexPath.row].name
        
        
        //bak bunaaaa  cell.nameLabel.text = userRelations.relations[indexPath.row]
        
        if(userRelations.relations[indexPath.row].picture_url?.absoluteString != ""){
            cell.profilePhoto.sd_setImage(with: userRelations.relations[indexPath.row].picture_url, for: UIControlState.normal)
        }else{
            cell.profilePhoto.setImage(UIImage(named: "profile"), for: UIControlState())
        }
        
        
        
        if(!userRelations.relations[indexPath.row].is_following){
            cell.followButton.setBackgroundImage(UIImage(named: "follow"), for: UIControlState())
            cell.followButton.addTarget(self, action: #selector(FacebookFriends.pressedFollow(_:)), for: .touchUpInside)
        } else {
            cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), for: UIControlState())
        }

        
        
        
        if(userRelations.relations[indexPath.row].username == MoleCurrentUser.username){
            cell.followButton.isHidden = true
        }
        
        
        return cell
       
    }
 
    func pressedContinue(_ sender: UIButton){
        self.performSegue(withIdentifier: "facebookAfter", sender: self)
    }
    
    func pressedFollow(_ sender: UIButton){
        let Row=sender.tag

        MolocateAccount.follow(userRelations.relations[Row].username) { (data, response, error) in
            
        }

        userRelations.relations[Row].is_following = true
  
        tableView.reloadRows(at: [IndexPath(row: Row, section: 0)], with: .none)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
