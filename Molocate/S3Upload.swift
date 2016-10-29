//
//  S3upload.swift
//  Molocate
//
//  Created by Kagan Cenan on 23.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import Foundation
import AWSS3



open class S3Upload {
   
    var isUp = false
    var isFailed = false

    var completionHandler:AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var expression: AWSS3TransferUtilityUploadExpression?
    var video_id = 0
    var theRequest:VideoUploadRequest?
    
    init(){
        
        self.expression = AWSS3TransferUtilityUploadExpression()
        self.expression?.progressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) in
            DispatchQueue.main.async(execute: {
                
                if debug{print(progress.fractionCompleted)}
                var progressInfo = Dictionary<String, Any>()
                progressInfo["progress"] =  Float(progress.fractionCompleted)
                progressInfo["id"] = self.video_id
                if let i = VideoUploadRequests.index(where: {$0.id == self.video_id}) {
                    VideoUploadRequests[i].progress = Float(progress.fractionCompleted)
                }
                NotificationCenter.default.post(name: TimelineController.updateProgressNotification, object:nil, userInfo: progressInfo)
                
            })
        }
        
        self.completionHandler = {(task, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                if (error != nil){
                    
                    if !self.isFailed{
                        self.isFailed = true
                        let userinf = ["id":self.video_id]
                        task.cancel()
                        NotificationCenter.default.post(name: TimelineController.prepareForRetryNotification, object: nil, userInfo:userinf )
                        MolocateVideo.encodeGlobalVideo()
                    }
                    
                    if debug {
                        print("Failed with error")
                        print("Error: %@",error!);
                        
                    }
                }else{

                    
                    self.sendThumbnailandData(self.theRequest!.thumbnail, info: (self.theRequest?.JsonData)!, videoid: self.video_id, completionHandler: { (data, thumbnailUrl, videoid, response, error) in
                        print(data)
                        if data == "success" {
                            self.isUp = true
                            
                            DispatchQueue.main.async(execute: {
                                
                                do {
                                    if let i = VideoUploadRequests.index(where: {$0.id == videoid}) {
                                        
                                        if debug { print("video deleted with id:\(videoid)") }
                                        try FileManager.default.removeItem(at: VideoUploadRequests[i].uploadRequest.body)
                                        
                                        NotificationCenter.default.post(name: TimelineController.uploadFinishedNotification, object: nil, userInfo: ["id": i])
                                        VideoUploadRequests.remove(at: i)
                                       
                                        MolocateVideo.encodeGlobalVideo()
                                        
                                        MyS3Uploads.remove(at: i)
                                    }
                                } catch _ {
                                    if debug { print(error) }
                                }
                                
                            })
                            
                        }else if !self.isFailed{
                            self.isFailed = true
                            let userinf = ["id":self.video_id]
                            task.cancel()
                            NotificationCenter.default.post(name: TimelineController.prepareForRetryNotification, object: nil, userInfo:userinf )
                            MolocateVideo.encodeGlobalVideo()
                        }
                        
                    })
                    
                }
                
            })
        }

    }
    
    func upload(_ retry:Bool = false, id:Int,uploadRequest: AWSS3TransferManagerUploadRequest, fileURL: String, fileID: String, json:  [String:Any], thumbnail_image: Data) {
        
        if debug { print("upload started with id:\(id)")};
        
        self.isUp = false
        self.isFailed = false
        self.video_id = id
        
        if !retry {
                self.theRequest = VideoUploadRequest(filePath: fileURL, thumbnail: thumbnail_image, JsonData: json, fileId: fileID, uploadRequest: uploadRequest, id:id, isFailed: false, progress: 0.0)
                VideoUploadRequests.insert(theRequest!, at:0)
                MolocateVideo.encodeGlobalVideo()
        }
    
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.configuration.timeoutIntervalForResource = 50.0
        transferUtility.uploadFile(uploadRequest.body, bucket: uploadRequest.bucket!, key: uploadRequest.key!, contentType: "text/plain", expression: expression, completionHander: completionHandler)

    }
    

    func sendThumbnailandData(_ thumbnail: Data, info: [String:Any], videoid: Int, completionHandler: @escaping (_ data: String?, _ thumbnailUrl: String, _ videoid: Int, _ response: URLResponse?, _ error: NSError?) -> ()){
        
        var string_info:Data = Data()
        
        do {
             string_info = try JSONSerialization.data(withJSONObject: info, options:  JSONSerialization.WritingOptions.prettyPrinted)
        }catch{
            
            print("Error in senThumbnailanData Json Serialization")
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
            
            if param["fileName"] != nil {
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
        
        var request = URLRequest(url: URL(string:  MolocateBaseUrl + "video/api/upload_video_thumbnail/")!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 50.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            do{
                
                let data_string  = String(data: data!, encoding: String.Encoding.utf8)!
                if data_string[data_string.startIndex] == "{" {
                    let result = try JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    if (error != nil) {
                        completionHandler("error" , "",0,response , error as NSError?  )
                    } else {
                        if result.index(forKey: "thumbnail") != nil {
                            
                            completionHandler("success", result["thumbnail"]! as! String,videoid,response , error as NSError?  )
                        }else{
                            completionHandler("error" , "",0,response , nil  )
                        }
                    }
                }else{
                       completionHandler("error" , "",0,response , nil  )
                }
            }catch{
                completionHandler("error" , "",0,response , nil  )
            }
        })
        
        dataTask.resume()
        
    }
    
    
    //
    //
    //    func cancelUploadRequest(_ uploadRequest: AWSS3TransferManagerUploadRequest) {
    //
    //        uploadRequest.cancel().continue({ (task) -> AnyObject! in
    //            if task.error != nil {
    //                print("cancel() failed: [\(task.error)]")
    //            }
    //            if task.exception != nil {
    //               print("cancel() failed: [\(task.exception)]")
    //            }
    //            return nil
    //        })
    //        
    //    }
    //    

}
