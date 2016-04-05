//
//  MolocateVideo.swift
//  Molocate


import Foundation


let MoleCategoriesDictionary = ["Eğlence":"fun","Yemek":"food","Gezi":"travel","Moda":"fashion" , "Güzellik":"makeup", "Spor": "Sport","Etkinlik": "Event","Kampüs":"university", "Hepsi":"all"]

struct MoleVideoInformation{
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
    var thumbnailURL:NSURL = NSURL()
}

struct MoleVideoComment{
    var text: String = ""
    var username: String = ""
    var photo: NSURL = NSURL()
}

var MoleGlobalVideo:MoleVideoInformation!


public class MolocateVideo {
    
    class func getComments(videoId: String, completionHandler: (data: Array<MoleVideoComment>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl + "video/api/get_comments/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                //print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var comments: Array<MoleVideoComment> = Array<MoleVideoComment>()
                
                if(count != 0){
                    for thing in result["results"] as! NSArray{
                        var thecomment = MoleVideoComment()
                        thecomment.username = thing["username"] as! String
                        thecomment.photo = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        thecomment.text = thing["comment"] as! String
                        comments.append(thecomment)
                    }
                }
                
                completionHandler(data: comments , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<MoleVideoComment>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getComments()")
            }
            
        }
        
        task.resume()
    }
    
    
    class func getExploreVideos(nextURL: NSURL?, completionHandler: (data: [MoleVideoInformation]?, response: NSURLResponse!, error: NSError!) -> ()){
        
        let request = NSMutableURLRequest(URL: nextURL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
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
                
                var videoArray = [MoleVideoInformation]()
                
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
    
    
    class func getLikes(videoId: String, completionHandler: (data: Array<MoleUser>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "video/api/video_likes/?video_id=" + (videoId as String));
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
        
        // print(url?.absoluteString)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            do {
                
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                //print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? nil:result["next"] as? String
                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                
                var users: Array<MoleUser> = Array<MoleUser>()
                
                if(count != 0){
                    for thing in result["results"] as! NSArray{
                        var user = MoleUser()
                        user.username = thing["username"] as! String
                        user.profilePic = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        user.isFollowing = thing["is_following"] as! Int == 1 ? true:false
                        users.append(user)
                    }
                }
                
                
                completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  Array<MoleUser>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowings()")
            }
            
        }
        
        task.resume()
        
    }

    
    class func getUserVideos(name: String,type:String , completionHandler: (data: [MoleVideoInformation]?, response: NSURLResponse!, error: NSError!) -> ()){
        var nextURL = NSURL()
        switch(type){
        case "user":
            nextURL = NSURL(string: MolocateBaseUrl+"video/api/user_videos/?username="+name)!
            break
        case "tagged":
            nextURL = NSURL(string: MolocateBaseUrl+"video/api/tagged_videos/?username="+name)!
            break
        default:
            break
        }
        
        let request = NSMutableURLRequest(URL: nextURL)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                //print(result)
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
                
                
                var videoArray = [MoleVideoInformation]()
                
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

    
    class func getVideo(id: String?, completionHandler: (data: MoleVideoInformation?, response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: MolocateBaseUrl+"video/get_video/?video_id="+id!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            let nsError = error
            do {
                let item = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                
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
                
                
                
                completionHandler(data: videoStr, response: response, error: nsError)
            }catch{
                completionHandler(data: nil, response: NSURLResponse(), error: nsError)
                print("Error: in mole.getExploreVideos")
            }
        }
        task.resume()
    }
    
    
    
    
    class func likeAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "video/like/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        
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
        
        let url = NSURL(string: MolocateBaseUrl + "video/report/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
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
        
        let url = NSURL(string: MolocateBaseUrl + "video/unlike/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        
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
        
        let url = NSURL(string: MolocateBaseUrl + "video/delete/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        
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
            let url = NSURL(string: MolocateBaseUrl + "video/comment/")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
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
            let url = NSURL(string: MolocateBaseUrl + "video/api/delete_comment/?comment_id=" + (id as String))!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
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
    
    
    

    
}