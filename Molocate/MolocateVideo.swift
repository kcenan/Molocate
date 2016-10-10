import Foundation
import AWSS3

let MoleCategoriesDictionary = ["EĞLENCE":"fun","YEMEK":"food","GEZİ":"travel","MODA":"fashion" , "GÜZELLİK":"makeup", "SPOR": "Sport","ETKİNLİK": "Event","KAMPÜS":"university", "HEPSİ":"all","TREND":"trend","YAKINDA":"nearby"]
var MoleGlobalVideo:MoleVideoInformation!
var AddedNextUserVideos: URL?
var TaggedNextUserVideos: URL?


var VideoUploadRequests: [VideoUploadRequest] = [VideoUploadRequest]()
var MyS3Uploads: [S3Upload] = [S3Upload]()

struct MoleVideoInformation{
    var id: String?
    var username:String?
    var category:String?
    var location:String?
    var locationID:String?
    var caption:String?
    var urlSta:URL?
    var likeCount = 0
    var commentCount = 0
    var comments:[String]?
    var isLiked: Int = 0
    var isFollowing: Int = 0
    var userpic: URL?
    var dateStr: String?
    var taggedUsers:[String]?
    var thumbnailURL:URL?
    var isUploading = false
    var isFailed = false
    var deletable = false
}

struct VideoUploadRequest{
    var filePath:String?
    var thumbUrl: URL?
    var thumbnail:Data
    var JsonData: [String:AnyObject]
    var fileId:String?
    var uploadRequest: AWSS3TransferManagerUploadRequest
    var id = 0
    var isFailed = false
    func encode() -> Dictionary<String, AnyObject> {
        var dictionary : Dictionary = Dictionary<String, AnyObject>()
        dictionary["filePath"] = filePath as AnyObject?
        dictionary["thumbUrl"] = thumbUrl?.absoluteString as AnyObject?
        dictionary["JsonData"] = JsonData as AnyObject?
        dictionary["thumbnail"] = thumbnail as AnyObject?
        dictionary["uploadRequestBody"] = uploadRequest.body.absoluteString as AnyObject?
        dictionary["uploadRequestBucket"] = uploadRequest.bucket as AnyObject?
        dictionary["uploadRequestKey"] = uploadRequest.key as AnyObject?
        dictionary["fileId"] = fileId as AnyObject?
        dictionary["id"] = id as AnyObject?
        dictionary["isFailed"] = isFailed as AnyObject?
        return dictionary
    }
}

struct MoleVideoComment{
    var id: String = ""
    var text: String = ""
    var username: String = ""
    var photo: URL = URL(string:"")!
    var deletable = false
}

open class MolocateVideo {
    
    static let timeout = 8.0
    
    class func encodeGlobalVideo(){
        let ud = UserDefaults.standard
        if VideoUploadRequests.count == 0 {
            ud.set(false, forKey: "isStuck")
        }else{
            ud.set(true, forKey: "isStuck")
            let dataUploadRequests = VideoUploadRequests.map({
                (value: VideoUploadRequest) -> Dictionary<String, AnyObject> in
                return value.encode()
            })
            ud.set(dataUploadRequests, forKey: "videoRequests")
        }
        // print(fileURL)
        
        
    }
    class func decodeGlobalVideo(){
        let ud = UserDefaults.standard
        if ud.object(forKey: "videoRequests") != nil {
            let dataUploadRequests  = ud.object(forKey: "videoRequests") as! [Dictionary<String, AnyObject>]
            VideoUploadRequests = dataUploadRequests.map({
                (value:Dictionary<String, AnyObject> ) -> VideoUploadRequest in
                //print("decoding")
                MyS3Uploads.append(S3Upload())
                return self.decodeVideoUploadRequest(value)
                
            })
        }
        
        
    }
    
    class func decodeVideoUploadRequest(_ dictionary: Dictionary<String, AnyObject>) -> VideoUploadRequest{
       
        let filePath = dictionary["filePath"] as! String
        let thumbUrl:URL = URL(string: dictionary["thumbUrl"] as! String)!
        let JsonData = dictionary["JsonData"] as! [String:AnyObject]
        let thumbnail = dictionary["thumbnail"] as! Data
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = URL(string:  dictionary["uploadRequestBody"] as! String)
        uploadRequest?.bucket = dictionary["uploadRequestBucket"] as? String
        uploadRequest?.key = dictionary["uploadRequestKey"] as? String
        let fileId = dictionary["fileId"] as! String
        let id = dictionary["id"] as! Int
        let isFailed = true
        
        return VideoUploadRequest(filePath: filePath, thumbUrl: thumbUrl, thumbnail: thumbnail, JsonData: JsonData, fileId: fileId, uploadRequest: uploadRequest!, id: id, isFailed: isFailed )
        
    }
    class func getComments(_ videoId: String, completionHandler: @escaping (_ data: Array<MoleVideoComment>, _ response: URLResponse?, _ error: NSError?, _ count: Int?, _ next: String?, _ previous: String?) -> ()) {
        
        let url = URL(string: MolocateBaseUrl + "video/api/get_comments/?video_id=" + (videoId as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            if error == nil {
                let nsError = error;
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "results") != nil {
                        let commentdata = result["results"] as!  NSArray
                        let count: Int = result["count"] as! Int
                        let next =  result["next"] is NSNull ? nil:result["next"] as? String
                        let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                    
                        
                        var comments = [MoleVideoComment]()
                        
                        for i in 0..<commentdata.count{
                            var thecomment = MoleVideoComment()
                            let thing = commentdata[i] as! [String:AnyObject]
                            //print(thing)
                            thecomment.username = thing["username"] as! String
                            thecomment.photo = thing["picture_url"] is NSNull ? URL(string:"")!:URL(string: thing["picture_url"] as! String)! as URL
                            thecomment.text = thing["comment"] as! String
                            thecomment.id = thing["comment_id"] as! String
                            thecomment.deletable = thing["is_deletable"] as! Bool
                            comments.append(thecomment)
                        }
                        
                        
                        completionHandler(comments , response , nsError as NSError?, count, next, previous  )
                    }else{
                        completionHandler([MoleVideoComment]() , nil , nsError as NSError?, 0, nil, nil  )
                        if debug { print("ServerDataError:: in MolocateVideo.getComments()")}
 
                    }
                } catch{
                    completionHandler([MoleVideoComment]() , nil , nsError as NSError?, 0, nil, nil  )
                    if debug { print("JSONError:: in MolocateVideo.getComments()")}
                }
            }else{
                completionHandler([MoleVideoComment]() , nil , error as NSError?, 0, nil, nil  )
                if debug { print("RequestError:: in MolocateVideo.getComments()")}
            }
            
        })
        
        task.resume()
    }
    
    class func getFilters(_ completionHandler: @escaping (_ data: [filter]?, _ response: URLResponse?, _ error: NSError?) -> ()){
        
        var request = URLRequest(url: URL(string: MolocateBaseUrl+"video/api/video_filters/")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout + 2.0
        eventcount = 0
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if error == nil{
                let nsError = error
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers ) as! [[String:AnyObject]]
                   // print(result)
                    var filters = [filter]()
                    for item in result {
                        var filt = filter()
                        filt.isevent = (item["is_event"] as! Int) == 0 ? false:true
                        if (item["is_event"] as! Int) == 1 {
                            eventcount += 1
                            iseventhere = true
                        }
                        filt.name = item["name"] as! String
                        filt.raw_name = item["name_raw"] as! String
                        filt.thumbnail_url = URL(string: item["thumbnail_url"] as! String) == nil ? URL(string:""):URL(string: item["thumbnail_url"] as! String)!
                        filters.append(filt)
                    }
                    completionHandler(filters, response, nsError as NSError?)
                } catch {
                    completionHandler([filter](), response, nsError as NSError?)
                }
        
    
    }
        })
        task.resume()
    }
    
    
    class func getExploreVideos(_ nextURL: URL?, completionHandler: @escaping (_ data: [MoleVideoInformation]?, _ response: URLResponse?, _ error: NSError?, _ next: URL?) -> ()){
      
        var request = URLRequest(url: nextURL!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout + 2.0
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            if error == nil{
                let nsError = error
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers ) as! [String: AnyObject]
                    
                    if result.index(forKey: "results") != nil {
                        
                        let videos = result["results"] as! NSArray
                        var nexturl: URL?
                        
                        if (result["next"] != nil){
                            if result["next"] is NSNull {
                                nexturl = nil
                            }else {
                                let nextStr = result["next"] as! String
                                nexturl = URL(string: nextStr)!
                            }
                        }
                        
                        var videoArray = [MoleVideoInformation]()
                        
                        for i in 0..<videos.count{
                            
                            let item = videos[i] as! [String:AnyObject]
                            let owner_user = item["owner_user"] as! [String:AnyObject]
                            let place_taken = item["place_taken"] as! [String:String]
                            var videoStr = MoleVideoInformation()
                            
                            videoStr.id = item["video_id"] as? String
                            videoStr.urlSta = URL(string:  item["video_url"] as! String)! as URL
                            videoStr.username = owner_user["username"] as? String
                            videoStr.location = place_taken["name"]!
                            videoStr.locationID = place_taken["place_id"]!
                            videoStr.caption = item["caption"] as? String
                            videoStr.likeCount = item["like_count"] as! Int
                            videoStr.commentCount = item["comment_count"] as! Int
                            videoStr.category = item["category"] as? String
                            videoStr.isLiked = item["is_liked"] as! Int
                            videoStr.isFollowing = owner_user["is_following"] as! Int
                            videoStr.userpic = owner_user["picture_url"] is NSNull ? URL(string:"")!:URL(string: owner_user["picture_url"] as! String)!
                            videoStr.dateStr = item["date_str"] as? String
                            videoStr.taggedUsers = item["tagged_users"] as? [String]
                            videoStr.thumbnailURL = URL(string:item["thumbnail"] as! String)! as URL
                            videoStr.deletable = item["is_deletable"] as! Bool
                            videoArray.append(videoStr)
//                            print(videoStr.username)
//                            print(videoStr.location)
//                            print(videoStr.urlSta)
                        }
                        completionHandler(videoArray, response, nsError as NSError?, nexturl)
                    }else{
                        completionHandler([MoleVideoInformation](), response, nsError as NSError?, nil)
                        if debug {print("ServerDataError: in MolocateVideo.getExploreVideos()")}
                        
                    }
                }catch{
                    completionHandler([MoleVideoInformation](), URLResponse(), nsError as NSError?, nil)
                    if debug { print("JsonError: in MolocateVideo.getExploreVideos")}
                }
            }else{
                completionHandler([MoleVideoInformation](), URLResponse(), error as NSError?, nil)
                if debug { print("Request: in MolocateVideo.getExploreVideos")}

            }
        })
        task.resume()
    }
    
    class func getNearbyVideos(_ placeLat: Float,placeLon: Float, completionHandler: @escaping (_ data: [MoleVideoInformation]?, _ response: URLResponse?, _ error: NSError?, _ next: URL?) -> ()){
        
        
        let url = URL(string: MolocateBaseUrl + "/place/api/nearby_videos/?lat=\(placeLat)&lon=\(placeLon)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout + 2.0
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil{
                let nsError = error
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers ) as! [String: AnyObject]
                    if result.index(forKey: "results") != nil {
                        
                        let videos = result["results"] as! NSArray
                        var nexturl: URL?
                        
                        if (result["next"] != nil){
                            if result["next"] is NSNull {
                                nexturl = nil
                            }else {
                                let nextStr = result["next"] as! String
                                nexturl = URL(string: nextStr)!
                            }
                        }
                        
                        var videoArray = [MoleVideoInformation]()
                        
                        for i in 0..<videos.count{
                            
                            let item = videos[i] as! [String:AnyObject]
                            let owner_user = item["owner_user"] as! [String:AnyObject]
                            let place_taken = item["place_taken"] as! [String:String]
                            var videoStr = MoleVideoInformation()
                            
                            videoStr.id = item["video_id"] as? String
                            videoStr.urlSta = URL(string:  item["video_url"] as! String)!
                            videoStr.username = owner_user["username"] as? String
                            videoStr.location = place_taken["name"]!
                            videoStr.locationID = place_taken["place_id"]!
                            videoStr.caption = item["caption"] as? String
                            videoStr.likeCount = item["like_count"] as! Int
                            videoStr.commentCount = item["comment_count"] as! Int
                            videoStr.category = item["category"] as? String
                            videoStr.isLiked = item["is_liked"] as! Int
                            videoStr.isFollowing = owner_user["is_following"] as! Int
                            videoStr.userpic = owner_user["picture_url"] is NSNull ? URL(string:"")!:URL(string: owner_user["picture_url"] as! String)!
                            videoStr.dateStr = item["date_str"] as? String
                            videoStr.taggedUsers = item["tagged_users"] as? [String]
                            videoStr.thumbnailURL = URL(string:item["thumbnail"] as! String)!
                            videoStr.deletable = item["is_deletable"] as! Bool
                            videoArray.append(videoStr)
                            //                            print(videoStr.username)
                            //                            print(videoStr.location)
                            //                            print(videoStr.urlSta)
                        }
                        completionHandler(videoArray, response, nsError as NSError?, nexturl)
                    }else{
                        completionHandler([MoleVideoInformation](), response, nsError as NSError?, nil)
                        if debug {print("ServerDataError: in MolocateVideo.getExploreVideos()")}
                        
                    }
                }catch{
                    completionHandler([MoleVideoInformation](), URLResponse(), nsError as NSError?, nil)
                    if debug { print("JsonError: in MolocateVideo.getExploreVideos")}
                }
            }else{
                completionHandler([MoleVideoInformation](), URLResponse(), error as NSError?, nil)
                if debug { print("Request: in MolocateVideo.getExploreVideos")}
                
            }
        })
        task.resume()
    }

    class func getLikes(_ videoId: String, completionHandler: @escaping (_ data: Array<MoleUser>, _ response: URLResponse?, _ error: NSError?, _ count: Int?, _ next: String?, _ previous: String?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "video/api/video_likes/?video_id=" + (videoId as String));
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            if error == nil {
                let nsError = error;
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                do {
                    
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "results") != nil {
                      
                        let count: Int = result["count"] as! Int
                        let next =  result["next"] is NSNull ? nil:result["next"] as? String
                        let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                        let likers = result["results"] as! NSArray
                        var users = [MoleUser]()
                        
                            for i in 0..<likers.count{
                                let thing = likers[i] as! [String:AnyObject]
                                var user = MoleUser()
                                user.username = thing["username"] as! String
                                user.profilePic = thing["picture_url"] is NSNull ? URL(string:"")!:URL(string: thing["picture_url"] as! String)!
                                user.isFollowing = thing["is_following"] as! Int == 1 ? true:false
                                users.append(user)
                            }
                        
                        completionHandler(users , response , nsError as NSError?, count, next, previous  )
                    }else{
                        completionHandler(Array<MoleUser>() , nil , nsError as NSError?, 0, nil, nil  )
                       /// print("ServerDataError:: in MolocateVideo.geLikes()")
                    }
                } catch{
                    completionHandler(Array<MoleUser>() , nil , nsError as NSError?, 0, nil, nil  )
                  //  print("JsonError:: in MolocateVideo.getLikes(()")
                }
            }else{
                completionHandler(Array<MoleUser>() , nil , error as NSError?, 0, nil, nil  )
               // print("RequestError:: in MolocateVideo.getLikes(()")
            }
            
        })
        
        task.resume()
        
    }
    
    
    class func getUserVideos(_ name: String,type:String , completionHandler: @escaping (_ data: [MoleVideoInformation]?, _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let nextURL:URL
        
        switch(type){
            case "user":
                nextURL = URL(string: MolocateBaseUrl+"video/api/user_videos/?username="+name)!
                break
            case "tagged":
                nextURL = URL(string: MolocateBaseUrl+"video/api/tagged_videos/?username="+name)!
                break
            default:
                nextURL = URL(string:"")!
                break
        }
        
        var request = URLRequest(url: nextURL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout + 2.0
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if error == nil {
                let nsError = error
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                    if result.index(forKey: "results") != nil{
                        
                        switch(type){
                        case "user":
                            if (result["next"] != nil){
                                if result["next"] is NSNull {
                                    AddedNextUserVideos = nil
                                }else {
                                    let nextStr = result["next"] as! String
                                    AddedNextUserVideos = URL(string: nextStr)!
                                }
                            }
                            break
                        case "tagged":
                            if (result["next"] != nil){
                                if result["next"] is NSNull {
                                    TaggedNextUserVideos = nil
                                }else {
                                    let nextStr = result["next"] as! String
                                    TaggedNextUserVideos = URL(string: nextStr)!
                                }
                            }
                            break
                        default:
                            break
                        }
                        
                        
                        let videos = result["results"] as! NSArray
                        var videoArray = [MoleVideoInformation]()
                        
                        for i in 0..<videos.count{
                            let item = videos[i] as! [String:AnyObject]
                            let owner_user = item["owner_user"] as! [String:AnyObject]
                            let place_taken = item["place_taken"] as! [String:String]
                            
                            var videoStr = MoleVideoInformation()
                            videoStr.id = item["video_id"] as? String
                            videoStr.urlSta = URL(string:  item["video_url"] as! String)!
                            videoStr.username = owner_user["username"] as? String
                            videoStr.location = place_taken["name"]!
                            videoStr.locationID = place_taken["place_id"]!
                            videoStr.caption = item["caption"] as? String
                            videoStr.likeCount = item["like_count"] as! Int
                            videoStr.commentCount = item["comment_count"] as! Int
                            videoStr.category = item["category"] as? String
                            videoStr.isLiked = item["is_liked"] as! Int
                            videoStr.isFollowing = owner_user["is_following"] as! Int
                            videoStr.userpic = owner_user["picture_url"] is NSNull ? URL(string:"")!:URL(string: owner_user["picture_url"] as! String)!
                            videoStr.dateStr = item["date_str"] as? String
                            videoStr.taggedUsers = item["tagged_users"] as? [String]
                            
                            videoStr.thumbnailURL = URL(string:item["thumbnail"] as! String)!
                            videoStr.deletable = item["is_deletable"] as! Bool
                            videoArray.append(videoStr)
                           
//                            print(videoStr.username)
//                            print(videoStr.location)
//                            print(videoStr.urlSta)
                        }
                        completionHandler(videoArray, response, nsError as NSError?)
                    }else{
                        completionHandler([MoleVideoInformation](), URLResponse(), nsError as NSError?)
                        if debug {print("ServerDataError: in MoleVideo.getUserVideos")}
                    }
                }catch{
                    completionHandler([MoleVideoInformation](), URLResponse(), nsError as NSError?)
                    if debug {print("JsonError: in MoleVideo.getUserVideos")}
                }
            }else{
                completionHandler([MoleVideoInformation](), URLResponse(), error as NSError?)
                if debug {print("RequestError:  in MoleVideo.getUserVideos")}
            }
        })
        task.resume()
    }
    
    
    class func getVideo(_ id: String?, completionHandler: @escaping (_ data: MoleVideoInformation?, _ response: URLResponse?, _ error: NSError?) -> ()){
       
        let url = URL(string: MolocateBaseUrl+"video/get_video/?video_id="+id!)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            
            if error == nil {
            let nsError = error
                do {
                    let item = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as![String: AnyObject]
                    if item.index(forKey: "owner_user") != nil {
                        var videoStr = MoleVideoInformation()
                        let owner_user = item["owner_user"] as! [String:AnyObject]
                        let placeTaken = item["place_taken"] as! [String:String]
                        
                        videoStr.id = item["video_id"] as? String
                        videoStr.urlSta = URL(string:  item["video_url"] as! String)! as URL
                        videoStr.username = owner_user["username"] as? String
                        videoStr.location = placeTaken["name"]!
                        videoStr.locationID = placeTaken["place_id"]!
                        videoStr.caption = item["caption"] as? String
                        videoStr.likeCount = item["like_count"] as! Int
                        videoStr.commentCount = item["comment_count"] as! Int
                        videoStr.category = item["category"] as? String
                        videoStr.isLiked = item["is_liked"] as! Int
                        videoStr.isFollowing = owner_user["is_following"] as! Int
                        videoStr.userpic = owner_user["picture_url"] is NSNull ? URL(string:"")!:URL(string: owner_user["picture_url"] as! String)!
                        videoStr.dateStr = item["date_str"] as? String
                        videoStr.taggedUsers = item["tagged_users"] as? [String]
                        videoStr.deletable = item["is_deletable"] as! Bool
                        videoStr.thumbnailURL = URL(string:item["thumbnail"] as! String)! as URL
                        
//                        print(videoStr.username)
//                        print(videoStr.location)
//                        print(videoStr.urlSta)
                        completionHandler(videoStr, response, nsError as NSError?)
                    }else{
                        completionHandler(MoleVideoInformation(), URLResponse(), nsError as NSError?)
                        if debug {print("ServerDataError: in MolocateVideo.getVideo")}
                    }
                }catch{
                    completionHandler(MoleVideoInformation(), URLResponse(), nsError as NSError?)
                    if debug {print("JsonError: in MolocateVideo.getVideo")}
                }
            }else{
                completionHandler(MoleVideoInformation(), URLResponse(), error as NSError?)
                if debug { print("RequestError: in MolocateVideo.getVideo")}
            }
        })
        task.resume()
    }
    
    
    
    
    class func likeAVideo(_ videoId: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "video/like/?video_id=" + (videoId as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil{
                let nsError = error
                
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    if result.index(forKey: "result") != nil{
                        completionHandler(result["result"] as? String , response , nsError as NSError?)
                    }else{
                        completionHandler("fail" , nil , nsError as NSError?)
                        if debug {print("ServerDataError:: in MolocateVideo.likeAVideo()")}
                    }
                } catch{
                    completionHandler("fail" , nil , nsError as NSError?  )
                    if debug {print("Error:: in MolocateVideo.likeAVideo()")}
                }
            }else{
                completionHandler("fail" , nil , error as NSError? )
                if debug {print("JsonError:: in MolocateVideo.likeAVideo()")}
            }
            
        })
        
        task.resume()
    }
    class func reportAVideo(_ videoId: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "video/report/?video_id=" + (videoId as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "result") != nil{
                        completionHandler(result["result"] as? String , response , nsError as NSError? )
                    }else{
                        completionHandler("fail" , nil , nsError as NSError? )
                        if debug {print("ServerDataError:: in MolocateVideo.reportAVideo()")}
                    }
                } catch{
                    completionHandler("fail" , nil , nsError as NSError? )
                    if debug {print("JsonError:: in MolocateVideo.reportAVideo()")}
                }
            }else{
                completionHandler("fail" , nil , error as NSError? )
                if debug {print("RequestError:: in MolocateVideo.reportAvideo()")}
            }
        })
        
        task.resume()
    }
    
    class func unLikeAVideo(_ videoId: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "video/unlike/?video_id=" + (videoId as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "result") != nil{
                        completionHandler(result["result"] as? String , response , nsError as NSError? )
                    }else{
                        completionHandler("fail" , nil , nsError as NSError? )
                        if debug {print("ServerDataError:: in MolocateVideo.unLikeAVideo()")}
                    }
                } catch{
                    completionHandler("fail" , nil , nsError as NSError? )
                    if debug {print("JsonError:: in MolocateVideo.unLikeAVideo()")}
                }
            }else{
                completionHandler("fail" , nil , error as NSError?)
                if debug {print("RequestError:: in MolocateVideo.unLikeAVideo()")}

            }
            
        })
        
        task.resume()
    }
    
    class func deleteAVideo(_ videoId: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "video/delete/?video_id=" + (videoId as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "result") != nil{
                        completionHandler(result["result"] as? String , response , nsError as NSError? )
                    }else{
                        completionHandler("fail" , nil , nsError as NSError? )
                        if debug {print("ServerDataError:: in MolocateVideo.deleteAVideo()")}

                    }
                } catch{
                    completionHandler("fail" , nil , nsError  as NSError?)
                    if debug {print("JsonError:: in MolocateVideo.deleteAVideo()")}
                }
            }else{
                completionHandler("fail" , nil , error as NSError?)
                if debug {print("RequestError:: in MolocateVideo.deleteAVideo()")}
            }
                
        })
        
        task.resume()
    }
    
    
    
    class func commentAVideo(_ videoId: String,comment: String, mentioned_users: [String], completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        do{
            
            let Body = ["video_id": videoId,"comment": comment, "mentioned_users": mentioned_users] as [String : Any]
            let jsonData = try JSONSerialization.data(withJSONObject: Body, options: JSONSerialization.WritingOptions())
            
            let url = URL(string: MolocateBaseUrl + "video/comment/")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            request.timeoutInterval = timeout
        
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                if error == nil{
                    let nsError = error
                    
                    do {
                        
                        let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                        //print(result)
                        if result.index(forKey: "result") != nil{
                            completionHandler(result["comment_id"] as? String , response , nsError as NSError? )
                        } else {
                            completionHandler("fail" , nil , nsError as NSError? )
                            if debug { print("ServerDataError:: in MolocateVideo.commentAVideo()")}
                        }
                    } catch{
                        completionHandler("fail" , nil , nsError as NSError? )
                        if debug { print("JsonError:: in MolocateVideo.commentAVideo()")}
                    }
                }else{
                    completionHandler("fail" , nil , error as NSError? )
                    if debug {print("JsonError:: in MolocateVideo.commentAVideo()")}
                }
                
            })
            
            task.resume()
        }catch{
            completionHandler("fail" , nil , nil )
            if debug {print("JsonError:: in MolocateVideo.commentAVideo() in start")}
        }
    }
    
    class func increment_watch(_ videoIds: [String], completionHandler: (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        do{
            
            let Body = ["videos": videoIds]
            let jsonData = try JSONSerialization.data(withJSONObject: Body, options: JSONSerialization.WritingOptions())
            
            let url = URL(string: MolocateBaseUrl + "video/api/increment_watch/")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            request.timeoutInterval = timeout
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
               // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
            })
                  task.resume()
        }catch{
            //  print("error")
        }
            
       
    }
    
    class func deleteAComment(_ id: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
   
            
            let url = URL(string: MolocateBaseUrl + "video/api/delete_comment/?comment_id=" + (id as String))!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.timeoutInterval = timeout
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                if error == nil {
                    let nsError = error
                    
                    do {
                        
                        let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                        if result.index(forKey: "result") != nil{
                           completionHandler(result["result"] as? String , response , nsError as NSError? )
                        }else{
                            completionHandler("fail" , nil , nsError as NSError? )
                            if debug {print("ServerDataError:: in mole.deleteComment()")}
                        }
                       
                    } catch{
                        completionHandler("fail" , nil , nsError as NSError? )
                        if debug {print("JsonError:: in mole.deleteComment()")}
                    }
                }else{
                    completionHandler("fail" , nil , error as NSError? )
                    if debug {print("RequestError:: in MolocateVideo.deleteComment()")}
                }
                
            })
            
            task.resume()
    }
}
