//  MolocatePlace.swift
//  Molocate

import Foundation

struct MolePlace{
    var id: String = ""
    var name: String = ""
    var caption: String = ""
    var follower_count = 0;
    var following_count = 0;
    var tag_count = 0;
    var picture_url:NSURL = NSURL()
    var placeVideos: [MoleVideoInformation] = [MoleVideoInformation]()
    var city = ""
    var address = ""
    var is_following = 0
    var web_site = ""
    var video_count = 0
    var phone = ""
    var videoArray = [MoleVideoInformation]()
}


public class MolocatePlace {
    class func followAPlace(place_id: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: MolocateBaseUrl + "place/api/follow/?place_id=" + (place_id as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.followAPlace()")
            }
            
        }
        
        task.resume()
    }
    
    class func unfollowAPlace(place_id: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: MolocateBaseUrl + "place/api/unfollow/?place_id=" + (place_id as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.unfollowAPlace()")
            }
            
        }
        
        task.resume()
    }
    
    
    class func getPlace(placeid: String, completionHandler: (data: MolePlace, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl + "place/api/get_place/?place_id=" + (placeid as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            do {
                
                let item = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                var place = MolePlace()
                if let notExist = item["result"]{
                    place.name = "notExist"
                } else{
                    
                    place.id = placeid
                    place.name = item["name"] as! String
                    place.city = item["city"] as! String
                    place.is_following = item["is_following"] as! Int
                    place.address = item["address"] as! String
                    place.video_count = item["video_count"] as! Int
                    place.follower_count = item["follower_count"] as! Int
                    place.caption = item["caption"] as! String
                    place.picture_url = item["picture_url"] is NSNull ? NSURL():NSURL(string: item["picture_url"] as! String)!
                    place.phone = item["phone"] as! String
                    place.web_site = item["web_site"] as! String
                    let videos = item["place_videos"] as! NSArray
                    if (item["next_place_videos"] != nil){
                        if item["next_place_videos"] is NSNull {
                            print("next is null")
                            nextU = nil
                        }else {
                            let nextStr = item["next_place_videos"] as! String
                            //print(nextStr)
                            nextU = NSURL(string: nextStr)!
                        }
                    }
                
                    for item in videos {
                        //print(item)
                        var videoStr = MoleVideoInformation()
                        //print(item)
                        videoStr.id = item["video_id"] as! String
                        videoStr.urlSta = NSURL(string:  item["video_url"] as! String)!
                        videoStr.username = item["owner_user"]!!["username"] as! String
                        videoStr.location = item["place_taken"]!!["name"] as! String
                        videoStr.locationID = item["place_taken"]!!["place_id"] as! String
                        videoStr.caption = item["caption"] as! String
                        videoStr.likeCount = item["like_count"] as! Int
                        videoStr.commentCount = item["comment_count"] as! Int
                        videoStr.category = item["category"] as! String
                        videoStr.isLiked = item["is_liked"] as! Int
                        let jsonObject = item["owner_user"]
                        videoStr.isFollowing = jsonObject!!["is_following"] as! Int
                        videoStr.userpic = jsonObject!!["picture_url"] is NSNull ? NSURL():NSURL(string: jsonObject!!["picture_url"] as! String)!
                        videoStr.dateStr = item["date_str"] as! String
                        videoStr.taggedUsers = item["tagged_users"] as! [String]
                        
                        videoStr.thumbnailURL = NSURL(string:item["thumbnail"] as! String)!
                        place.videoArray.append(videoStr)
                        
                    }
                }
                
                completionHandler(data: place, response: response , error: nsError  )
            } catch{
                completionHandler(data: MolePlace() , response: nil , error: nsError  )
                print("Error:: in mole.getUser()")
            }
            
            
        }
        
        task.resume()
    }

    
}