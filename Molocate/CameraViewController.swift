//  CameraViewController.swift
//  Molocate


import UIKit
import AssetsLibrary
import AVFoundation
import Photos
import QuadratTouch
import RecordButton
import CoreLocation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


var locationDict:[[String:locationss]]!
var placeOrder:NSMutableDictionary!
var valuell:String!
var valuellacc:String!
var valuealt:String!
var valuealtacc:String!
struct locationss{
    var id = ""
    var name = ""
    var lat:Float!
    var lon:Float!
    var adress = ""
}
private var SessionRunningContext = UnsafeMutableRawPointer.allocate(bytes: 10, alignedTo: 1)
private enum AVCamSetupResult: Int {
    case success
    case cameraNotAuthorized
    case sessionConfigurationFailed
}

var videoPath: String? = ""
var videoData: Data?
var fakeoutputFileURL: URL?
var fakebackgrounID: NSInteger?
var placesArray = [String]()
var videoId:String!
var videoUrl:String!
var tempAssetURL: URL!
var audioAsset:AVAsset!
var thumbnail = UIImage()
typealias JSONParameters = [String: AnyObject]

class CameraViewController: UIViewController,CLLocationManagerDelegate, AVCaptureFileOutputRecordingDelegate{
    fileprivate var recordButton : RecordButton!
    fileprivate var progressTimer : Timer!
    fileprivate var progress : CGFloat! = 0
    fileprivate var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    fileprivate var rootLayer = CALayer()
    fileprivate var camera = true
    fileprivate var videoURL:URL?
    fileprivate var sessionQueue: DispatchQueue?
    fileprivate var vurl: URL?
    fileprivate var topLayer = CALayer()
    fileprivate var flashLayer = CALayer()
    fileprivate var bottomLayer = CALayer()
    fileprivate var firstAsset:AVAsset!
    fileprivate var secondAsset:AVAsset!
    fileprivate var isFlashMode = false
    fileprivate var deviceLat: CLLocationDegrees?
    fileprivate var deviceLon: CLLocationDegrees?
    fileprivate var brightness:CGFloat = 0.0
    @IBOutlet var toolbarYancı: UILabel!
    var videoClips:[URL] = [URL]()
    @IBOutlet var bottomToolbar: UIToolbar!
    @IBOutlet var toolbar: UIToolbar!
    fileprivate var setupResult: AVCamSetupResult = .success
    fileprivate var sessionRunning: Bool = false
    fileprivate var backgroundRecordingID: UIBackgroundTaskIdentifier = 0
    fileprivate var videoDeviceInput: AVCaptureDeviceInput!
    
    
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureMovieFileOutput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recordingDelegate: AVCaptureFileOutputRecordingDelegate?
    
    var location:CLLocation!
    var locationManager:CLLocationManager!
    var firstFront = false
    
    var locationMeasurements : NSMutableArray!
    var bestEffortAtLocation : CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationMeasurements = NSMutableArray()
        placesArray.removeAll()
        placeOrder = NSMutableDictionary()
        placeOrder.removeAllObjects()

        locationDict = [[String:locationss]]()

        self.captureSession = AVCaptureSession()
        captureSession?.automaticallyConfiguresApplicationAudioSession = false
        
        self.sessionQueue = DispatchQueue(label: "session queue", attributes: [])
  
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.session = self.captureSession
//        let bounds = self.view.bounds
//        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
//        previewLayer?.bounds = bounds
//        previewLayer!.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        //previewLayer?.contentsGravity = AVLayerVideoGravityResizeAspect
        captureSession?.sessionPreset = AVCaptureSessionPreset640x480
        
       

        self.setupResult = AVCamSetupResult.success
        
        // Check video authorization status. Video access is required and audio access is optional.
        // If audio access is denied, audio is not recorded during movie recording.
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            self.sessionQueue!.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) {granted in
                if !granted {
                    self.setupResult = AVCamSetupResult.cameraNotAuthorized
                }
                self.sessionQueue!.resume()
            }
        default:
            // The user has previously denied access.
            self.setupResult = AVCamSetupResult.cameraNotAuthorized
        }

        
        self.sessionQueue!.async {
            guard self.setupResult == AVCamSetupResult.success else {
                return
            }

            self.backgroundRecordingID = UIBackgroundTaskInvalid
            
            let videoDevice = CameraViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.front)
            let videoDeviceInput: AVCaptureDeviceInput!
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
            } catch let error as NSError {
                videoDeviceInput = nil
                NSLog("Could not create video device input: %@", error)
            } catch _ {
                fatalError()
            }
            
            
            

            self.captureSession!.beginConfiguration()
            
            
            if self.captureSession!.canAddInput(videoDeviceInput) {
                self.captureSession!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async {
                self.initGui()
                self.previewLayer?.connection.videoOrientation
                    
                }
            } else {
                NSLog("Could not add video device input to the session")
                self.setupResult = AVCamSetupResult.sessionConfigurationFailed
            }
            
            let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            let audioDeviceInput: AVCaptureDeviceInput!
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                
            } catch let error as NSError {
                audioDeviceInput = nil
                NSLog("Could not create audio device input: %@", error)
            } catch _ {
                fatalError()
            }
            
            if self.captureSession!.canAddInput(audioDeviceInput) {
                self.captureSession!.addInput(audioDeviceInput)
            } else {
                NSLog("Could not add audio device input to the session")
            }
            
            let movieFileOutput = AVCaptureMovieFileOutput()
            let preferredTimeScale:Int32 = 30
            let totalSeconds:Int64 = Int64(Int(15) * Int(preferredTimeScale))
            let maxDuration:CMTime = CMTimeMake(totalSeconds, preferredTimeScale)
            movieFileOutput.maxRecordedDuration = maxDuration
            if self.captureSession!.canAddOutput(movieFileOutput) {
                self.captureSession!.addOutput(movieFileOutput)
                let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo)
                if connection?.isVideoStabilizationSupported ?? false {
                    connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                }
                self.videoOutput = movieFileOutput
                
            } else {
                NSLog("Could not add movie file output to the session")
                //self.setupResult = AVCamSetupResult.SessionConfigurationFailed
            }
            
            
            self.captureSession!.commitConfiguration()
            if UIApplication.shared.isIgnoringInteractionEvents {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        

     
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (AVAudioSession.sharedInstance().category != AVAudioSessionCategoryPlayAndRecord) {
            try! AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation )
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.allowBluetooth, .defaultToSpeaker, .mixWithOthers])
            try! AVAudioSession.sharedInstance().setActive(true)
            //try! AVAudioSession.sharedInstance().setActive(true)
        }
        
        self.sessionQueue!.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.captureSession!.startRunning()
                self.sessionRunning = self.captureSession!.isRunning
                
            case .cameraNotAuthorized:
                DispatchQueue.main.async{
                    if UIApplication.shared.isIgnoringInteractionEvents {
                        UIApplication.shared.endIgnoringInteractionEvents()
                    }
                    let message = NSLocalizedString("Molocate'in kamera kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
                    let alertController = UIAlertController(title: "Molocate Kamera", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    // Provide quick access to Settings.
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.default) {action in
                        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                        
                    }
                    alertController.addAction(settingsAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            case .sessionConfigurationFailed:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Çekim için uygun değil", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            let seconds = 5.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                
                self.displayLocationInfo(self.bestEffortAtLocation)
                
            })
            
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    func initGui(){
        videoDone.isEnabled = false
        toolbar.barTintColor = swiftColor
        toolbar.isTranslucent = false
        toolbar.clipsToBounds = true
        let width = self.view.frame.width
        let height = (self.view.frame.height-self.view.frame.width-2*self.toolbar.frame.height-self.toolbarYancı.frame.height)
        let topRect = CGRect(x: 0, y: self.view.frame.width+self.toolbar.frame.height+self.toolbarYancı.frame.height, width: width, height: height)
        let nview = UIView(frame: topRect)
        bottomToolbar.barTintColor = swiftColor
        bottomToolbar.isTranslucent = false
        bottomToolbar.clipsToBounds = true
        recordButton = RecordButton(frame: CGRect(x: 0,y: 0,width: 2*topRect.height/3,height: 2*topRect.height/3))
        recordButton.center = nview.center
        recordButton.progressColor = .red
        recordButton.closeWhenFinished = false
        recordButton.buttonColor = swiftColor
        recordButton.addTarget(self, action: #selector(CameraViewController.holdDown), for: .touchDown)
        recordButton.addTarget(self, action: #selector(CameraViewController.holdRelease), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(CameraViewController.holdRelease), for: UIControlEvents.touchDragExit)
        recordButton.addTarget(self, action: #selector(CameraViewController.holdDown), for: UIControlEvents.touchDragEnter)
        
        recordButton.center.x = self.view.center.x
        view.addSubview(recordButton)
        // This part is for the square shaped capture. Actually our capture is on all screen like normal camera but we are reducing that into square shaped with the two cover layer.
        let newFrame = CGRect(x: 0, y: 60, width: self.view.frame.width, height: self.view.frame.width*4/3)
        self.previewLayer!.frame = newFrame
        // let y = (self.view.frame.height+self.view.frame.width)/2
        //let bottomRect = CGRect(x: 0, y: 0, width: width , height: height)
        self.topLayer.frame = topRect
        //self.bottomLayer.frame = bottomRect
        self.topLayer.backgroundColor = UIColor.white.cgColor
        //self.bottomLayer.backgroundColor = UIColor.whiteColor().CGColor
        self.topLayer.opacity = 1
        self.bottomLayer.opacity = 1
        self.toolbar.layer.opacity = 1
        self.toolbarYancı.layer.opacity = 1
        self.bottomToolbar.layer.opacity = 1
        
        self.view.layer.addSublayer(self.previewLayer!)
        self.view.layer.addSublayer(self.bottomLayer)
        self.view.layer.addSublayer(self.bottomToolbar.layer)
        self.view.layer.addSublayer(self.topLayer)
        self.view.layer.addSublayer(self.toolbar.layer)
        self.view.layer.addSublayer(self.toolbarYancı.layer)
        self.view.layer.addSublayer(self.recordButton.layer)
        self.view.layer.addSublayer(self.flashButton.layer)

        
    
    }
    
    private func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let locationAge = newLocation.timestamp.timeIntervalSinceNow
        
        //print(locationAge)
        if locationAge > 5 {
            return
        }

        if (bestEffortAtLocation == nil) || (bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
            self.bestEffortAtLocation = newLocation
            if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
                        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
                            if (error != nil) {
                                //print("Reverse geocoder failed with error" + error!.localizedDescription)
                                return
                            }
                
                            if placemarks!.count > 0 {
                               // let pm = placemarks![0] as CLPlacemark
                                self.displayLocationInfo(newLocation)
                
                
                                
                            } else {
                                //print("Problem with the data received from geocoder")
                            }
                        })            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      displayAlert("Hata", message: "Konumunuza Erişilemedi")

    }

    
    func displayLocationInfo(_ location: CLLocation) {
            //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        let session = Session.sharedSession()
        
    
        //var parameters = [Parameter.query:"moda sahil"]
        let parameters = location.parameters(bool: true)
    
        
        let searchTask = session.venues.search(parameters) {
            (result) -> Void in
            DispatchQueue.main.async(execute: {
                ////print(result)
                locationDict.removeAll()
                placesArray.removeAll()
                placeOrder.removeAllObjects()
                if let response = result.response {
                    
                    
                    let venues = response["venues"] as! [JSONParameters]?
                    for i in 0..<venues!.count{
                        let item = venues![i]
                        let itemlocation = item["location"] as! [String:AnyObject]
                        let itemstats = item["stats"] as! [String:AnyObject]
                        let isVerified = item["verified"] as! Bool
                        let checkinsCount = itemstats["checkinsCount"] as! NSInteger
                        let enoughCheckin:Bool = (checkinsCount > 300)
                        
                            if(isVerified||enoughCheckin){
                                placeOrder.setObject(placesArray.count , forKey: (item["name"] as! String as NSCopying))
                                placesArray.append(item["name"] as! String)
                                let name = item["name"] as! String
                                let id = item["id"] as! String
                                let lat = itemlocation["lat"] as! Float
                                let lon = itemlocation["lng"] as! Float
                                let address = itemlocation["formattedAddress"] as! [String]
                                
                                var loc = locationss()
                                loc.name = name
                                loc.id = id
                                loc.lat = lat
                                loc.lon = lon
                                for item in address {
                                    loc.adress = loc.adress + item
                                }
                                if item.index(forKey: "photo") != nil {
                                    //////print("foto var")
                                } else {
                                    
                                    //////print("foto yok")
                                }
                                
                                let locationDictitem = [name:loc]
                                locationDict.append(locationDictitem)
                                
                            }
                        }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "configurePlace"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPlaces"), object: nil)
                }
                
                
            })
        }
        
        searchTask.start()
    }

    
    

    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Note that the app delegate controls the device orientation notifications required to use the device orientation.
        let deviceOrientation = UIDevice.current.orientation
        if UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation) {
            let previewLayer = self.previewLayer
            previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)!
        }
    }
    @IBAction func focusTap(_ gestureRecognizer: UIGestureRecognizer) {
        let devicePoint = (self.previewLayer! as AVCaptureVideoPreviewLayer).captureDevicePointOfInterest(for: gestureRecognizer.location(in: gestureRecognizer.view))
        self.focusWithMode(AVCaptureFocusMode.autoFocus, exposeWithMode: AVCaptureExposureMode.autoExpose, atDevicePoint: devicePoint, monitorSubjectAreaChange: true)
        
    }
    
    
    
    
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var cameraChange: UIBarButtonItem!
    @IBAction func cameraChange(_ sender: AnyObject) {
        
        self.cameraChange.isEnabled = false
        self.recordButton.isEnabled = false
        
        for item in captureSession!.inputs {
            
            let input = item as! AVCaptureDeviceInput
            let device = input.device as AVCaptureDevice
            
            if device.hasMediaType(AVMediaTypeVideo){
                captureSession?.removeInput(input)
            }
            
            
        }
        

        

        
        self.sessionQueue!.async {
            
            
            let currentVideoDevice:AVCaptureDevice = self.videoDeviceInput!.device
            let currentPosition: AVCaptureDevicePosition = currentVideoDevice.position
            var preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.unspecified
            
            switch currentPosition {
            case AVCaptureDevicePosition.front:
                preferredPosition = AVCaptureDevicePosition.back
            case AVCaptureDevicePosition.back:
                preferredPosition = AVCaptureDevicePosition.front
            case AVCaptureDevicePosition.unspecified:
                preferredPosition = AVCaptureDevicePosition.back
                
            }

            
            let videoDevice = CameraViewController.deviceWithMediaType(AVMediaTypeVideo,  preferringPosition: preferredPosition)
            let videoDeviceInput: AVCaptureDeviceInput!
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            } catch _ {
                videoDeviceInput = nil
            }
            
            self.captureSession!.beginConfiguration()
            
            // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
            self.captureSession!.removeInput(self.videoDeviceInput)
            
            if self.captureSession!.canAddInput(videoDeviceInput) {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                
                CameraViewController.setFlashMode(AVCaptureFlashMode.on, forDevice: videoDevice!)
                
                
                NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.subjectAreaDidChange(_:)),  name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: videoDevice)
                
                self.captureSession!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                self.captureSession!.addInput(self.videoDeviceInput)
            }
            
            let connection = self.videoOutput!.connection(withMediaType: AVMediaTypeVideo)
            connection?.videoOrientation = self.previewLayer!.connection.videoOrientation
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            self.captureSession!.commitConfiguration()
            
            DispatchQueue.main.async {
                if !self.firstFront{
                self.cameraChange.isEnabled = true
                }
                self.recordButton.isEnabled = true
                
            }
        }
        
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        // Enable the Record button to let the user stop the recording.
        DispatchQueue.main.async {
            self.recordButton.isEnabled = true
            //self.recordButton.setTitle(NSLocalizedString("Stop", comment: "Recording button stop title"), forState: .Normal)

        }
    }
    
    func subjectAreaDidChange(_ notification: Notification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        self.focusWithMode(AVCaptureFocusMode.continuousAutoFocus, exposeWithMode: AVCaptureExposureMode.continuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: false)
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        let currentBackgroundRecordingID = self.backgroundRecordingID
        self.backgroundRecordingID = UIBackgroundTaskInvalid
        fakebackgrounID = currentBackgroundRecordingID
        
        if self.progress > 0.2 {
            self.bottomToolbar.layer.opacity = 1
        }
        
     //  var success: Bool = true
    
        if error != nil {
            //NSLog("Movie file finishing error: %@", error!) "The recording reached the maximum allowable length."
            if error.localizedDescription == "There is not enough available space to continue the file writing. Make room by deleting existing videos or photos." {
          //  success = error!.userInfo[AVErrorRecordingSuccessfullyFinishedKey] as! Bool? ?? false
            self.holdRelease()
            self.displayRecordAlert("Hata", message: "Telefonunuzda yeterli yer yok.")
            }
        }
        self.cropVideoSquare(outputFileURL)
    
    }
    
    

    @IBOutlet var videoDone: UIBarButtonItem!
    @IBAction func videoDone(_ sender: AnyObject) {
        self.holdRelease()
        if (self.videoOutput!.isRecording) {
            self.videoOutput?.stopRecording()
        }
        if ((self.progress > 0.2)) {
        
        tempAssetURL = nil
        firstAsset = nil
        secondAsset = nil
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.mergeVideoClips()
        } else {
            displayAlert("Dikkat!", message: "Videonuz en az 3 saniye olmalıdır.")
        }
        
        
    }

    func focusWithMode(_ focusMode: AVCaptureFocusMode, exposeWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point:CGPoint, monitorSubjectAreaChange: Bool) {
        self.sessionQueue!.async {
            let device = self.videoDeviceInput.device
            do {
                try device?.lockForConfiguration()
                defer {device?.unlockForConfiguration()}
                // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
                
                if (device?.isFocusPointOfInterestSupported)! && (device?.isFocusModeSupported(focusMode))! {
                    device?.focusPointOfInterest = point
                    device?.focusMode = focusMode
                }
                
                if (device?.isExposurePointOfInterestSupported)! && (device?.isExposureModeSupported(exposureMode))! {
                    device?.exposurePointOfInterest = point
                    device?.exposureMode = exposureMode
                }
                
                device?.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            } catch _ {}
        }
    }
    
    
    class func setFlashMode(_ flashMode: AVCaptureFlashMode, forDevice device: AVCaptureDevice) {
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            do {
                try device.lockForConfiguration()
                defer {device.unlockForConfiguration()}
                device.flashMode = flashMode
            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            }
        }
    }
    
    class func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: mediaType)
        var captureDevice = devices?.first as! AVCaptureDevice?
        
        for device in devices as! [AVCaptureDevice] {
            if device.position == position {
                captureDevice = device
               
                break
            }
        }
        
        return captureDevice
    }
    
    func cropVideoSquare(_ url: URL ){
        
        //All explanations are in crop video square xcodeproject in https://www.one-dreamer.com/cropping-video-square-like-vine-instagram-xcode/
        let tempasset = AVAsset(url: url)
        let clipVideoTrack = (tempasset.tracks(withMediaType: AVMediaTypeVideo)[0]) as AVAssetTrack
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1,30)
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let t1 = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: -(clipVideoTrack.naturalSize.width/self.view.frame.height))
        let t2 = t1.rotated(by: 3.141593/2)
        transformer.setTransform(t2, at: kCMTimeZero)
        instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
        videoComposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        let documentsPath = (NSTemporaryDirectory() as NSString)
        let random = arc4random()
        let exportPath = documentsPath.appendingFormat("/CroppedVideo\(random).mp4" as NSString, documentsPath)
        let exportURl = URL(fileURLWithPath: exportPath as String)
        let exporter = AVAssetExportSession(asset: tempasset, presetName:AVAssetExportPresetMediumQuality)
        exporter?.videoComposition = videoComposition
        exporter?.outputURL = exportURl
        exporter?.outputFileType = AVFileTypeMPEG4
        exporter?.exportAsynchronously(completionHandler: { () -> Void in
        DispatchQueue.main.async(execute: {
                self.handleExportCompletion(exporter!, turl: url)
            })

            
            })

        
    }
    
    func handleExportCompletion(_ session: AVAssetExportSession,turl: URL) {
        
        videoClips.append(session.outputURL!)
        do {
         
            try FileManager.default.removeItem(at: turl)

            
        } catch _ {
        }
        if !(self.videoOutput?.isRecording)! {
        self.cameraChange.isEnabled = true
        self.videoDone.isEnabled = true
        self.recordButton.isEnabled = true
        }
        if ((self.progress > 0.9999)) {
            
            tempAssetURL = nil
            firstAsset = nil
            secondAsset = nil
            activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.mergeVideoClips()
        }
        
    }
    
    
    func mergeVideoClips(){
        
        let composition = AVMutableComposition()
        
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let audioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var time:Double = 0.0
        for video in self.videoClips {
            
            let asset = AVAsset(url: video)
            let videoAssetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
            let audioAssetTrack = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
            let atTime = CMTimeMakeWithSeconds(time, 1000)
        
            do{
                try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration) , of: videoAssetTrack, at: atTime)
                
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration) , of: audioAssetTrack, at: atTime)
                
            }catch{
                //print("something bad happend I don't want to talk about it")
            }
            
            time +=  asset.duration.seconds
            
            
        }
        
        
        
        let directory = (NSTemporaryDirectory() as NSString)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        let date = dateFormatter.string(from: Date())
        let savePath = "\(directory)/mergedVideo-\(date).mp4"
        let url = URL(fileURLWithPath: savePath)
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = url
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.outputFileType = AVFileTypeMPEG4
        
        
        exporter?.exportAsynchronously(completionHandler: { () -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.finalExportCompletion(exporter!)
            })
            
        })
        
        
    }
    
    func finalExportCompletion(_ session: AVAssetExportSession) {
        videoPath = session.outputURL?.path
        DispatchQueue.main.async {
           
                for url in self.videoClips {
                    let removalURL = url as URL
                    do {
                        
                        try FileManager.default.removeItem(at: removalURL)
                        //print("siliniyor at finalexport")
                        //try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                        
                    } catch _ {
                    }
                    
                
                self.videoClips.removeAll()
            }
            
        }

                    let contentURL = URL(fileURLWithPath: videoPath!)
                    let asset = AVAsset(url: contentURL)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    let time = CMTime(seconds: 0, preferredTimescale: 1)
        
                    do {
                        let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                        thumbnail = UIImage(cgImage: imageRef)
                        self.performSegue(withIdentifier: "capturePreview", sender: self)
                    } catch {
                        ////print(error)
                        
                    }

    }

    


    @IBOutlet var backtoCont: UIBarButtonItem!
    @IBAction func backtoCont(_ sender: AnyObject) {
       
            tempAssetURL = nil
            firstAsset = nil
            secondAsset = nil
       
        DispatchQueue.main.async {
        
                for url in self.videoClips {
                    let removalURL = url as URL
                do {
                    
                    try FileManager.default.removeItem(at: removalURL)
                    //print("siliniyor at back")
                    //try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                    
                } catch _ {
                    }
                
            }
            self.videoClips.removeAll()
            
          
            
                ////print("siliniyor")

        
        let cleanuppath: ()->() = {
            do {

               try FileManager.default.removeItem(atPath: videoPath!)
                
            } catch _ {}
            
        }
        if(videoPath != ""){
            cleanuppath()
            ////print("siliniyor")
            
        }
        placesArray.removeAll()
        placeOrder.removeAllObjects()
        self.performSegue(withIdentifier: "backToCont", sender: self)
        }
        
        }
    
    

    func holdDown(){
        if self.progress<1 {
        self.videoDone.isEnabled = false
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(CameraViewController.updateProgress), userInfo: nil, repeats: true)
        self.cameraChange.isEnabled = false
        self.recordButton.isEnabled = false
       
        
        self.sessionQueue!.async {
            if self.isFlashMode {
            let device = self.videoDeviceInput.device
            do {
                try device?.lockForConfiguration()
                defer {device?.unlockForConfiguration()}
                ////print(device.description)
                ////print(device.isFlashModeSupported(AVCaptureFlashMode.On))
                
                if (device?.position == AVCaptureDevicePosition.back){
                    device?.torchMode = .on
                }else {
                    DispatchQueue.main.async {
                    let newFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.flashLayer.frame = newFrame
                    self.flashLayer.backgroundColor = UIColor.white.cgColor
                    self.flashLayer.opacity = 0.9
                    self.brightness = UIScreen.main.brightness
                    UIScreen.main.brightness = 1.0
                    self.view.layer.addSublayer(self.flashLayer)
                    }
                    
                }
                

            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            } catch _ {}
        
            }
            
            if self.progress < 1 {
            if !self.videoOutput!.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                    // callback is not received until AVCam returns to the foreground unless you request background execution time.
                    // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                    // To conclude this background execution, -endBackgroundTask is called in
                    // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                let connection = self.videoOutput!.connection(withMediaType: AVMediaTypeVideo)
                
                connection?.videoOrientation = self.previewLayer!.connection.videoOrientation
                
                // Turn OFF flash for video recording.
                
                
                
                // Start recording to a temporary file.
                let outputFileName = ProcessInfo.processInfo.globallyUniqueString as NSString
                //////print(outputFileName)

                let outputFilePath: String = (NSTemporaryDirectory() as NSString).appendingPathComponent(outputFileName.appendingPathExtension("mov")!)
                
                self.videoOutput!.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                
            } else {
                self.videoOutput!.stopRecording()
                
            }
            
            }
            
            
            
        }
        
        
        
        
        
        
        
        
        
        }
        

    }

    
    func updateProgress() {
        
        let maxDuration = CGFloat(15) // Max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        if progress > 0.999999 {
            self.holdRelease()
            self.recordButton.isEnabled = false
        }
        if progress >= 1 {
            progressTimer.invalidate()
            if self.isFlashMode {
                let device = self.videoDeviceInput.device
                do {
                    try device?.lockForConfiguration()
                    defer {device?.unlockForConfiguration()}
                    if (device?.position == AVCaptureDevicePosition.back){
                        device?.torchMode = .off
                    }else {
                        DispatchQueue.main.async {
                            self.flashLayer.removeFromSuperlayer()
                            UIScreen.main.brightness = self.brightness
                        }
                        
                    }
                    
                    
                } catch let error as NSError {
                    NSLog("Could not lock device for configuration: %@", error)
                } catch _ {}
                
            }
        
            
        }
        
    }


    func holdRelease(){
        //print("hop")
        self.progressTimer.invalidate()

        if self.isFlashMode {
        let device = self.videoDeviceInput.device
        do {
            try device?.lockForConfiguration()
            defer {device?.unlockForConfiguration()}
            if (device?.position == AVCaptureDevicePosition.back){
                device?.torchMode = .off
            }else {
                DispatchQueue.main.async {
                    self.flashLayer.removeFromSuperlayer()
                    UIScreen.main.brightness = self.brightness
                }
                
            }
            
            
        } catch let error as NSError {
            NSLog("Could not lock device for configuration: %@", error)
        } catch _ {}
            
        }
    
        if self.videoOutput!.isRecording {
        self.videoOutput?.stopRecording()
        }
        
        
    }
    
    
    class func setFlashMode(_ flashMode: AVCaptureFlashMode, device: AVCaptureDevice){
        
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
           // var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.torchMode = AVCaptureTorchMode.on
                ////print(device.torchLevel)
                device.unlockForConfiguration()
                
            } catch{
                //error = error1
                ////print(error)
            }
        }
        
    }
      
    @IBOutlet var flashButton: UIButton!

    @IBAction func flashButton(_ sender: AnyObject) {
        if isFlashMode == false {
            isFlashMode = true
            flashButton.setBackgroundImage(UIImage(named: "openFlash"), for: UIControlState())
          
        } else {
            isFlashMode = false
            flashButton.setBackgroundImage(UIImage(named: "closeFlash"), for: UIControlState())

        }
    }
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.present(alert, animated: true, completion: nil)
    }
    func displayRecordAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.backtoCont(self)
        })))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.sessionQueue!.async {
            if self.setupResult == AVCamSetupResult.success {
                self.captureSession!.stopRunning()
                for item in (self.captureSession?.inputs)! {
                self.captureSession?.removeInput((item as! AVCaptureInput))
                }
                for item in (self.captureSession?.outputs)!{
                self.captureSession?.removeOutput((item as! AVCaptureOutput))
                }
                
                self.removeObservers()
           }
            self.previewLayer?.removeFromSuperlayer()
            self.videoDeviceInput = nil
            self.captureSession = nil
            self.videoOutput = nil
            self.previewLayer = nil
            
        }

        
        

    
    }
    
    
    
    fileprivate func addObservers() {
        self.captureSession!.addObserver(self, forKeyPath: "running", options: NSKeyValueObservingOptions.new, context: SessionRunningContext)
 
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.subjectAreaDidChange(_:) as (CameraViewController) -> (Notification) -> ()), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.videoDeviceInput.device)
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.sessionRuntimeError(_:)), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: self.captureSession)
        // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
        // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
        // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
        // interruption reasons.
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.sessionWasInterrupted(_:)), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: self.captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.sessionInterruptionEnded(_:)), name: NSNotification.Name.AVCaptureSessionInterruptionEnded, object: self.captureSession)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        self.captureSession!.removeObserver(self, forKeyPath: "running", context: SessionRunningContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == SessionRunningContext {
            let isSessionRunning = change![NSKeyValueChangeKey.newKey]! as! Bool
            
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                
                self.cameraChange.isEnabled = isSessionRunning && (AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 1)
                self.recordButton.isEnabled = isSessionRunning
                
            }
       
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    

    
    func sessionRuntimeError(_ notification: Notification) {
        let error = (notification as NSNotification).userInfo![AVCaptureSessionErrorKey]! as! NSError
        NSLog("Capture session runtime error: %@", error)
        
        // Automatically try to restart the session running if media services were reset and the last start running succeeded.
        // Otherwise, enable the user to try to resume the session running.
        if error.code == AVError.Code.mediaServicesWereReset.rawValue {
            self.sessionQueue!.async {
                if self.sessionRunning {
                    self.captureSession!.startRunning()
                    self.sessionRunning = self.captureSession!.isRunning
                } else {
                    DispatchQueue.main.async {
                        self.recordButton.isHidden = false
                    }
                }
            }
        } else {
            self.recordButton.isHidden = false
        }
    }
    
    func sessionWasInterrupted(_ notification: Notification) {
        // In some scenarios we want to enable the user to resume the session running.
        // For example, if music playback is initiated via control center while using AVCam,
        // then the user can let AVCam resume the session running, which will stop music playback.
        // Note that stopping music playback in control center will not automatically resume the session running.
        // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
        var showResumeButton = false
        
        // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
        if #available(iOS 9.0, *) {
            let reason = (notification as NSNotification).userInfo![AVCaptureSessionInterruptionReasonKey]! as! Int
            NSLog("Capture session was interrupted with reason %ld", reason)
            
            if reason == AVCaptureSessionInterruptionReason.audioDeviceInUseByAnotherClient.rawValue ||
                reason == AVCaptureSessionInterruptionReason.videoDeviceInUseByAnotherClient.rawValue {
                showResumeButton = true
            } else if reason == AVCaptureSessionInterruptionReason.videoDeviceNotAvailableWithMultipleForegroundApps.rawValue {
                // Simply fade-in a label to inform the user that the camera is unavailable.
                
            }
        } else {
            NSLog("Capture session was interrupted")
            showResumeButton = (UIApplication.shared.applicationState == UIApplicationState.inactive)
        }
        
        if showResumeButton {
            // Simply fade-in a button to enable the user to try to resume the session running.

        }
    }
    func sessionInterruptionEnded(_ notification: Notification) {
        NSLog("Capture session interruption ended")
        
    }
    
    
    

}

extension CLLocation {
    
    func parameters(bool: Bool) -> Parameters {
        let myll = Parameter.ll
        let myllacc = Parameter.llAcc
        let myalt = Parameter.alt
        let myaltAcc = Parameter.altAcc
        let intent = Parameter.intent
        let radius = Parameter.radius
        valuell = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        valuellacc = "\(self.horizontalAccuracy)"
        valuealt = "\(self.altitude)"
        valuealtacc = "\(self.verticalAccuracy)"

        if bool {
            return [ myll:valuell , myllacc:valuellacc , myalt:valuealt, myaltAcc: valuealtacc,intent:"browse",radius:"\(500)"]
        } else {
            return [ myll:valuell , myllacc:valuellacc , myalt:valuealt, myaltAcc: valuealtacc]
        }
        
        }
    
    
}


