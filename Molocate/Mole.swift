import UIKit
import SystemConfiguration

let baseUrl = "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/"

let categoryDict = ["Eğlence":"fun","Yemek":"food","Gezi":"travel","Moda":"fashion" , "Güzellik":"makeup", "Spor": "Sport","Etkinlik": "Event","Kampüs":"university", "Hepsi":"all"]
struct videoInf{
    var id: String = ""
    var username:String = ""
    var category:String = ""
    var location:String = ""
    var locationID:String = ""
    var caption:String = ""
    var urlSta:NSURL = NSURL()
    var urlTemp:NSURL = NSURL()
    var likeCount = 0
    var commentCount = 0
    var comments = [String]()
    var isLiked: Int = 0
    var isFollowing: Int = 0
    var userpic: NSURL = NSURL()
    var dateStr: String = ""
    var taggedUsers = [String]()
}

struct notifications{
    var owner:String = ""
    var date:String = ""
    var action:String = ""
    var actor:String = ""
    var target:String = ""
    var sentence:String = ""
    var picture_url: NSURL = NSURL()
}
var nextT:NSURL!
var nextU:NSURL!
var userToken: String?
var theVideo:videoInf!
var exploreInProcess = false
struct User{
    var username:String = ""
    var email : String = ""
    var profilePic:NSURL = NSURL()
    var token: String = ""
    var first_name = ""
    var last_name = ""
    var post_count = 0;
    var tag_count = 0;
    var follower_count = 0;
    var following_count = 0;
    var isFollowing:Bool = false;
    var gender = "male"
    var birthday = "2016-10-12"
    
    func printUser() -> Void {
        print("username: " + username)
        print("email: " + email)
        //print("profile_pic: " + profilePic.absoluteString)
        //print("token: "+ token)
        print("first_name: "+first_name)
        print("last_name: "+last_name)
        print("post_count:  \(post_count)");
        print("tag_count:  \(tag_count)");
        print("follower_count:  \(follower_count)");
        print("following_count:  \(following_count)");
    }
}

struct comment{
    var text: String = ""
    var username: String = ""
    var photo: NSURL = NSURL()
}

struct Place{
    var id: String = ""
    var name: String = ""
    var caption: String = ""
    var follower_count = 0;
    var following_count = 0;
    var tag_count = 0;
    var picture_url:NSURL = NSURL()
    var placeVideos: [videoInf] = [videoInf]()
    var city = ""
    var address = ""
    var is_following = 0
    var web_site = ""
    var video_count = 0
    var phone = ""
    var videoArray = [videoInf]()
}


var currentUser:User = User()
var faceUsername = ""
var faceMail = ""
var fbToken = ""

public class Molocate {
    
    class func follow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: baseUrl + "/relation/api/follow/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.follow()")
            }
            
        }
        
        task.resume()
        
    }
    
    class func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    class func unfollow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: baseUrl + "relation/api/unfollow/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
           // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.unfollow()")
            }
            
        }
        
        task.resume()
    }
    
    class func followAPlace(place_id: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: baseUrl + "place/api/follow/?place_id=" + (place_id as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
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
        let url = NSURL(string: baseUrl + "place/api/unfollow/?place_id=" + (place_id as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
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
    
    
    
    class func getFollowers(username: String, completionHandler: (data: Array<User>, response: NSURLResponse!, error: NSError!, count: Int, next: String?, previous: String? ) -> ()) {
        
        let url = NSURL(string: baseUrl + "relation/api/followers/?username=" + (username as String) )!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
           // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
               // print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var users: Array<User> = Array<User>()
                
                if(count != 0){
                    print(result["results"] )
                    for thing in result["results"] as! NSArray{
                        var user = User()
                        user.username = thing["username"] as! String
                        user.profilePic = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        //user.isFollowing = thing["is_following"] as! Int == 0 ? false:true
                        users.append(user)
                    }
                }
                
                completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<User>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowers()")
            }
            
        }
        task.resume()
    }
    
    
    class func getFollowings(username: String, completionHandler: (data: Array<User>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
        
        let url = NSURL(string: baseUrl + "relation/api/followings/?username=" + (username as String));
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken! , forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            
            do {
                
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                //print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var users: Array<User> = Array<User>()
                
                if(count != 0){
                    for thing in result["results"] as! NSArray{
                        var user = User()
                        user.username = thing["username"] as! String
                        user.profilePic = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        users.append(user)
                    }
                }
                
                
                completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<User>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowings()")
            }
            
        }
        
        task.resume()
        
    }
    
    class func getPlace(placeid: String, completionHandler: (data: Place, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: baseUrl + "place/api/get_place/?place_id=" + (placeid as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            do {
                
                let item = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                var place = Place()
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
                
                var videoArray = [videoInf]()
                
                for item in videos {
                    //print(item)
                    var videoStr = videoInf()
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
                
                    place.videoArray.append(videoStr)
                    
                    }
                }

                completionHandler(data: place, response: response , error: nsError  )
            } catch{
                completionHandler(data: Place() , response: nil , error: nsError  )
                print("Error:: in mole.getUser()")
            }
            
            
        }
        
        task.resume()
    }
    
    class func getUser(username: String, completionHandler: (data: User, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: baseUrl + "account/api/get_user/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(result)
                var user = User()
                user.email = result["email"] as! String
                user.username = result["username"] as! String
                user.first_name = result["first_name"] as! String
                user.last_name = result["last_name"] as! String
                user.profilePic = result["picture_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                user.follower_count = result["follower_count"] as! Int
                user.following_count = result["following_count"]as! Int
                user.tag_count = result["tag_count"] as! Int
                user.post_count = result["post_count"]as! Int
                user.isFollowing = result["is_following"] as! Int == 1 ? true:false
           
                completionHandler(data: user, response: response , error: nsError  )
            } catch{
                completionHandler(data: User() , response: nil , error: nsError  )
                print("Error:: in mole.getUser()")
            }
            
            
        }
        
        task.resume()
    }
    
    class func getLikes(videoId: String, completionHandler: (data: Array<User>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
        
        let url = NSURL(string: baseUrl + "video/api/video_likes/?video_id=" + (videoId as String));
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken! , forHTTPHeaderField: "Authorization")
        
       // print(url?.absoluteString)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
           print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            do {
                
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                //print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var users: Array<User> = Array<User>()
                
                if(count != 0){
                    for thing in result["results"] as! NSArray{
                        var user = User()
                        user.username = thing["username"] as! String
                        user.profilePic = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        user.isFollowing = thing["is_following"] as! Int == 1 ? true:false
                        users.append(user)
                    }
                }
                
                
                completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<User>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowings()")
            }
            
        }
        
        task.resume()
        
    }
    
    
    class func getComments(videoId: String, completionHandler: (data: Array<comment>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()) {
        
        let url = NSURL(string: baseUrl + "video/api/get_comments/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var comments: Array<comment> = Array<comment>()
                
                if(count != 0){
                    for thing in result["results"] as! NSArray{
                        var thecomment = comment()
                        thecomment.username = thing["username"] as! String
                        thecomment.photo = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        thecomment.text = thing["comment"] as! String
                        comments.append(thecomment)
                    }
                }
                
                completionHandler(data: comments , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<comment>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getComments()")
            }
            
        }
        
        task.resume()
    }
    
    
    class func getExploreVideos(nextURL: NSURL?, completionHandler: (data: [videoInf]?, response: NSURLResponse!, error: NSError!) -> ()){
        
        let request = NSMutableURLRequest(URL: nextURL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                let videos = result["results"] as! NSArray
                if (result["next"] != nil){
                    if result["next"] is NSNull {
                        print("next is null")
                        nextU = nil
                    }else {
                        let nextStr = result["next"] as! String
                        //print(nextStr)
                        nextU = NSURL(string: nextStr)!
                    }
                }
                
                var videoArray = [videoInf]()
                
                for item in videos {
                    //print(item)
                    var videoStr = videoInf()
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
        
                    videoArray.append(videoStr)
                    
                }
                completionHandler(data: videoArray, response: response, error: nsError)
            }catch{
                completionHandler(data: nil, response: NSURLResponse(), error: nsError)
                print("Error: in mole.getExploreVideos")
            }
        }
        task.resume()
    }
    
    
    class func getVideo(id: String?, completionHandler: (data: videoInf?, response: NSURLResponse!, error: NSError!) -> ()){
        var url = NSURL(string: baseUrl+"video/get_video/?video_id="+id!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            let nsError = error
            do {
                let item = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)

                    print(item)
                    var videoStr = videoInf()
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
                    
                
                    
                
                completionHandler(data: videoStr, response: response, error: nsError)
            }catch{
                completionHandler(data: nil, response: NSURLResponse(), error: nsError)
                print("Error: in mole.getExploreVideos")
            }
        }
        task.resume()
    }

    
    class func getUserVideos(name: String,type:String , completionHandler: (data: [videoInf]?, response: NSURLResponse!, error: NSError!) -> ()){
        var nextURL = NSURL()
        switch(type){
            case "user":
            nextURL = NSURL(string: baseUrl+"video/api/user_videos/?username="+name)!
            break
            case "tagged":
            nextURL = NSURL(string: baseUrl+"video/api/tagged_videos/?username="+name)!
            break
            default:
            break
        }
        
        let request = NSMutableURLRequest(URL: nextURL)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                print(result)
                switch(type){
                case "user":
                    if (result["next"] != nil){
                        if result["next"] is NSNull {
                            print("next is null")
                            nextU = nil
                        }else {
                            let nextStr = result["next"] as! String
                            //print(nextStr)
                            nextU = NSURL(string: nextStr)!
                        }
                    }
                    break
                case "tagged":
                    if (result["next"] != nil){
                        if result["next"] is NSNull {
                            print("next is null")
                            nextT = nil
                        }else {
                            let nextStr = result["next"] as! String
                            //print(nextStr)
                            nextT = NSURL(string: nextStr)!
                        }
                    }
                    break
                default:
                    break
                }
                
                let videos = result["results"] as! NSArray

                
                var videoArray = [videoInf]()
                
                for item in videos {
                    //print(item)
                    var videoStr = videoInf()
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
                    
                    videoArray.append(videoStr)
                    
                }
                completionHandler(data: videoArray, response: response, error: nsError)
            }catch{
                completionHandler(data: nil, response: NSURLResponse(), error: nsError)
                print("Error: in mole.getExploreVideos")
            }
        }
        task.resume()
    }
    
    

    
    class func getNotifications(nextURL: NSURL?, completionHandler: (data: [notifications]?, response: NSURLResponse!, error: NSError!) -> ()){
        let nURL = NSURL(string: baseUrl+"activity/api/show_activities/")
        let request = NSMutableURLRequest(URL: nURL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                var notificationArray = [notifications]()
                let array = result as! NSArray
                for item in array {
                    print(item)
                    var notification = notifications()
                    notification.action = item ["action"] as! String
                    notification.owner =  item ["owner"] as! String
                    notification.actor = item["actor"] as! String
                    notification.date = item["date_str"] as! String
                    notification.sentence = item["sentence"] as! String
                    notification.target = item["target"] as! String
                    notification.picture_url = item["picture_url"] is NSNull ? NSURL():NSURL(string: item["picture_url"] as! String)!
                    notificationArray.append(notification)
                }
                completionHandler(data: notificationArray, response: response, error: nsError)
            }catch{
                completionHandler(data: nil, response: NSURLResponse(), error: nsError)
                print("Error: in mole.getExploreVideos")
            }
        }
        task.resume()
    }

    
    
    class func likeAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: baseUrl + "video/like/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.like()")
            }
            
        }
        
        task.resume()
    }
    class func reportAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: baseUrl + "video/report/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.unlike()")
            }
            
        }
        
        task.resume()
    }
    
    class func unLikeAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: baseUrl + "video/unlike/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.unlike()")
            }
            
        }
        
        task.resume()
    }
    
    class func deleteAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: baseUrl + "video/delete/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.deleteAVideo()")
            }
            
        }
        
        task.resume()
    }


    
    class func commentAVideo(videoId: String,comment: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        do{
            
            let Body = ["video_id": videoId,"comment": comment]
            let jsonData = try NSJSONSerialization.dataWithJSONObject(Body, options: NSJSONWritingOptions())
            let url = NSURL(string: baseUrl + "video/comment/")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
            request.HTTPBody = jsonData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
               // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                let nsError = error
                
                do {
                    
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                } catch{
                    completionHandler(data: "" , response: nil , error: nsError  )
                    print("Error:: in mole.commentAVideo()")
                }
                
            }
            
            task.resume()
        }catch{
            completionHandler(data: "" , response: nil , error: nil )
            print("Error:: in mole.commentAVideo()")
        }
    }

    
    class func deleteAComment(id: String,comment: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        do{
            
            let Body = ["comment_id": id,"comment": comment]
            let jsonData = try NSJSONSerialization.dataWithJSONObject(Body, options: NSJSONWritingOptions())
            let url = NSURL(string: baseUrl + "video/api/delete_comment/?comment_id=" + (id as String))!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
            request.HTTPBody = jsonData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                let nsError = error
                
                do {
                    
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                } catch{
                    completionHandler(data: "" , response: nil , error: nsError  )
                    print("Error:: in mole.deleteComment()")
                }
                
            }
            
            task.resume()
        }catch{
            completionHandler(data: "" , response: nil , error: nil )
            print("Error:: in mole.deleteComment()")
        }
    }
    
    

    
    class func EditUser(completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        do{
            
            let Body = ["profile_pic": currentUser.profilePic.absoluteString,
                        "first_name": currentUser.first_name,
                        "last_name": currentUser.last_name,
                        "gender": currentUser.gender,
                        "birthday": currentUser.birthday
                        ]
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(Body, options: NSJSONWritingOptions())
            let url = NSURL(string: baseUrl + "account/api/edit_user/")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
            request.HTTPBody = jsonData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                let nsError = error
                
                do {
                    
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    completionHandler(data: "success" as! String , response: response , error: nsError  )
                } catch{
                    completionHandler(data: "fail" , response: nil , error: nsError  )
                    print("Error:: in mole.EditUser()")
                }
                
            }
            
            task.resume()
        }catch{
                    completionHandler(data: "fail" , response: nil , error: nil )
            print("Error:: in mole.EditUser()")
        }
    }
    
    class func uploadProfilePhoto(image: NSData, completionHandler: (data: String!, response: NSURLResponse!, error: NSError!) -> ()){
       
        let headers = ["content-type": "/*/", "content-disposition":"attachment;filename=molocate.png" ]
        
        var request = NSMutableURLRequest(URL: NSURL(string: baseUrl + "/account/api/upload_picture/")!, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        request.HTTPBody = image
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))

            let nsError = error;
            
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                var urlString = ""
                if(result["result"] as! String=="success"){
                    urlString = result["picture_url"] as! String
                }else{
                    urlString = ""
                }
                completionHandler(data: urlString, response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                
                print("Error:: in mole.uploadProfilePhoto()")
            }
            
        }
        
        task.resume();
        

            
    }
    
    
    class func getCurrentUser(completionHandler: (data: User, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: baseUrl +  "/account/api/current/")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + userToken!, forHTTPHeaderField: "Authorization")
        //print(userToken)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            //print(data)
            let nsError = error;
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                //print(result)
                currentUser.email = result["email"] as! String
                currentUser.username = result["username"] as! String
                currentUser.first_name = result["first_name"] as! String
                currentUser.last_name = result["last_name"] as! String
                currentUser.profilePic = result["picture_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                currentUser.tag_count = result["tag_count"] as! Int
                currentUser.post_count = result["post_count"] as! Int
                currentUser.follower_count = result["follower_count"] as! Int
                currentUser.following_count = result["following_count"]as! Int
                currentUser.gender =  result["gender"] is NSNull ? "": (result["gender"] as! String)
                
                completionHandler(data: currentUser, response: response , error: nsError  )
            } catch{
                completionHandler(data: User() , response: nil , error: nsError  )
                print("Error:: in mole.getCurrentUser()")
            }
            
        }
        
        task.resume();
        
    }
    
    
    
}
