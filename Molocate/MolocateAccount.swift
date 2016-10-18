 //Molocate app. Account Related Functions
import UIKit
import RNCryptor
//Globals
 
let MolocateBaseUrl = "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/"
var IsExploreInProcess = false
var MoleCurrentUser: MoleUser = MoleUser()
var FaceUsername = ""
var FaceMail = ""
var FbToken = ""
let profileBackgroundColor = UIColor(netHex: 0xDCDDDF)

//Structs
 struct filter{
    var name = ""
    var raw_name = ""
    var isevent = false
    var thumbnail_url: URL?
    
 }
struct MoleUserFriend {
    var is_following = false
    var picture_url: URL?
    var thumbnail_url: URL?
    var username:String = ""
    var name: String = ""
}

struct MoleUserRelations{
    var relations = [MoleUserFriend]()
    var totalCount = 0
}

struct MoleUser{
    var username:String = ""
    var email : String = ""
    var profilePic:URL?
    var thumbnailPic:URL?
    var token: String = ""
    var first_name = ""
    var last_name = ""
    var post_count = 0;
    var tag_count = 0;
    var follower_count = 0;
    var following_count = 0;
    var place_following_count = 0;
    var different_checkins = 0;
    var isFollowing:Bool = false;
    var gender = "male"
    var birthday = "2016-10-12"
    var isFaceUser:Bool = false
    var bio = ""
    func printUser() -> Void {
        print("username: " + username)
        print("email: " + email)
        print("profile_pic: " + (profilePic?.absoluteString)!)
        print("token: " + token)
        print("first_name: "+first_name)
        print("last_name: "+last_name)
        print("post_count:  \(post_count)");
        print("tag_count:  \(tag_count)");
        print("follower_count:  \(follower_count)");
        print("following_count:  \(following_count)");
    }
}


//MolocateAccount:
open class MolocateAccount {
    
    static let timeOut = 8.0
    
    class func getFollowers(_ nextUrl: String = "", username: String, completionHandler: @escaping (_ data: MoleUserRelations, _ response: URLResponse?, _ error: NSError?, _ count: Int, _ next: String?, _ previous: String? ) -> ()) {
        
        let url: URL
        
        if(nextUrl == ""){
            url = URL(string: MolocateBaseUrl + "relation/api/followers/?username=" + (username as String) )!
        }else{
            url = URL(string:nextUrl)!
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))

            if(error == nil){
                let nsError = error;
                
                do {
                   // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    if(result.index(forKey: "results") != nil){
                        let count: Int = (result["count"] as? Int)!
                        let next =  result["next"] is NSNull ? "":result["next"] as? String
                        let previous =  result["previous"] is NSNull ? "":result["previous"] as? String
                        let results = result["results"] as! NSArray
                        
                        var followers = MoleUserRelations()
                        followers.totalCount = count
                        
                        var friends = [MoleUserFriend]()
                        
                            for i in 0..<results.count{
                                var friend = MoleUserFriend()
                                let thing = results[i] as! [String:AnyObject]
                           
                                friend.username = thing["username"] as! String
                                friend.name =  thing["first_name"] as! String
                                friend.picture_url = thing["picture_url"] is NSNull ? URL(string: ""):URL(string: thing["picture_url"] as! String)!
                                let thumbnail = thing["thumbnail_url"] as! String
                   
                                friend.thumbnail_url = thumbnail == "" ? friend.picture_url:URL(string: thumbnail)!
                                    let isfollowing = thing["is_following"] as! Int
                          
                                friend.is_following = isfollowing == 0 ? false:true
                            
                                friends.append(friend)
                            }
                        
                        
                        followers.relations = friends
                        
                        completionHandler(followers , response , nsError as NSError?, count, next, previous)
                    }else{
                        completionHandler(MoleUserRelations(), nil, nsError as NSError?, -1, nil, nil)
                        
                        if debug { print("ServerDataError:: in mole.getFollowers()") }
                    }
                } catch{
                    completionHandler(MoleUserRelations() , nil , nsError as NSError?, 0, nil, nil  )
                    if debug { print("JSONCastError:: in mole.getFollowers()") }
                }
            }else{
                    completionHandler(MoleUserRelations() , nil , error as NSError?, 0, nil, nil  )
                    if debug {print("RequestError:: in mole.getFollowers()")}
            }
            
        })
        task.resume()
    }
    
    
    
   class func getFacebookFriends(_ nextUrl: String = "",completionHandler: @escaping (_ data: MoleUserRelations, _ response: URLResponse?, _ error: NSError?, _ count: Int?, _ next: String?, _ previous: String?) -> ()){
    let url: URL
    if(nextUrl == ""){
        url = URL(string: MolocateBaseUrl + "account/api/facebook_friends/")!
    }else{
        url = URL(string:nextUrl)!
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
    request.timeoutInterval = timeOut
    
    let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        
        if error == nil{
            let nsError = error
            do {
                
                let response = String(data: data!, encoding: String.Encoding.utf8)
                
                if response!.characters[response!.startIndex] == "[" {
                
                let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Dictionary<String, AnyObject>]
                
                
                    var friends = MoleUserRelations()
                
                    for i in 0..<result.count{
                        var friend = MoleUserFriend()
                        let thing = result[i] 
                        friend.username = thing["username"] as! String
                        friend.name =  thing["first_name"] as! String
                        friend.picture_url = thing["picture_url"] is NSNull ? URL(string: ""):URL(string: thing["picture_url"] as! String)!
                        let thumbnail = thing["thumbnail_url"] as! String
                        
                        friend.thumbnail_url = thumbnail == "" ? friend.picture_url:URL(string: thumbnail)!
                        let isfollowing = thing["is_following"] as! Int
                        
                        friend.is_following = isfollowing == 0 ? false:true
                        friends.relations.append(friend)
                    
                    }
                    
                    completionHandler(friends , nil, nsError as NSError?, 0, nil, nil )
                }else{
                    completionHandler(MoleUserRelations() , nil , nsError as NSError?, 0, nil, ""  )
                    if debug {print("JSONCastError:: in mole.getFacebookFriends()")}
                }
              
            } catch{
                completionHandler(MoleUserRelations() , nil , nsError as NSError?, 0, nil, ""  )
                if debug {print("JSONCastError:: in mole.getFacebookFriends()")}
            }
        }else{
            completionHandler(MoleUserRelations() , nil , error as NSError?, 0, nil, ""  )
            if debug {print("RequestError:: in mole.getFacebookFriends()")}
        }
    })
    
    task.resume()
    
    }
    
    
    
    class func getSuggestedFriends(_ nextUrl: String = "",completionHandler: @escaping (_ data: MoleUserRelations, _ response: URLResponse?, _ error: NSError?, _ count: Int?, _ next: String?, _ previous: String?) -> ()){
        let url: URL
        if(nextUrl == ""){
            url = URL(string: MolocateBaseUrl + "account/api/suggested_users/")!
        }else{
            url = URL(string:nextUrl)!
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            if error == nil{
                let nsError = error
                do {
                    
                    let response = String(data: data!, encoding: String.Encoding.utf8)
                    
                    if response![(response?.startIndex)!]=="[" {
                        
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Dictionary<String, AnyObject>]
                    
                    var followings = MoleUserRelations()
            
                        for i in 0..<result.count{
                            var friend = MoleUserFriend()
                            let thing = result[i] 
                            friend.username = thing["username"] as! String
                            friend.name =  thing["first_name"] as! String
                            friend.picture_url = thing["picture_url"] is NSNull ? nil:URL(string: thing["picture_url"] as! String)!
                            let thumbnail = thing["thumbnail_url"] as! String
                            
                            friend.thumbnail_url = thumbnail == "" ? friend.picture_url:URL(string: thumbnail)!
                            let isfollowing = thing["is_following"] as! Int
                            
                            
                            friend.is_following = isfollowing == 0 ? false:true
                            
                            
                            
                            followings.relations.append(friend)
                        }
                    
                        
                        completionHandler(followings , nil , nsError as NSError?, 0, nil, nil  )
                    }else{
                        completionHandler(MoleUserRelations() , nil , nsError as NSError?, 0, nil, ""  )
                        if debug {print("JSONCastError:: in mole.getFacebookFriends()")}
                    }
                } catch{
                    completionHandler(MoleUserRelations() , nil , nsError as NSError?, 0, nil, ""  )
                    if debug {print("JSONCastError:: in mole.getFacebookFriends()")}
                }
            }else{
                completionHandler(MoleUserRelations() , nil , error as NSError?, 0, nil, ""  )
                if debug {print("RequestError:: in mole.getFacebookFriends()")}
            }
        })
        
        task.resume()
        
    }
    


    class func getFollowings(_ nextUrl: String = "",username: String, completionHandler: @escaping (_ data: MoleUserRelations, _ response: URLResponse?, _ error: NSError?, _ count: Int?, _ next: String?, _ previous: String?) -> ()){
        
        let url: URL
        if(nextUrl == ""){
            url = URL(string: MolocateBaseUrl + "relation/api/followings/?username=" + (username as String) )!
        }else{
            url = URL(string:nextUrl)!
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        
            if error == nil{
                let nsError = error
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                   
                    if(result.index(forKey: "results") != nil){
                        let count: Int = result["count"] as! Int
                        let next =  result["next"] is NSNull ? "":result["next"] as? String
                        let previous =  result["previous"] is NSNull ? "":result["previous"] as? String
                        let results = result["results"] as! NSArray
                        var followings = MoleUserRelations()
                        followings.totalCount = count
                        var friends = [MoleUserFriend]()
                        
              
                        for i in 0..<results.count{
                            var friend = MoleUserFriend()
                            let thing = results[i] as! [String:AnyObject]
                            friend.username = thing["username"] as! String
                            friend.name =  thing["first_name"] as! String
                            friend.picture_url = thing["picture_url"] is NSNull ? nil:URL(string: thing["picture_url"] as! String)!
                            let thumbnail = thing["thumbnail_url"] as! String
                            
                            friend.thumbnail_url = thumbnail == "" ? friend.picture_url:URL(string: thumbnail)!
                            let isfollowing = thing["is_following"] as! Int
                            
                           
                            friend.is_following = isfollowing == 0 ? false:true
                            
                            
                     
                            friends.append(friend)
                        }
                        
                        
                        followings.relations = friends
                        
                        completionHandler(followings , response , nsError as NSError?, count, next, previous  )
                    }else{
                        completionHandler(MoleUserRelations() , nil , nsError as NSError?, -1, nil, ""  )
                        if debug {print("ServerDataError:: in mole.getFollowings()")}
                    }
                } catch{
                    completionHandler(MoleUserRelations() , nil , nsError as NSError?, 0, nil, ""  )
                    if debug {print("JSONCastError:: in mole.getFollowings()")}
                }
            }else{
                   completionHandler(MoleUserRelations() , nil , error as NSError?, 0, nil, ""  )
                    if debug {print("RequestError:: in mole.getFollowings()")}
            }
        })
        
        task.resume()
        
    }
    
    class func getFollowingPlaces(_ username: String, completionHandler: @escaping (_ data: [MolePlace], _ response: URLResponse?, _ error: NSError? ) -> ()) {
        
        let url: URL
        url = URL(string: MolocateBaseUrl + "/account/api/following_places/?username=" + (username as String) )!

        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            if(error == nil){
                let nsError = error;
                
                do {
                     //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Dictionary<String,String>]
                //print(result.count)
                    if(result.count != 0){
                        var places = [MolePlace]()
                        for item in result {
                            var place = MolePlace()
                            place.name = item["name"]!
                            place.id = item["place_id"]!
                            place.address = item["address"]!
                            places.append(place)
                            
                        }
                     
                        completionHandler(places , response , nsError as NSError?)
                   }else{
                        completionHandler([MolePlace]() , nil , nsError as NSError? )
                        if debug { print("ServerDataError:: in mole.getFollowers()") }
                    }
                } catch{
                    completionHandler([MolePlace]() , nil , nsError as NSError? )
                    if debug { print("JSONCastError:: in mole.getFollowers()") }
                }
            }else{
                completionHandler([MolePlace]() , nil , error as NSError?)
                if debug {print("RequestError:: in mole.getFollowers()")}
            }
            
        })
        task.resume()
    }
    
    class func getCheckedInPlaces(username: String, completionHandler: @escaping (_ data: [MolePlace] ,_ response: URLResponse?,_ error: NSError? ) -> ()) {
        
        let url: URL
        url = URL(string: MolocateBaseUrl + "/account/api/checkedin_places/?username=" + username )!
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, Error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            if(Error == nil){
                let nsError = Error;
                
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Dictionary<String, String>]
                
                    if(result.count != 0){
                        var places = [MolePlace]()
                        for item in result {
                            var place = MolePlace()
                            place.name = item["name"]!
                            place.id = item["place_id"]!
                            place.address = item["address"]!
                            places.append(place)
                        }
                        
                        completionHandler(places , response , nsError as NSError?)
                    }else{
                        completionHandler([MolePlace]() , nil , nsError as NSError?)
                        
                        if debug { print("ServerDataError:: in mole.getFollowers()") }
                    }
                } catch{
                    completionHandler([MolePlace]() , nil , nsError as NSError?)
                    if debug { print("JSONCastError:: in mole.getFollowers()") }
                }
            }else{
                completionHandler([MolePlace]() , nil , Error as NSError?)
                if debug {print("RequestError:: in mole.getFollowers()")}
            }
            
        })
        task.resume()
    }


    
    class func Login(_ username: String, password: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let json = ["username": username, "password": password]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            
            let url = URL(string: MolocateBaseUrl + "api-token-auth/")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = timeOut
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
     
                if error==nil{
                    let nsError = error
                    do {
                        
                        let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                        
                        if(result.index(forKey: "token") != nil){
                            MoleUserToken = result["token"] as? String
                            
                            UserDefaults.standard.set(MoleUserToken, forKey: "userToken")

                            DispatchQueue.main.async(execute: {
                               
                                MolocateAccount.getCurrentUser({ (data, response, error) -> () in
                                    completionHandler("success" , response , nsError as NSError? )
                                })
                            
                                if(DeviceToken != nil){
                                    MolocateAccount.registerDevice({ (data, response, error) in
                                
                                    })
                                }
                            })
                            
                        }else {
                            completionHandler("Hata", response , nsError as NSError? )
                            if debug { print("Wrong password or username::in MolocateAccount.Login() ") }
                            
                        }
                        
                    } catch {
                        
                        completionHandler("error" , response , nsError as NSError? )
                        if debug { print("JSONError::in MolocateAccount.Login()") }
                    }
                }else{
                    
                    completionHandler("error" , response , error as NSError?)
                    if debug { print("RequestError::in MolocateAccount.Login()") }
                }
            })
            
            task.resume()
            
        } catch {
            completionHandler("JsonError" , URLResponse() , nil )
            if debug { print("JSONCastError::in MolocateAccount.Login()") }
        }
    }
    
    class func FacebookLogin(_ json: JSONParameters,completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let url = URL(string: MolocateBaseUrl + "/account/facebook_login/")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = timeOut
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
             
                if error == nil {
                    let Nserror = error
                    do {
                        
                        //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                        
                        let resultJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                        if(resultJson.index(forKey: "logged_in") != nil){
                            let logging = resultJson["logged_in"] as! Int
                            let loggedIn = logging == 1
                            
                            if loggedIn {
                                MoleUserToken = resultJson["access_token"] as? String
                                UserDefaults.standard.set(MoleUserToken, forKey: "userToken")

                                DispatchQueue.main.async(execute: {
                                    if(DeviceToken != nil && !isRegistered){
                                        MolocateAccount.registerDevice({ (data, response, error) in
                                            
                                        })
                                    }
                                })
                                completionHandler("success", response, error as NSError?)
                                
                            } else if let _ = resultJson["email_validation"]{
                                FaceMail = resultJson["email_validation"] as! String
                                FaceUsername = resultJson["suggested_username"] as! String
                                completionHandler("signup", response, error as NSError?)
                            }else{
                                completionHandler("error", response, error as NSError?)
                                if debug {print("JSONCastError:: in MolocateAccount.facebookLogin()")}
                            }
                        }else{
                            completionHandler("error", response, error as NSError?)
                            if debug {print("ServerDataError:: in MolocateAccount.facebookLogin()")}
                        }
                            
                    } catch{
    
                        completionHandler("error", response, Nserror as NSError?)
                        if debug {print("JSONCastError:: in MolocateAccount.facebookLogin() in start*")}
                    }
                }else{
                    completionHandler("error", response, error as NSError?)
                    if debug {print("RequestError:: in MolocateAccount.facebookLogin()")}
                }
            })
            task.resume()
        } catch {
            completionHandler("error", URLResponse(), nil)
        }
    }
    
    class func FacebookSignup(_ json: JSONParameters,completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let url = URL(string: MolocateBaseUrl + "/account/facebook_login/")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = timeOut
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if error == nil{
                    let Nserror = error
                    do {
                        
                        let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                        if(result.index(forKey: "logged_in") != nil){
                            let logging = result["logged_in"] as! Int
                            let notloggedin = logging == 0
                            
                            if notloggedin{
                                let usernameb = result["username"] as! String
                                let emailb = result["email"] as! String
                                let usernameExist: Bool = usernameb == "username_exists"
                                let emailNotValid: Bool = emailb  == "not_valid"
                                
                                if (usernameExist && emailNotValid){
                                    completionHandler("Kullanıcı adınız ve e-mailiniz daha önce alındı.", response, Nserror as NSError?)
                                } else {
                                    if usernameExist {
                                        completionHandler("Kullanıcı adı daha önce alındı.", response, Nserror as NSError?)
                                        
                                    } else {
                                        completionHandler("Lütfen e-mailinizi değiştirin.", response, Nserror as NSError?)
                                    }
                                }
                            }else {
                                MoleUserToken = result["access_token"] as? String
                                UserDefaults.standard.set(MoleUserToken, forKey: "userToken")

                                DispatchQueue.main.async(execute: {
                                    if(DeviceToken != nil){
                                        MolocateAccount.registerDevice({ (data, response, error) in
                                            
                                        })
                                    }
                                })
                                completionHandler("success", response, Nserror as NSError?)
                            }
                        }else{
                            completionHandler("error", response, Nserror as NSError?)
                            if debug { print("ServerDataError:: in MolocateAccount.facebookSignup()")}
                        }
                        
                    } catch{
                        completionHandler("error", response, Nserror as NSError?)
                        if debug { print("JSONCastError:: in MolocateAccount.facebookSignup()")}
                        
                    }
                }else{
                    completionHandler("error", response, error as NSError?)
                    if debug { print("RequestError:: in MolocateAccount.facebookSignup()")}
                }
            })
            task.resume()
        } catch {
            completionHandler("error", URLResponse(), nil)
            if debug { print("JsonError:: in MolocateAccount.facebookSignup() in start")}
        }
    }
    
    
    class func SignUp(_ username: String, password: String, email: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        //let json = ["username": username, "password": password, "email": email]
        
        let pureString = username+"+/"+password+"+/"+email
        //print(pureString)
    
            let pureData = pureString.data(using: String.Encoding.utf8)
            let passwordEnc = "3+bHv9S_7Q+HZdW"
        let encriptedString = RNCryptor.encrypt(data: pureData!, withPassword: passwordEnc)
            
            let url = URL(string: MolocateBaseUrl + "account/regisnew/")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("/*/", forHTTPHeaderField: "Content-Type")
            request.setValue("attachment;filename=register", forHTTPHeaderField: "Content-Disposition")
            request.httpBody = encriptedString
            request.timeoutInterval = timeOut
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                
           
                if error == nil {
                    let nsError = error
                    do {
                        //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                        let result = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                        if(result.index(forKey: "access_token") != nil){
                            MoleUserToken = result["access_token"] as? String
                            UserDefaults.standard.set(MoleUserToken, forKey: "userToken")
                            DispatchQueue.main.async(execute: {
                                if(DeviceToken != nil && !isRegistered){
                                    MolocateAccount.registerDevice({ (data, response, error) in
                                        
                                    })
                                }
                            })
                            completionHandler("success" , response , nsError as NSError? )
                            
                        } else if result.index(forKey: "result") != nil{
                            let servererror = result["result"] as! String
                           // print(error)
                            switch (servererror){
                            case "user_exist":
                                completionHandler("Lütfen daha önce kullanılmamış bir kullanıcı adı seçiniz." , response , nsError as NSError? )
                                break
                            case "not_valid":
                                completionHandler("Lütfen geçerli bir email adresi giriniz." , response , nsError as NSError? )
                                break
                            case "email_exists":
                                completionHandler("Lütfen daha önce kullanılmamış bir mail seçiniz." , response , nsError as NSError? )
                                break
                            default:
                                completionHandler("Lütfen daha önce kullanılmamış bir kullanıcı adı seçiniz." , response , nsError as NSError? )
                                break
                                
                            }
                        }else{
                            completionHandler("ServerDataError" , response , nsError as NSError? )
                            if debug {print("ServerDataError: in MolocateAccount.signup()")}
                        }
                        
                    } catch {
                        completionHandler("JsonError" , response , nsError as NSError? )
                        if debug {print("JSONCastError: in MolocateAccount.signup()")}
                    }
                }else{
                    completionHandler("RequestError check your internet connection" , response , error as NSError? )
                    if debug {print("RequestError: in MolocateAccount.signup()")}
                }
            })
            
            task.resume()
            
    
    }
    
    
    class func follow(_ username: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "/relation/api/follow/?username=" + (username as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
           // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        
            if error == nil {
                
                let nsError = error
                do {
                   let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "result") != nil{
                        completionHandler(result["result"] as? String , response , nsError as NSError? )
                    }else{
                        completionHandler("ServerDataError" , nil , nsError  as NSError?)
                        if debug{print("ServerDataError:: in MolocateAccount.follow()")}

                    }
                } catch{
                    completionHandler("JsonError" , nil , nsError as NSError? )
                    if debug{print("JSONError:: in MolocateAccount.follow()")}
                }
            }else{
                completionHandler("RequestError" , nil , error  as NSError?)
                if debug{print("RequestError:: in MolocateAccount.follow()")}
            }
        })
        
        task.resume()
        
    }
    
    
    class func registerDevice (_ completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "/activity/api/register_device/?device_token=" + (DeviceToken! as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            if error == nil {
                
                let nsError = error
                
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    
                    if result.index(forKey: "result") != nil {
                        isRegistered = true
                        UserDefaults.standard.set(true, forKey: "isRegistered")
                        UserDefaults.standard.set(DeviceToken, forKey: "DeviceToken")
                        completionHandler(result["result"] as? String , response , nsError as NSError?)
                        
                    }else{
                        completionHandler("ServerDataError" , nil , nsError as NSError? )
                        if debug {print("ServerDataError:: in MolcateAccount.registerDevice()")}
                    }
                } catch{
                    completionHandler("JsonError" , nil , nsError as NSError? )
                    if debug {print("JsonError:: in MolcateAccount.registerDevice()")}
                  
                }
            }else{
                completionHandler("RequestError" , nil , error as NSError? )
                if debug {print("RequestError:: in MolcateAccount.registerDevice()")}
            }
            
        })
        
        task.resume()
        
    }
    
    class func resetBadge (_ completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "/activity/api/zero_badge/")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        
            if error == nil {
                let nsError = error
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "result") != nil{
                        completionHandler(result["result"] as? String , response , nsError as NSError? )
                    }else{
                        completionHandler("ServerDataError" , nil , nsError as NSError? )
                        if debug {print("ServerDataError:: in MolocateAccount.resetBadge()")}

                    }
                 
                } catch{
                    completionHandler("JsonError" , nil , nsError as NSError? )
                    if debug {print("JsonError:: in MolocateAccount.resetBadge()")}
                }
            }else{
                completionHandler("RequestError" , nil , error as NSError?)
                if debug {print("RequestError:: in MolocateAccount.resetBadge()")}
            }
            
        })
        
        task.resume()
        
    }
    
    class func unregisterDevice (_ completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let url = URL(string: MolocateBaseUrl + "/activity/api/unregister_device/")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
       
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
              
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "result") != nil {
                        completionHandler(result["result"] as? String , response , nsError as NSError? )
                        UserDefaults.standard.set(false, forKey: "isRegistered")
                        UserDefaults.standard.set("", forKey: "DeviceToken")
                        isRegistered = false
                    }else{
                        completionHandler("ServerDataError" , nil , nsError as NSError? )
                       // print("ServerDataError:: in MolocateAccount.unregisterDevice()")
                    }
                } catch{
                    completionHandler("JsonError" , nil , nsError  as NSError?)
                   // print("JsonError:: in MolocateAccount.unregisterDevice()")
                }
            }else{
                completionHandler("JsonError" , nil , error as NSError? )
                //print("RequestError:: in MolocateAccount.unregisterDevice()")
            }
            
        })
        task.resume()
    }
    
    class func unfollow(_ username: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        let url = URL(string: MolocateBaseUrl + "relation/api/unfollow/?username=" + (username as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    if result.index(forKey: "result") != nil {
                        completionHandler(result["result"] as? String , response , nsError as NSError? )
                    }else{
                        completionHandler("ServerDataError" , nil , nsError as NSError? )
                        if debug { print("ServerDataError:: in MolocateAccount.unfollow()")}
                    }
                } catch{
                    completionHandler("JsonError" , nil , nsError as NSError? )
                    if debug { print("JsonError:: in MolocateAccount.unfollow()")}
                }
            }else{
                completionHandler("RequestError" , nil , error as NSError? )
                if debug { print("RequestError:: in MolocateAccount.unfollow()")}
            }
            
        })
        
        task.resume()
    }
    
    class func searchUser(_ username: String, completionHandler: @escaping (_ data: [MoleUser], _ response: URLResponse?, _ error: NSError?) -> ()) {

        var url = URLComponents(string: MolocateBaseUrl + "/account/api/search_user/")
        url?.queryItems = [URLQueryItem(name: "username", value: username)]
        var request = URLRequest(url: (url?.url)!)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
                let nsError = error;
                
                do {
                    //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [[String:AnyObject]]
                    
                    var userArray = [MoleUser]()
                    for item in result {
                        
                        var user = MoleUser()
                        user.username = item["username"] as! String
                        print(item["thumbnail_url"])
                        if item["thumbnail_url"] as! String == "" {
                           user.profilePic = item["picture_url"] is NSNull ? nil:URL(string:item["picture_url"] as! String)!
                        } else {
                            user.profilePic = item["thumbnail_url"] is NSNull ? nil:URL(string: item["thumbnail_url"] as! String)!
                        }
                        user.first_name = item["first_name"] as! String
                        user.last_name = item["last_name"] as! String
                        user.isFollowing = item["is_following"] as! Int == 1 ? true:false
                        userArray.append(user)
                        
                    }
                    completionHandler(userArray , nil , nsError as NSError? )
                
                } catch {
                    completionHandler([MoleUser]() , nil , nsError  as NSError?)
                    if debug { print("JSONError:: in MolocateAccount.searchUser()")}
                }
            }else{
                completionHandler([MoleUser]() , nil , error as NSError?)
                if debug { print("RequestError:: in MolocateAccount.searchUser()")}
            }
        })
        task.resume()
    }
    class func getUser(_ username: String, completionHandler: @escaping (_ data: MoleUser, _ response: URLResponse?, _ error: NSError?) -> ()) {
        
        let url = URL(string: MolocateBaseUrl + "account/api/get_user/?username=" + (username as String))!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
            let nsError = error;
            
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    //print(result)
                    if result.index(forKey: "email") != nil {
                        var user = MoleUser()
                        user.email = result["email"] as! String
                        user.username = result["username"] as! String
                        user.first_name = result["first_name"] as! String
                        user.last_name = result["last_name"] as! String
                        user.profilePic = result["picture_url"] is NSNull ? nil:URL(string: result["picture_url"] as! String)!
                        user.bio = result["caption"] is NSNull ? String() : result["caption"] as! String
                        user.follower_count = result["follower_count"] as! Int
                        user.following_count = result["following_count"] as! Int
                        user.place_following_count = result["place_count"] as! Int
                        user.different_checkins = result["check_in_count"] as! Int
                        user.tag_count = result["tag_count"] as! Int
                        user.post_count = result["post_count"]as! Int
                        user.isFollowing = result["is_following"] as! Int == 1 ? true:false
                        completionHandler(user, response , nsError as NSError? )
                    }else{
                        completionHandler(MoleUser() , nil , nsError  as NSError?)
                        if debug {print("ServerDataError:: in MolocateAccount.getUser()")}
                    }
                } catch{
                    completionHandler(MoleUser() , nil , nsError as NSError? )
                    if debug {print("JsonError:: in MolocateAccount.getUser()")}
                }
            }else{
                completionHandler(MoleUser() , nil , error as NSError?)
                if debug {print("RequestError:: in MolocateAccount.getUser()")}
            }
        })
        
        task.resume()
    }
    
    
    class func changePassword(_ old_password:String,new_password: String, completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        do{
            
            let Body = ["old_password": old_password,
                        "new_password": new_password]
            
            let jsonData = try JSONSerialization.data(withJSONObject: Body, options: JSONSerialization.WritingOptions())
            let url = URL(string: MolocateBaseUrl + "account/api/change_password/")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            request.timeoutInterval = timeOut
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                if error == nil {
                let nsError = error
                    do {
                        //check result if it is succed
                        let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                        if result.index(forKey: "result") != nil {
                            let answer = result["result"] as! String
                            completionHandler(answer  , response , nsError as NSError? )
                        }else{
                            completionHandler("ServerDataError" , nil , nsError  as NSError?)
                            if debug {print("ServerDataError:: in MolocateAccount.changePassword()")}
                        }
                    } catch{
                        completionHandler("JsonError" , nil , nsError  as NSError?)
                        if debug {print("JsonError:: in MolocateAccount.changePassword()")}
                    }
                }else {
                    completionHandler("RequestError" , nil , error as NSError?)
                    if debug {print("RequestError:: in MolocateAccount.changePassword()")}
                }
                
            })
            
            task.resume()
        }catch{
            completionHandler("JsonError" , nil , nil )
            if debug { print("JsonError:: in Molocate.changePassword() in start")}
        }
    }
    
    
    class func EditUser(_ completionHandler: @escaping (_ data: String? , _ response: URLResponse?, _ error: NSError?) -> ()){
        
        do{
            
            let Body = ["profile_pic": MoleCurrentUser.profilePic?.absoluteString,
                        "first_name": MoleCurrentUser.first_name,
                        "last_name": MoleCurrentUser.last_name,
                        "gender": MoleCurrentUser.gender,
                        "birthday": MoleCurrentUser.birthday,
                        "caption":MoleCurrentUser.bio
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: Body, options: JSONSerialization.WritingOptions())
            let url = URL(string: MolocateBaseUrl + "account/api/edit_user/")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData
            request.timeoutInterval = timeOut
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                if error == nil {
                let nsError = error
                    do {
                        //check result if it is succed
                        let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                    
                        if result.index(forKey: "following_count") != nil {
                            
                            completionHandler("success"  , response , nsError as NSError? )
                            
                        }else{
                            completionHandler("ServerError" , nil , nsError as NSError? )
                            if debug {print("ServerDataError:: in MolocateAccount.EditUser()")}

                        }
                       
                    } catch{
                        completionHandler("JsonError" , nil , nsError  as NSError?)
                        if debug {print("JsonError:: in MolocateAccount.EditUser()")}
                    }
                }else {
                    completionHandler("RequestError" , nil , error  as NSError?)
                    if debug {print("RequestError:: in MolocateAccount.EditUser()")}
                }
            })
            
            task.resume()
        }catch{
            completionHandler("JsonError" , nil , nil )
            if debug {print("JsonError:: in MolocateAccount.EditUser()")}
        }
    }
    
    class func sendProfilePhotoandThumbnail(_ image: Data, thumbnail: Data, completionHandler: @escaping (_ data: String?, _ pictureUrl: String, _ thumbnailUrl: String, _ response: URLResponse?, _ error: NSError?) -> ()){
      
        let headers = [
            "content-type": "multipart/form-data; boundary=---011000010111000001101001",
            "authorization": "Token " + MoleUserToken!
        ]
        let parameters = [
            [
                "name": "picture",
                "fileName": ["0": []],
                "content-type" : "image/jpeg"
            ],
            [
                "name": "thumbnail",
                "fileName": ["0": []],
                "content-type" : "image/jpeg"
            ]
        ]
        
        let boundary = "---011000010111000001101001"
        
       
        let postData = NSMutableData()
        
        for param in parameters {
            
            var body = ""
            let paramName = param["name"]!
            
            body += "--\(boundary)\r\n"
            
        
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            
            let filename = param["fileName"]
            let contentType = param["content-type"]!
    
            body += "; filename=\"\(filename)\"\r\n"
            body += "Content-Type: \(contentType)\r\n\r\n"
            postData.append(body.data(using: String.Encoding.utf8)!)
              
            
            if paramName as! String == "picture"{
                postData.append(image)
            }else{
                postData.append(thumbnail)
            }
        
        }
        
        postData.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        var request = URLRequest(url: URL(string: MolocateBaseUrl + "account/api/upload_both/")!,cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            do{
               
                
                if (error != nil) {
                    completionHandler("error" , "", "",response , error as NSError? )
                } else {
                    
                     let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: String]
                    if result.index(forKey: "thumbnail_url") != nil  {
                    
                    completionHandler("success", result["picture_url"]!, result["thumbnail_url"]!,response , error as NSError? )
                        
                    }else{
                          completionHandler("error" , "", "",response , nil  )
                    }
                }
            }catch{
                completionHandler("error" , "", "",response , nil  )
            }
        })
        
        dataTask.resume()
    }
    
    
    class func uploadProfilePhoto(_ image: Data, completionHandler: @escaping (_ data: String?, _ response: URLResponse?, _ error: NSError?) -> ()){
        
        let headers = ["content-type": "/*/", "content-disposition":"attachment;filename=molocate.png" ]
        
        var request = URLRequest(url: URL(string: MolocateBaseUrl + "/account/api/upload_picture/")!, cachePolicy:.useProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.httpBody = image
        request.timeoutInterval = timeOut
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error  in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error;
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: String]
                    if result.index(forKey: "result") != nil{
                        var urlString = ""
                        let message = result["result"]
                        if(message == "success"){
                            urlString = result["picture_url"]!
                        }else{
                            urlString = ""
                        }
                        completionHandler(urlString, response , nsError  as NSError?)
                    }else{
                        completionHandler("ServerDataError" , nil , nsError  as NSError?)
                        if debug {print("ServerDataError:: in MolocateAccount.uploadProfilePhoto()")}
                    }
                   
                } catch{
                    completionHandler("JsonError" , nil , nsError as NSError? )
                    if debug {print("JsonError:: in MolocateAccount.uploadProfilePhoto()")}
                }
            }else{
                completionHandler("RequestError" , nil , error as NSError? )
                if debug {print("RequestError:: in MolocateAccount.uploadProfilePhoto()")}
            }
            
        })
        
        task.resume();
        
    }
    
    class func setProfilePictures(){
        getDataFromUrl(MoleCurrentUser.profilePic!) { (data, response, error) in
            DispatchQueue.main.async(execute: {
                if data != nil{
                    UserDefaults.standard.set(data, forKey: "profile_picture")
                }
            })
        }
        getDataFromUrl(MoleCurrentUser.thumbnailPic! ) { (data, response, error) in
            DispatchQueue.main.async(execute: {
                if data != nil{
                    UserDefaults.standard.set(data, forKey: "thumbnail_picture")
                }
            })
        }
    }
    
    
    class func getDataFromUrl(_ url: URL, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ Error: NSError? ) -> ()) {
        
        let task = URLSession.shared.dataTask(with: url) { (data,response,error) in
                completionHandler(data, response, error as? NSError)
        }
        task.resume()
    }
    
    class func getCurrentUser(_ completionHandler: @escaping (_ data: MoleUser, _ response: URLResponse?, _ error: NSError?) -> ()) {
        
        let url = URL(string: MolocateBaseUrl +  "/account/api/current/")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error  in
            if error == nil {
                let nsError = error;
            
                do {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    
                    if result.index(forKey: "email") != nil{
                        MoleCurrentUser.email = result["email"] as! String
                        MoleCurrentUser.username = result["username"] as! String
                        MoleCurrentUser.first_name = result["first_name"] as! String
                        MoleCurrentUser.last_name = result["last_name"] as! String
                        
                        let profile_picture = result["picture_url"] is NSNull ? URL(string: ""):URL(string: result["picture_url"] as! String)!
                        
                        if profile_picture?.absoluteString != MoleCurrentUser.profilePic?.absoluteString{
                           
                            MoleCurrentUser.profilePic = result["picture_url"] is NSNull ? URL(string: "")!:URL(string: (result["picture_url"] as! String))!
                            
                            MoleCurrentUser.thumbnailPic = result["thumbnail_url"] is NSNull ? MoleCurrentUser.profilePic :URL(string: result["picture_url"] as! String)!
                            setProfilePictures()
                        }
                        MoleCurrentUser.bio = result["caption"] is NSNull ? String() : result["caption"] as! String
                        MoleCurrentUser.tag_count = result["tag_count"] as! Int
                        MoleCurrentUser.post_count = result["post_count"] as! Int
                        MoleCurrentUser.follower_count = result["follower_count"] as! Int
                        MoleCurrentUser.following_count = result["following_count"]as! Int
                        MoleCurrentUser.place_following_count = result["place_count"] as! Int
                        MoleCurrentUser.different_checkins = result["check_in_count"] as! Int
                        MoleCurrentUser.gender =  result["gender"] is NSNull ? "": (result["gender"] as! String)
                        MoleCurrentUser.birthday = result["birthday"] is NSNull || (result["birthday"] as! String)   == "" ? "1970-01-01" : result["birthday"] as! String
                        
                        if result["is_facebook_created_user"] as! Int == 0 {
                            MoleCurrentUser.isFaceUser = false
                        } else {
                            MoleCurrentUser.isFaceUser = true
                        }
                       // print(MoleCurrentUser.token)
                        completionHandler(MoleCurrentUser, response , nsError as NSError? )
                    }else{
                        completionHandler(MoleCurrentUser , nil , nsError as NSError? )
                        if debug {print("ServerDataError:: in MolocateAccount.getCurrentUser()")}
                    }
                    
                } catch{
                    completionHandler(MoleCurrentUser , nil , nsError as NSError? )
                    if debug {print("JsonError:: in MolocateAccount.getCurrentUser()")}
                }
            }else{
                completionHandler(MoleCurrentUser , nil , error as NSError? )
                if debug {print("RequestError:: in MolocateAccount.getCurrentUser()")}
            }
            
        })
        
        task.resume();
        
    }
    
    
    
}
