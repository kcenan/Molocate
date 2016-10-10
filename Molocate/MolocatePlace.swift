//  MolocatePlace.swift
//  Molocate
import Foundation

var MoleNextPlaceVideos: URL?

struct MolePlace{
    var id: String = ""
    var name: String = ""
    var caption: String = ""
    var follower_count = 0;
    var following_count = 0;
    var tag_count = 0;
    var picture_url:URL = URL(string:"")!
    var placeVideos: [MoleVideoInformation] = [MoleVideoInformation]()
    var city = ""
    var address = ""
    var is_following = 0
    var web_site = ""
    var video_count = 0
    var phone = ""
    var videoArray = [MoleVideoInformation]()
    var lat = 0.0
    var lon = 0.0
    var distance = ""
}


open class MolocatePlace {
    static let timeout = 8.0
    class func followAPlace(_ place_id: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "place/api/follow/?place_id=" + (place_id as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    completionHandler(result["result"] as? String , response , nsError as NSError?  )
                } catch{
                    completionHandler("fail" , nil , nsError as NSError?  )
                    if debug {print("JsonError:: in MolocatePlace.followAPlace()")}
                }
            }else{
                completionHandler("fail" , nil , error as NSError?  )
                if debug {print("RequestError:: in MolocatePlace.followAPlace()")}

            }
            
        })
        
        task.resume()
    }
    
    class func unfollowAPlace(_ place_id: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        let url = URL(string: MolocateBaseUrl + "place/api/unfollow/?place_id=" + (place_id as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    completionHandler(result["result"] as? String , response , nsError as NSError?  )
                } catch{
                    completionHandler("fail" , nil , nsError as NSError?  )
                    if debug {print("JsonError:: in MolocatePlace.unFollowAPlace()")}
                }
            }else{
                completionHandler("fail" , nil , error   as NSError?)
                if debug {print("RequestError:: in MolocatePlace.unFollowAPlace()")}
                
            }
            
        })
        task.resume()
    }
    
    
    class func getPlace(_ placeid: String, completionHandler: @escaping (_ data: MolePlace, _ response: URLResponse?, _ error: NSError?) -> ()) {
        
        let url = URL(string: MolocateBaseUrl + "place/api/get_place/?place_id=" + (placeid as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
                let nsError = error;
                
                do {
                    
                    let item = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    
                    var place = MolePlace()
                    let exist = item.index(forKey: "result")
                    
                    if  exist != nil{
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
                        place.picture_url = item["picture_url"] is NSNull ? URL(string: "")!:URL(string: item["picture_url"] as! String)!
                        place.phone = item["phone"] as! String
                        place.web_site = item["web_site"] as! String
                        let lon = item["longitude"] as! String
                        let lat = item["latitude"] as! String
                        place.lon = CFStringGetDoubleValue(lon as CFString!)
                        place.lat = CFStringGetDoubleValue(lat as CFString!)
                      
                        if (item.index(forKey: "next_place_videos") != nil){
                            if item["next_place_videos"] is NSNull {
                                //print("next is null")
                                MoleNextPlaceVideos = nil
                            }else {
                                let nextStr = item["next_place_videos"] as! String
                                MoleNextPlaceVideos = URL(string: nextStr)!
                            }
                        }
                        
                        let videos = item["place_videos"] as! [Dictionary<String, AnyObject>]
                        
                        for i in 0..<videos.count {
                            let item = videos[i]
                            let owner_user = item["owner_user"] as!  [String: AnyObject]
                            let placeTaken = item["place_taken"] as! [String:String]
                            var videoStr = MoleVideoInformation()
                            videoStr.id = item["video_id"] as! String
                            videoStr.urlSta = URL(string:  item["video_url"] as! String)!
                            videoStr.username = owner_user["username"] as! String
                            videoStr.location = placeTaken["name"]!
                            videoStr.locationID = placeTaken["place_id"]!
                            videoStr.caption = item["caption"] as! String
                            videoStr.likeCount = item["like_count"] as! Int
                            videoStr.commentCount = item["comment_count"] as! Int
                            videoStr.category = item["category"] as! String
                            videoStr.isLiked = item["is_liked"] as! Int
                            videoStr.isFollowing = owner_user["is_following"] as! Int
                            videoStr.userpic = owner_user["picture_url"] is NSNull ? URL(string: "")!:URL(string: owner_user["picture_url"] as! String)!
                            videoStr.dateStr = item["date_str"] as! String
                            videoStr.taggedUsers = item["tagged_users"] as! [String]
                            
                            videoStr.thumbnailURL = URL(string:item["thumbnail"] as! String)!
                            place.videoArray.append(videoStr)
                            
                        }
                    }
                    
                    completionHandler( place, response , nsError as NSError?  )
                } catch{
                    completionHandler(MolePlace() , nil , nsError as NSError?  )
                    if debug {print("JsonError:: in MolocatePlace.getPlace()")}
                }
            
            }else{
                completionHandler(MolePlace() , nil , error as NSError?  )
                if debug {print("RequestError:: in MolocatePlace.getPlace()")}
            }
        })
        
        task.resume()
    }
    
    
    class func getNearbyPlace(_ placeLat: Float,placeLon: Float, completionHandler: @escaping (_ data: [MolePlace], _ response: URLResponse?, _ error: NSError?) -> ()) {
        
        let url = URL(string: MolocateBaseUrl +  "place/api/nearby_places/?lat=\(placeLat)&lon=\(placeLon)")
        var request = URLRequest(url: url!)
        
        
        
        
        
        
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
           // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error;
                var lastPlaces = [MolePlace]()
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                     if result.index(forKey: "results") != nil{
                    let places = result["results"] as! [Dictionary<String,String>]
                    
                    for item in places {
                        var place = MolePlace()
                        place.id = item["place_id"]!
                        place.name = item["name"]!
                        place.distance = item["distance"]!
                        place.address = item["address"]!
                        lastPlaces.append(place)
                        
                    }
                    }
                    completionHandler(lastPlaces, response , nsError as NSError?  )
                } catch{
                    completionHandler([MolePlace]() , nil , nsError as NSError?  )
                    if debug {print("JsonError:: in MolocatePlace.getPlace()")}
                }
                
            }else{
                completionHandler([MolePlace]() , nil , error as NSError?  )
                if debug {print("RequestError:: in MolocatePlace.getPlace()")}
            }
        })
        
        task.resume()
    }
    
    
    class func searchPlace(_ str:String,placeLat: Float,placeLon: Float, completionHandler: @escaping (_ data: [MolePlace], _ response: URLResponse?, _ error: NSError?) -> ()) {
        var url = URLComponents(string: MolocateBaseUrl + "/place/api/search_place/")
        url?.queryItems = [URLQueryItem(name: "name", value: str),URLQueryItem(name: "lat", value: "\(placeLat)"),URLQueryItem(name: "lon", value: "\(placeLon)")]
        print(url?.url)
        var request = URLRequest(url: (url?.url)!)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error;
                var lastPlaces = [MolePlace]()
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    if result.index(forKey: "results") != nil{
                        let places = result["results"] as! [Dictionary<String, String>]
                        
                        for item in places {
                            var place = MolePlace()
                            place.id = item["place_id"]!
                            place.name = item["name"]!
                            place.distance = item["distance"]!
                            place.address = item["address"]!
                            lastPlaces.append(place)
                            
                        }
                    }
                    completionHandler(lastPlaces, response , nsError as NSError?  )
                } catch{
                    completionHandler([MolePlace]() , nil , nsError as NSError?  )
                    if debug {print("JsonError:: in MolocatePlace.getPlace()")}
                }
                
            }else{
                completionHandler([MolePlace]() , nil , error as NSError?  )
                if debug {print("RequestError:: in MolocatePlace.getPlace()")}
            }
        })
        
        task.resume()
    }

    
    
    

    
    
    class func getFollowers(_ nextUrl: String = "", placeId: String, completionHandler: @escaping (_ data: MoleUserRelations, _ response: URLResponse?, _ error: NSError?, _ count: Int, _ next: String?, _ previous: String? ) -> ()) {
        var url  = URL(string: "")!
        if(nextUrl == ""){
            url = URL(string: MolocateBaseUrl + "place/api/get_followers/?place_id=" + (placeId as String) )!
        }else{
            url = URL(string:nextUrl)!
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error;
                
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    if result.index(forKey: "results") != nil{
                        let count: Int = result["count"] as! Int
                        let next =  result["next"] is NSNull ? "":result["next"] as? String
                        let previous =  result["previous"] is NSNull ? "":result["previous"] as? String
                        let results = result["results"] as! NSArray
                        var followers = MoleUserRelations()
                        followers.totalCount = count
                        var friends: Array<MoleUserFriend> = Array<MoleUserFriend>()
                    
                            for i in 0..<results.count{
                                var friend = MoleUserFriend()
                                let thing = results[i] as! [String:AnyObject]
                                friend.username = thing["username"] as! String
                                friend.picture_url = thing["picture_url"] is NSNull ? URL(string: "")!:URL(string: thing["picture_url"] as! String)!
                                let thumbnail = thing["thumbnail_url"] as! String
                                
                                friend.thumbnail_url = thumbnail == "" ? friend.picture_url:URL(string: thumbnail)!
                                let isfollowing = thing["is_following"] as! Int
                                
                                friend.is_following = isfollowing == 0 ? false:true
                                if(friend.username==MoleCurrentUser.username){
                                    friend.is_following = true
                                }
                                
                                
                                friends.append(friend)
                            }
                        
                        
                        followers.relations = friends
                        
                        completionHandler(followers , response , nsError as NSError?, count, next, previous  )
                    }else{
                        completionHandler(MoleUserRelations() , nil , nsError as NSError?, 0, nil, nil  )
                        if debug {print("ServerDataError:: in MolocatePlace.getFollowers()")}

                    }
                } catch{
                    completionHandler(MoleUserRelations() , nil , nsError as NSError?, 0, nil, nil  )
                    if debug {print("JsonError:: in MolocatePlace.getFollowers()")}
                }
            }else{
                completionHandler(MoleUserRelations() , nil , error as NSError?, 0, nil, nil  )
                if debug {print("RequestError:: in MolocatePlace.getFollowers()")}
            }
            
        })
        task.resume()
    }
    
    
}
