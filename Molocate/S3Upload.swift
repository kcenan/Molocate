//
//  S3upload.swift
//  Molocate
//
//  Created by Kagan Cenan on 23.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import Foundation
import AWSS3

let CognitoRegionType = AWSRegionType.usEast1
let DefaultServiceRegionType = AWSRegionType.euCentral1
let CognitoIdentityPoolId: String = "us-east-1:721a27e4-d95e-4586-a25c-83a658a1c7cc"
let S3BucketName: String = "molocatebucket"
var n = 0

open class S3Upload {
    var isUp = false
    var isFailed = false
    var uploadTask:AWSS3TransferUtilityTask?
    var completionHandler:AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var key_id = 0
    var theRequest:VideoUploadRequest?
    
    func upload(_ retry:Bool = false, id:Int,uploadRequest: AWSS3TransferManagerUploadRequest, fileURL: String, fileID: String, json:  [String:AnyObject], thumbnail_image: Data) {
        
        print("upload started with id:\(id)")
        isUp = false
        isFailed = false
        key_id = id
       
        if !retry {
            do{
                
                //var image = thumbnail_image
//                
//                if image == nil {
//                    let data = NSData(contentsOfURL: (VideoUploadRequests[id].thumbUrl))
//                    let nimage = UIImage(data: data!)
//                    image = UIImageJPEGRepresentation(nimage!, 0.5)
//
//                }
                let outputFileName = "thumbnail.jpg"
        
                let outputFilePath: String = (NSTemporaryDirectory() as NSString).appendingPathComponent(outputFileName)
                
                try thumbnail_image.write(to: URL(fileURLWithPath: outputFilePath), options: .atomicWrite )
                
                let thumb = URL(fileURLWithPath: outputFilePath)
                
              
                

                print("VideoUploadRequest created with id:\(id)")
                
                theRequest = VideoUploadRequest(filePath: fileURL,thumbUrl: thumb, thumbnail: thumbnail_image, JsonData: json, fileId: fileID, uploadRequest: uploadRequest, id:id, isFailed: false)
                
                VideoUploadRequests.insert(theRequest!, at:0)
              
                
                MolocateVideo.encodeGlobalVideo()
                
            }catch{
               // print("uploadRequest cannot created")
            }
        }
        
        if VideoUploadRequests.count != 0 {
            UserDefaults.standard.set(false, forKey: "isStuck")
        }
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.uploadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                if self.uploadTask == nil {
                    self.uploadTask = task
                }
                //print(bytesSent)
                if totalBytesSent <= totalBytesExpectedToSend {
                    progressBar?.progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    var progressInfo = Dictionary<String, AnyObject>()
                    progressInfo["progress"] =  Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    progressInfo["id"] = id
               
                    print("progress updated with id:\(id)")
                    NSNotificationCenter.defaultCenter().postNotificationName("updateProgress", object:nil, userInfo: progressInfo)
                }else{
                    
                }
                
            })
        }
        
        self.completionHandler = {(task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if ((error) != nil){
                    //print("Failed with error")
                   // print("Error: %@",error!);
                }else{
                
                    self.sendThumbnailandData(self.theRequest!.thumbnail, info: json, videoid:id, completionHandler: { (data, thumbnailUrl, videoid, response, error) in
                        if data == "success" {
                            self.isUp = true
                         DispatchQueue.main.asynchronously(execute: {
                            do {
                              
                                CaptionText = ""
                 
                                if let i = VideoUploadRequests.index(where: {$0.id == videoid}) {
                                    print("video deleted with id:\(id)")
                                    try FileManager.defaultManager().removeItemAtURL(VideoUploadRequests[i].uploadRequest.body)
                                  
                                    NotificationCenter.defaultCenter().postNotificationName("uploadFinished", object: nil, userInfo: ["id":i])
                                    
                                    VideoUploadRequests.remove(at: i)
                                    
                                    MolocateVideo.encodeGlobalVideo()
                                    
                                    if VideoUploadRequests.count == 0 {
                                        UserDefaults.standardUserDefaults.setBool(false, forKey: "isStuck")
                                    }
                                    
                                    
                                    MyS3Uploads.remove(at: i)
                                   
                                    
                                }
                                
                                
                                
                                n = 0
               
                            
                               
                            } catch _ {
                        
                            }
                            
                         })
                        }else if !self.isFailed{
                            self.isFailed = true
                            let userinf = ["id":videoid]
                            NotificationCenter.default.postNotificationName("prepareForRetry", object: nil, userInfo:userinf )
                            MolocateVideo.encodeGlobalVideo()
                        }
                    })

                }
            
            })
        }

      
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadFile(uploadRequest.body, bucket: uploadRequest.bucket!, key: uploadRequest.key!, contentType: "text/plain", expression: expression, completionHander: completionHandler).continue { (task) -> AnyObject? in

            if ((task.error) != nil) {
                //print("Error: %@", task.error)
        
            }
            if ((task.exception) != nil) {
               // print("Exception: %@", task.exception)
            }
            if ((task.result) != nil) {
                let uploadTask = task.result
                // Do something with uploadTask.
        
                let seconds = 100.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(delay))
                dispatch_after(dispatchTime, DispatchQueue.main, {
                    //print("18s passed")
                    if !self.isUp && !self.isFailed{
                        //print("cancel")
                        uploadTask?.cancel()
                        let userinf = ["id":id]
                        NSNotificationCenter.defaultCenter().postNotificationName("prepareForRetry", object: nil, userInfo:userinf )
                        MolocateVideo.encodeGlobalVideo()
                        
                    }
                    
                })

            }
            
            return nil
        }
 
    }
    

    
    
    func cancelUploadRequest(_ uploadRequest: AWSS3TransferManagerUploadRequest) {
    
        uploadRequest.cancel().continue({ (task) -> AnyObject! in
            if task.error != nil {
               // print("cancel() failed: [\(error)]")
            }
            if task.exception != nil {
              //  print("cancel() failed: [\(exception)]")
            }
            return nil
        })
        
    }
    
    func sendThumbnailandData(_ thumbnail: Data, info: [String:AnyObject], videoid: Int, completionHandler: @escaping (_ data: String?, _ thumbnailUrl: String, _ videoid: Int, _ response: URLResponse?, _ error: NSError?) -> ()){
        
        
        var string_info:Data = Data()
        
        do {
             string_info = try JSONSerialization.data(withJSONObject: info, options:  JSONSerialization.WritingOptions.prettyPrinted)
        }catch{
            
           // print("Errrorororororo")
        }
        
    
        
        let headers = [
            "content-type": "multipart/form-data; boundary=---011000010111000001101001",
            "authorization": "Token " + MoleUserToken!
        ]
        
        let parameters = [
            
            [
                "name": "file",
                "fileName": ["0": []],
                "content-type" : "image/jpeg",
                "value": thumbnail
            ],
            [
                "name": "info",
                "value": string_info,
                "filename": ["0": []],
                "content-type" : "application/json",
                
            ]
            
        ]
        
        let boundary = "---011000010111000001101001"
        
        
        let postData = NSMutableData()
        
        for param in parameters {
            
            var body = ""
            let paramName = param["name"]!
            
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            
            if let filename = param["fileName"] {
                let filename = param["fileName"]
                let contentType = param["content-type"]!
                
                body += "; filename=\"\(filename)\"\r\n"
                body += "Content-Type: \(contentType)\r\n\r\n"
                postData.append(body.data(using: String.Encoding.utf8)!)
                postData.append(thumbnail)
                
            }else{
                body+="\r\n\r\n"
                postData.append(body.data(using: String.Encoding.utf8)!)
                postData.append(param["value"] as! Data)
            }
            
        }
        
        postData.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: URL(string:  MolocateBaseUrl + "video/api/upload_video_thumbnail/")!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            do{
                progressBar?.isHidden = true
                let data_string  = String(data: data!, encoding: String.Encoding.utf8)!
               // print("data_string:" + data_string)
                if data_string[0] == "{" {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    
                    if (error != nil) {
                        completionHandler(data:"error" , thumbnailUrl: "",videoid: 0,response: response , error: error  )
                    } else {
                        if result.index(forKey: "thumbnail") != nil {
                        completionHandler(data: "success", thumbnailUrl: result["thumbnail"]! as! String,videoid: videoid,response: response , error: error  )
                        }else{
                        completionHandler(data:"error" , thumbnailUrl: "",videoid: 0,response: response , error: nil  )
                        }
                    }
                }else{
                       completionHandler(data:"error" , thumbnailUrl: "",videoid: 0,response: response , error: nil  )
                }
            }catch{
                completionHandler(data:"error" , thumbnailUrl: "",videoid: 0,response: response , error: nil  )
            }
        })
        
        dataTask.resume()
        
    }
    





}
