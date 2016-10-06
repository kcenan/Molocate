//
//  findVenueController.swift
//  Molocate
//
//  Created by Kagan Cenan on 15.08.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class findVenueController: UIViewController,UITableViewDelegate , UITableViewDataSource {
    
    
    var tableView: UITableView!
    var backgroundLabel:UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var venues = [MolePlace]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = self.view.frame
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        self.navigationItem.title = "Mekanlar"
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return venues.count
    }
    

    
    
    func tableView(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = searchVenue(style: .Default, reuseIdentifier: "cellface")
        cell.nameLabel.text = venues[(indexPath as NSIndexPath).row].name
        cell.addressNameLabel.text = venues[(indexPath as NSIndexPath).row].address
        cell.distanceLabel.text = venues[(indexPath as NSIndexPath).row].distance
//        cell.profilePhoto.tag = indexPath.row
//        cell.nameLabel.tag = indexPath.row
//        cell.followButton.tag = indexPath.row
//        cell.usernameLabel.tag = indexPath.row
//        cell.usernameLabel.text = userRelations.relations[indexPath.row].username
//        cell.nameLabel.text = userRelations.relations[indexPath.row].name
//        
//
//        
        
        return cell
        
    }
    func tableView(tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! searchUsername
        pressedPlace(venues[(indexPath as NSIndexPath).row].id)
        
    }
    
    
    func pressedPlace(placeId: String) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
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

    

    
    
    
    

    
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

