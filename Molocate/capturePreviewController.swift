//
//  capturePreviewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 5.12.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit



class capturePreviewController: UIViewController, UITextFieldDelegate, UITableViewDelegate ,UITableViewDataSource,UICollectionViewDelegate ,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var toolBar: UIToolbar!
    struct placeVar {
        var name: String!
        var province: String
        var FormattedAdress: String!
        var latitude: Float!
        var longitude: Float!
        var rating: Float!
        
    }
    let screenSize: CGRect = UIScreen.mainScreen().bounds
   // var comment : UITextField!
   
    @IBOutlet var collectionView: UICollectionView!
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var autocompleteUrls = [String]()
    var videoURL: NSURL?
//    private var asset: AVAsset?
//    private var playerItem: AVPlayerItem?
//    

    @IBOutlet var textField: UITextField!
    var categories = ["Hepsi","Eğlence","Yemek","Gezinti","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]

    @IBOutlet var placeTable: UITableView!
    @IBAction func post(sender: AnyObject) {
        player?.pause()
        var videodata = NSData()
        do {
        videodata = try NSData(contentsOfURL: videoURL!, options: NSDataReadingOptions.DataReadingUncached)
        } catch _{
            print("error")
        }
            //let videodata = NSData(contentsOfURL: videoURL!)
        let headers = [
            "authorization": "Token \(userToken!)",
            "content-type": "/*/",
            "content-disposition": "attachment;filename=deneme.mp4",
            "cache-control": "no-cache"
        ]
        let request = NSMutableURLRequest(URL: NSURL(string: "http://molocate.elasticbeanstalk.com/video/upload/")!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData,
            timeoutInterval: 10.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = videodata
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                    
                    print("Result -> \(result)")
                    let statue = result["result"] as! String
                    if(statue == "success"){
                        let videoId = result["video_id"] as! String
                        let videoUrl = result["video_url"] as! String
                        print(videoUrl)
                        let json = [
                            "video_id": videoId,
                            "video_url": videoUrl,
                            "caption": "This city is awesome:)",
                            "category": "travel",
                            "tagged_users": [],
                            "location": [
                                [
                                    "id": "mekmaekfmaıhjagej3ıo45j3kt348t3gkg",
                                    "latitude": "35.342643",
                                    "longitude": "32.345236",
                                    "name": "Milas Merkez Kafasına göre herkes",
                                    "address": "Milas aq"
                                ]
                            ]
                        ]
                        
                        let newheaders = [
                            "authorization": "Token \(userToken!)",
                            "content-type": "application/json",
                            "cache-control": "no-cache"
                        ]
                        
                        do {
                            
                            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
                            print(NSString(data: jsonData, encoding: NSUTF8StringEncoding))
                            
                            // create post request
                            _ = NSURL(string: "http://molocate.elasticbeanstalk.com/video/update/")!
                            let request = NSMutableURLRequest(URL: NSURL(string: "http://molocate.elasticbeanstalk.com/video/update/")!,
                                cachePolicy: .UseProtocolCachePolicy,
                                timeoutInterval: 10.0)
                            request.HTTPMethod = "POST"
                            request.allHTTPHeaderFields = newheaders
                            request.HTTPBody = jsonData
                            
                            
                            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                                print(response)
                                print("=========================================")
                                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                                dispatch_async(dispatch_get_main_queue(), {
                                    if error != nil{
                                        print("Error -> \(error)")
                                        
                                        return
                                    }
                                    
                                    do {
                                        
                                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                                        
                                        
                                        print("Result -> \(result)")
                                        
                                        
                                        
                                    } catch {
                                        print("Error -> \(error)")
                                    }
                                })
                            }
                            
                            task.resume()
                            
                            
                            
                            
                        } catch {
                            print(error)
                            
                            
                        }
                        
                        
                        
                    } else{
                        //                        self.displayAlert("Hata", message: result["result"] as! String)
                        //                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        //                        self.activityIndicator.stopAnimating()
                        //                        self.activityIndicator.hidesWhenStopped = true
                    }
                    
                    
                    
                    
                } catch {
                    print("Error -> \(error)")
                    
                }
            }
        })
        
        dataTask.resume()
        
        
        
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(videoPath!)  //.removeItemAtURL(fakeoutputFileURL!)
            dispatch_async(dispatch_get_main_queue()) {
                print("siiiiil")
            self.performSegueWithIdentifier("finishUpdate", sender: self)
            
            }
        } catch _ {
            
        }
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
//        comment = UITextField(frame: CGRectMake(0, 159, screenSize.width, screenSize.height - screenSize.width - 208))
//        comment.attributedPlaceholder = .None
//        comment.textColor = UIColor.blackColor()
//        comment.delegate = self
//        comment.borderStyle = UITextBorderStyle.RoundedRect
//        comment.clearsOnBeginEditing = true
//        view.addSubview(comment)
//        
        
      
//        comment = UITextField()
//        //4sde sıkıntı olacak gibi
//        comment.frame = CGRectMake(0, 159, screenSize.width, screenSize.height - screenSize.width - 208)
//        comment.textColor = UIColor.blackColor()
//       
//        comment.textAlignment = .Left
//        comment.sizeToFit()
//        self.view.addSubview(comment)
        
        
        let index = NSIndexPath(forRow: 0, inSection: 0)
        self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        collectionView.contentSize.width = screenSize.size.width * 2
        collectionView.backgroundColor = swiftColor3
        
        dispatch_async(dispatch_get_main_queue()) {
            
            //self.textField.backgroundColor = UIColor.whiteColor()
            
            self.textField.autocapitalizationType = .Words
        }
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismisKeyboard")
//        view.addGestureRecognizer(tap)
//        
        

        
        
        textField.delegate = self
        
        placeTable.delegate = self
        placeTable.dataSource = self
        placeTable.scrollEnabled = true
        placeTable.hidden = true
        
       // print(deviceLat)
        videoURL = NSURL(fileURLWithPath: videoPath!, isDirectory: false)
        //videoURL = NSURL(fileURLWithPath: videoPath!)
        let asset = AVAsset(URL: videoURL!)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        _ = (self.view.frame.height-self.view.frame.width)/2
        let newRect = CGRect(x: 0, y: 164, width: self.view.frame.width, height: self.view.frame.width)
        playerLayer?.frame = newRect
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        
        view.layer.addSublayer(playerLayer!)
        player?.play()
        view.layer.addSublayer(placeTable.layer)
        view.layer.addSublayer(textField.layer)
        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let a : CGSize = CGSize.init(width: screenSize.width / 6, height: 44)
        
        return a
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myCell : captureCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! captureCollectionCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = swiftColor2
        myCell.selectedBackgroundView = backgroundView
        
        myCell.layer.borderWidth = 0
        myCell.backgroundColor = swiftColor3
        myCell.label?.text = categories[indexPath.row]
        myCell.frame.size.width = screenSize.width / 6
        myCell.label.textAlignment = .Center
        
        
        
        return myCell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
       
        
        
        print(indexPath.row)
        
        
        
        
        //  cell.backgroundColor = UIColor.purpleColor()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        placeTable.hidden = false
        let substring = (self.textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        searchAutocompleteEntriesWithSubstring(substring)
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        placeTable.hidden = false
        autocompleteUrls = placesArray
        placeTable.reloadData()
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autocompleteUrls.removeAll(keepCapacity: false)
        
        
        for curString in placesArray
        {
            print(curString)
            let myString: NSString! = curString as NSString
            let substringRange: NSRange! = myString.rangeOfString(substring)
            print(substringRange.location)
            if (substringRange.location == 0)
            {
                print("oldu")
                autocompleteUrls.append(curString)
            }
        }
        
            placeTable.reloadData()
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteUrls.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        var cell = (tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier))! as? UITableViewCell
        
        if let _ = cell
        {
            let index = indexPath.row as Int
            cell!.textLabel!.text = autocompleteUrls[index]
        } else
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: autoCompleteRowIdentifier)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        textField.text = selectedCell.textLabel!.text
        placeTable.hidden = true
        self.view.endEditing(true)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.view.endEditing(true)
            placeTable.hidden = true
            // ...
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
        
    }
    
    @IBAction func backToCamera(sender: AnyObject) {
       
        let cleanup: dispatch_block_t = {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(self.videoURL!)
            
            } catch _ {}
            
        }
        cleanup()
        performSegueWithIdentifier("backToCamera", sender: self)
        placesArray.removeAll()

        
        
    }
//
//    func dismisKeyboard(){
//        view.endEditing(true)
//        self.placeTable.hidden = true
//    }

    


}
