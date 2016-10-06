//
//  findFriendController.swift
//  Molocate
//
//  Created by Kagan Cenan on 21.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class findFriendController: UIViewController,UITableViewDelegate , UITableViewDataSource {

    
    var tableView: UITableView!
    var backgroundLabel:UILabel!
    var faceButton:UIButton!
    var randButton:UIButton!
    var userRelations = MoleUserRelations()
    var userRelationsFace = MoleUserRelations()
    var userRelationsRandom = MoleUserRelations()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        
        if MoleCurrentUser.isFaceUser {
            tableView.frame = CGRect(x: 0, y: 44, width: self.view.frame.width, height: self.view.frame.height-60-(self.navigationController?.navigationBar.frame.height)!)
            backgroundLabel = UILabel()
            backgroundLabel.frame = CGRect( x: 0 , y: 0 , width: MolocateDevice.size.width , height: 44)
            backgroundLabel.backgroundColor = UIColor.white
            backgroundLabel.layer.borderWidth = 0.2
            backgroundLabel.layer.masksToBounds = false
            backgroundLabel.layer.borderColor = swiftColor.cgColor
            view.addSubview(backgroundLabel)
            
            
            
            faceButton = UIButton()
            faceButton.frame = CGRect(x: MolocateDevice.size.width / 2  ,y: 7 , width: MolocateDevice.size.width / 2 - 20, height: 30)
            faceButton.setTitleColor(UIColor.black, for: UIControlState())
            faceButton.contentHorizontalAlignment = .center
            faceButton.setTitle("Önerilen", for: UIControlState())
            faceButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
            faceButton.addTarget(self, action: #selector(findFriendController.pressedFace(_:)), for: UIControlEvents.touchUpInside)
            view.addSubview(faceButton)
            
            randButton = UIButton()
            randButton.frame = CGRect(x: 20 ,y: 7 , width: MolocateDevice.size
                .width / 2 - 20, height: 30)
            randButton.setTitleColor(UIColor.white, for: UIControlState())
            randButton.contentHorizontalAlignment = .center
            randButton.setTitle("Facebook", for: UIControlState())
            randButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
            
            randButton.addTarget(self, action: #selector(findFriendController.pressedRand(_:)), for: UIControlEvents.touchUpInside)
            view.addSubview(randButton)
            randButton.backgroundColor = swiftColor2
            randButton.isHidden = false
            faceButton.backgroundColor = swiftColor3
            faceButton.isHidden = false
            backgroundLabel.isHidden = false
            
            
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.faceButton.frame
            rectShape.position = self.faceButton.center
            rectShape.path = UIBezierPath(roundedRect: self.faceButton.bounds, byRoundingCorners: [.bottomRight , .topRight] , cornerRadii: CGSize(width: 8, height: 8)).cgPath
            rectShape.borderWidth = 1.0
            rectShape.borderColor = swiftColor2.cgColor
            self.faceButton.layer.backgroundColor = swiftColor3.cgColor
            //Here I'm masking the textView's layer with rectShape layer
            self.faceButton.layer.mask = rectShape
            
            let rectShape2 = CAShapeLayer()
            rectShape2.bounds = self.randButton.frame
            rectShape2.position = self.randButton.center
            rectShape2.path = UIBezierPath(roundedRect: self.randButton.bounds, byRoundingCorners: [.bottomLeft , .topLeft] , cornerRadii: CGSize(width: 8, height: 8)).cgPath
            rectShape2.borderWidth = 1.0
            rectShape2.borderColor = swiftColor2.cgColor
            self.randButton.layer.backgroundColor = swiftColor2.cgColor
            self.randButton.layer.mask = rectShape2

        } else {
            tableView.frame = self.view.frame
        }
        view.addSubview(tableView)
        self.navigationItem.title = "Kişiler"
        // Do any additional setup after loading the view.
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRelations.relations.count
    }
    
    func pressedFace(_ sender: UIButton) {
        self.faceButton.backgroundColor = swiftColor2
        self.randButton.backgroundColor = swiftColor3
        userRelations = userRelationsRandom
        tableView.reloadData()
    }
    
    func pressedRand(_ sender: UIButton) {
        self.faceButton.backgroundColor = swiftColor3
        self.randButton.backgroundColor = swiftColor2
        userRelations = userRelationsFace
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = searchUsername(style: UITableViewCellStyle.default, reuseIdentifier: "cellface")
        
        cell.profilePhoto.tag = (indexPath as NSIndexPath).row
        cell.nameLabel.tag = (indexPath as NSIndexPath).row
        cell.followButton.tag = (indexPath as NSIndexPath).row
        cell.usernameLabel.tag = (indexPath as NSIndexPath).row
        cell.usernameLabel.text = userRelations.relations[(indexPath as NSIndexPath).row].username
        cell.nameLabel.text = userRelations.relations[(indexPath as NSIndexPath).row].name
        
        
        //bak bunaaaa  cell.nameLabel.text = userRelations.relations[indexPath.row]
        
        if(userRelations.relations[(indexPath as NSIndexPath).row].picture_url.absoluteString != ""){
            cell.profilePhoto.sd_setImageWithURL(userRelations.relations[indexPath.row].picture_url, forState: UIControlState.Normal)
        }else{
            cell.profilePhoto.setImage(UIImage(named: "profile"), for: UIControlState())
        }
        
        cell.profilePhoto.addTarget(self, action: #selector(findFriendController.pressedProfileSearch(_:)), for: UIControlEvents.touchUpInside)
        
        
        if(!userRelations.relations[(indexPath as NSIndexPath).row].is_following){
            cell.followButton.setBackgroundImage(UIImage(named: "follow"), for: UIControlState())

        } else {
            cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), for: UIControlState())
        }
        cell.followButton.addTarget(self, action: #selector(findFriendController.pressedFollow(_:)), for: .touchUpInside)
        
        
        
        if(userRelations.relations[(indexPath as NSIndexPath).row].username == MoleCurrentUser.username){
            cell.followButton.isHidden = true
        }
        
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! searchUsername
        pressedProfileSearch(cell.profilePhoto)
    }
    
    
    func pressedProfileSearch(_ sender:UIButton){
        
        let username = userRelations.relations[sender.tag].username
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        if username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        controller.classUser.username = username
        controller.classUser.profilePic =  userRelations.relations[sender.tag].picture_url
        controller.classUser.isFollowing = userRelations.relations[sender.tag].is_following
        
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
    }

    
    

    
    func pressedFollow(_ sender: UIButton){
        let Row = sender.tag
        //print(userRelations.relations[Row].is_following)
        if !userRelations.relations[Row].is_following {
        MolocateAccount.follow(userRelations.relations[Row].username) { (data, response, error) in
            
        }
        userRelations.relations[Row].is_following = true
        } else {
            MolocateAccount.unfollow(userRelations.relations[Row].username, completionHandler: { (data, response, error) in
                
            })
           userRelations.relations[Row].is_following = false
        }
        tableView.reloadData()
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
