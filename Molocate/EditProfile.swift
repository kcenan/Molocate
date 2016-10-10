//  editProfile.swift
//  Molocate

import UIKit
import SDWebImage


class editProfile: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let name : UILabel = UILabel()
    let notification : UILabel = UILabel()
    let gender : UILabel = UILabel()
    let birthday : UILabel = UILabel()
    let konum : UILabel = UILabel()
    let nameText : UITextField =  UITextField()
    let switchDemo : UISwitch = UISwitch()
    let erkek : UILabel = UILabel()
    let kadın : UILabel = UILabel()
    let photo : UIImageView = UIImageView()
    let saveButton : UIButton = UIButton()
    let password : UIButton = UIButton()
    let changePhoto : UIButton = UIButton()
    let datepicker: UIDatePicker = UIDatePicker()
    var user: MoleUser!
    let maleButton : UIButton = UIButton()
    let femaleButton : UIButton = UIButton()
    let imagePicker = UIImagePickerController()
    let erkekimage : UILabel = UILabel()
    let kadınimage :UILabel = UILabel()
    let caption :UITextView = UITextView()
    
    let lineColor = UIColor(netHex: 0xCCCCCC)
    
    var thumbnail: UIImage?
    var selected: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        user = MoleCurrentUser
        initGui()
        //print("fdgdsgdsgfdsgdfsgfds")
       // print(user.bio)
    }
    
    func initGui(){
        
        let screenWidth = MolocateDevice.size.width
        let screenHeight = MolocateDevice.size.height
        
        self.addPhotoPart(screenWidth, screenHeight: screenHeight)
        self.addNamePart(screenWidth, screenHeight: screenHeight)
        self.addNotificationsPart(screenWidth, screenHeight: screenHeight)
        self.addGenderPart(screenWidth, screenHeight: screenHeight)
        self.addTimePart(screenWidth, screenHeight: screenHeight)
        self.addSaveandPassword(screenWidth, screenHeight: screenHeight)
        self.addlines(screenWidth, screenHeight: screenHeight)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editProfile.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        

    }
    
    
    func addSaveandPassword(_ screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
        let saveButton   = UIButton(type: UIButtonType.system) as UIButton
        saveButton.frame = CGRect(x: 30 , y: -40 + (scr * 100) / 120 , width: screenWidth - 60 , height: (scr * 12) / 120 )
        saveButton.backgroundColor = swiftColor
        saveButton.setTitle("Değişiklikleri Kaydet", for: UIControlState())
        saveButton.addTarget(self, action: #selector(editProfile.buttonAction(_:)), for: UIControlEvents.touchUpInside)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.borderWidth = 0
        saveButton.setTitleColor(UIColor.white, for: UIControlState())
        saveButton.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold.ttf", size: 18)
        self.view.addSubview(saveButton)
        
    
        let password   = UIButton(type: UIButtonType.system) as UIButton
        password.frame = CGRect(x: 30 , y: 0 + (scr * 82) / 120 , width: screenWidth - 60 , height: (scr * 6) / 120 )
        password.setTitleColor(UIColor.white, for: UIControlState())
        password.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold.tff", size: 16)
        password.backgroundColor = swiftColor
        password.setTitle("Şifre Değiştir", for: UIControlState())
        password.addTarget(self, action: #selector(editProfile.changePassword(_:)), for: UIControlEvents.touchUpInside)
        password.layer.cornerRadius = 10
        password.layer.borderWidth = 0
        self.view.addSubview(password)
    }
    func addNotificationsPart(_ screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
   
        notification.frame = CGRect(x: 0, y: 0 + (scr * (42 / 120)), width: screenWidth / 3, height: (scr * 6) / 120)
        notification.text = "Durum:"
        notification.textAlignment = .right
        notification.font = UIFont (name: "AvenirNext-Regular", size: 16)
        self.view.addSubview(notification)

    }
    
    func addPhotoPart(_ screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
       
        if(user.profilePic?.absoluteString != ""){
            photo.image = UIImage(named: "profile")!
            photo.sd_setImage(with: user.profilePic)
            
        }else{
            photo.image = UIImage(named: "profile")!
        }
        
        photo.frame = CGRect(x: (screenWidth / 2) - ((scr * 19) / 240) , y: 0 + (scr * 2) / 120 , width: (scr * 19) / 120 , height: (scr * 19) / 120)
        photo.layer.borderWidth = 0.1
        photo.layer.masksToBounds = false
        photo.backgroundColor = profileBackgroundColor
        photo.layer.cornerRadius = photo.frame.height / 2
        photo.clipsToBounds = true
        self.view.addSubview(photo)
        
        
        let changePhoto   = UIButton(type: UIButtonType.system) as UIButton
        changePhoto.frame = CGRect(x: (screenWidth / 2) - 40, y: 0 + (scr * 22) / 120 , width: 80 , height: (scr * 5) / 120)
        changePhoto.backgroundColor = swiftColor
        changePhoto.layer.cornerRadius = 10
        changePhoto.layer.borderWidth = 0
        
        changePhoto.setTitleColor(UIColor.white, for: UIControlState())
        changePhoto.titleLabel!.font =  UIFont(name: "AvenirNext-Regular", size: 12)
        changePhoto.setTitle("Düzenle", for: UIControlState())
        changePhoto.addTarget(self, action: #selector(editProfile.changePhoto(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(changePhoto)
        imagePicker.delegate = self
    }
    func addTimePart(_ screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
                birthday.font = UIFont (name: "AvenirNext-Regular", size: 16)
        birthday.frame = CGRect(x: 0, y: 0 + (scr * (63 / 120)), width: screenWidth / 3, height: (scr * 16) / 120)
        birthday.text = "Doğum Tarihi:"
        birthday.textAlignment = .right
        self.view.addSubview(birthday)
        
        
        datepicker.frame = CGRect(x: screenWidth / 3 + 5  , y: 0 + (scr * (61 / 120)), width: screenWidth - (screenWidth / 3 - 10)     , height: (scr * 20) / 120 )
        datepicker.locale = Locale(identifier: "tr_TR")
        datepicker.datePickerMode = UIDatePickerMode.date
        datepicker.tintColor = UIColor.white
        datepicker.setValue(UIColor.black, forKeyPath: "textColor")
        datepicker.transform = CGAffineTransform(scaleX: 0.8 , y: 0.9 )
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var birthdaytext = user.birthday
        if(birthdaytext != ""){
            let index = birthdaytext.characters.index(birthdaytext.startIndex, offsetBy: 2)
            if(birthdaytext[index] == "/" ){
                let fullNameArr = birthdaytext.components(separatedBy: "/")
                birthdaytext =  fullNameArr[2] + "-" + fullNameArr[0] + "-"+fullNameArr[1]// First
            }
        }
        datepicker.setDate( dateFormatter.date(from: birthdaytext)!, animated: true)
        self.view.addSubview(datepicker)
        

        
    }
    
    func addNamePart(_ screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
     
        name.frame = CGRect(x: 0, y: 0 + (scr * (31 / 120)), width: screenWidth / 3, height: (scr * 6) / 120)
        name.text = "İsim Soyisim:"
        name.textAlignment = .right
        name.font = UIFont (name: "AvenirNext-Regular", size: 16)
        name.layer.borderWidth = 0.3
        name.layer.borderColor = lineColor.cgColor
        self.view.addSubview(name)
        
    
        
        
        nameText.frame = CGRect(x: screenWidth / 3 + 10 , y: 0 + (scr * (31 / 120)), width: (screenWidth - (screenWidth / 3) - 30)  - 5, height: (scr * 6) / 120)
        nameText.borderStyle = .roundedRect
        nameText.textColor = UIColor.black
        nameText.keyboardType = .default
        //user.printUser()
        nameText.font = UIFont(name: "AvenirNext-Regular", size: 14)
        nameText.text = user.first_name
        self.view.addSubview(nameText)
        
        caption.frame = CGRect(x: screenWidth / 3 + 10 , y: 0 + (scr * (41 / 120)), width: (screenWidth - (screenWidth / 3) - 30)  - 5, height: (scr * 8) / 120)
        
        caption.layer.borderColor = lineColor.cgColor
        caption.layer.borderWidth = 0.5
        caption.layer.cornerRadius = 10
        //ca = .RoundedRect
        caption.textColor = UIColor.black
        caption.keyboardType = .default
        caption.font = UIFont(name: "AvenirNext-Regular", size: 14)
        caption.text = user.bio
        self.view.addSubview(caption)
        
      
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = false
    }
    func addGenderPart(_ screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
        
    
        gender.frame = CGRect(x: 0, y: 0 + (scr * (53 / 120)), width: screenWidth / 3, height: (scr * 6) / 120)
        gender.text = "Cinsiyet:"
        gender.textAlignment = .right
        gender.font = UIFont (name: "AvenirNext-Regular", size: 16)
        self.view.addSubview(gender)
        
     
        kadın.frame = CGRect(x: screenWidth / 3 + 10, y: 0 + (scr * (53 / 120)), width: 50, height: (scr * 6) / 120)
        kadın.text = "Kadın"
        kadın.font = UIFont (name: "AvenirNext-Regular", size: 16)
        kadın.textAlignment = .right
        self.view.addSubview(kadın)
        

        erkekimage.frame = CGRect(x: screenWidth / 3 + 150 , y: 0 + (scr * (56 / 120)) - 10 , width: 25 , height: 20)
        erkekimage.text = "◽️"
        self.view.addSubview(erkekimage)
    
        kadınimage.frame = CGRect(x: screenWidth / 3 + 65 , y: 0 + (scr * (56 / 120)) - 10 , width: 25 , height: 20)
        kadınimage.text = "◽️"
        self.view.addSubview(kadınimage)
        
        
    
        erkek.frame = CGRect(x: screenWidth / 3 + 100 , y: 0 + (scr * (53 / 120)) , width: 50, height: (scr * 6) / 120)
        erkek.text = "Erkek"
        erkek.font = UIFont (name: "AvenirNext-Regular", size: 16)
        erkek.textAlignment = .left
        self.view.addSubview(erkek)
        
        
        if(user.gender == "male"){
            erkekimage.text = "🔳"
        }
        if(user.gender == "female"){
            kadınimage.text = "🔳"
        }
        
        let femaleButton   = UIButton(type: UIButtonType.roundedRect)
        femaleButton.frame = CGRect(x: screenWidth / 3 + 51 , y: 0 + (scr * (56 / 120)) - 6 , width: 38 , height: 38)
        femaleButton.addTarget(self, action: #selector(editProfile.femaleSelected(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(femaleButton)
        
        
        let maleButton   = UIButton(type: UIButtonType.system) as UIButton
        maleButton.frame = CGRect(x: screenWidth / 3 + 141 , y: 0 + (scr * (56 / 120)) - 6 , width: 38 , height: 38)
        maleButton.addTarget(self, action: #selector(editProfile.maleSelected(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(maleButton)
    }
    
    
    func addlines(_ screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight - 0
        
        let line1 = UIView(frame: CGRect(x: 0 , y: 0 + (scr * (29 / 120)) , width: screenWidth , height: 1.0))
        line1.layer.borderWidth = 1.0
        line1.layer.borderColor = lineColor.cgColor
        self.view.addSubview(line1)
        
        
        let line3 = UIView(frame: CGRect(x: 0 , y: 0 + (scr * (39 / 120)) , width: screenWidth , height: 1.0))
        line3.layer.borderWidth = 1.0
        line3.layer.borderColor = lineColor.cgColor
        self.view.addSubview(line3)
        
        
        
        let line5 = UIView(frame: CGRect(x: 0 , y: 0 + (scr * (51 / 120)) , width: screenWidth , height: 0.5))
        line5.layer.borderWidth = 0.5
        line5.layer.borderColor = lineColor.cgColor
        self.view.addSubview(line5)
        
        
        let line7 = UIView(frame: CGRect(x: 0 , y: 0 + (scr * (61 / 120)) , width: screenWidth , height: 0.5))
        line7.layer.borderWidth = 0.5
        line7.layer.borderColor = lineColor.cgColor
        self.view.addSubview(line7)
        
        
        let line11 = UIView(frame: CGRect(x: 0 , y: 0 + (scr * (81 / 120)) , width: screenWidth , height: 0.5))
        line11.layer.borderWidth = 0.5
        line11.layer.borderColor = lineColor.cgColor
        self.view.addSubview(line11)
        
        let line12 = UIView(frame: CGRect(x: 0 , y: 0 + (scr * (89 / 120)) , width: screenWidth , height: 0.5))
        line12.layer.borderWidth = 0.5
        line12.layer.borderColor = lineColor.cgColor
        self.view.addSubview(line12)
        
    }

    
    func femaleSelected(_ sender:UIButton!){
       // print("female selected")
        kadınimage.text = "🔳"
        erkekimage.text = "◽️"
        user.gender = "female"
        
    }
    func maleSelected(_ sender:UIButton!){
      //  print("male selected")
        kadınimage.text = "◽️"
        erkekimage.text = "🔳"
        user.gender = "male"
    }
    
    func buttonAction(_ sender:UIButton!)
    {
        
        sender.isHidden = true
        
        user.first_name = nameText.text!
        user.bio = caption.text!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        user.birthday = dateFormatter.string(from: datepicker.date)
        MoleCurrentUser = user
        
     //   let imageData = UIImageJPEGRepresentation(photo.image!, 0.5)
        activityIndicator.frame = sender.frame
        activityIndicator.center = sender.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        
        if selected != nil && thumbnail != nil {
            
            let imageData = UIImageJPEGRepresentation(selected!, 1.0)
            let thumbNailData = UIImageJPEGRepresentation(thumbnail!, 1.0)
            
          
            MolocateAccount.sendProfilePhotoandThumbnail(imageData!, thumbnail: thumbNailData!, completionHandler: { (data, pictureUrl, thumbnailUrl, response, error) in
                DispatchQueue.main.async { () -> Void in
                    
                    if data == "success"{
                        SDImageCache.shared().removeImage(forKey: MoleCurrentUser.profilePic?.absoluteString)
                        SDImageCache.shared().removeImage(forKey: MoleCurrentUser.thumbnailPic?.absoluteString)
                        SDImageCache.shared().store(self.selected!, forKey: pictureUrl)
                        SDImageCache.shared().store(self.thumbnail!, forKey: thumbnailUrl)
                        MoleCurrentUser.profilePic = URL(string: pictureUrl)!
                        MoleCurrentUser.thumbnailPic = URL(string: thumbnailUrl)!

                        choosedIndex = 0
                        self.navigationController?.popViewController(animated: true)
                        self.selected = nil
                        self.thumbnail = nil
                    }else{
                        self.displayAlert("Tamam", message: "Kullanıcı bilgileri değiştirilirken bir hata oluştu")
                        sender.isHidden = false
                    }
        
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                }
               
            })
        }else{
            MolocateAccount.EditUser({ (data, response, error) in
                DispatchQueue.main.async { () -> Void in
                    if data == "success"{
                        choosedIndex = 0
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.displayAlert("Tamam", message: "Kullanıcı bilgileri değiştirilirken bir hata oluştu")
                        sender.isHidden = false
                    }
                }
            })
        }
      
//
//        MolocateAccount.uploadProfilePhoto(imageData!) { (data, response, error) -> () in
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                if data[0] == "h"{
//                    SDImageCache.sharedImageCache().removeImageForKey(data!)
//                    SDImageCache.sharedImageCache().storeImage(self.photo.image!, forKey: data!)
//                    MoleCurrentUser.profilePic = NSURL(string: data!)!
//                    MolocateAccount.EditUser { (data, response, error) -> () in
//                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                            self.activityIndicator.stopAnimating()
//                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                            if data == "success"{
//                                choosedIndex = 0
//                                self.performSegueWithIdentifier("goBackProfile", sender: self)
//                            }else{
//                                self.displayAlert("Tamam", message: "Kullanıcı bilgileri değiştirilirken bir hata oluştu")
//                                sender.hidden = false
//                            }
//                           
//                        }
//                    }
//                }else{
//                    self.activityIndicator.stopAnimating()
//                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                    self.displayAlert("Tamam", message: "Profil fotosu yüklenirken bir hata oluştu")
//                    sender.hidden = false
//                }
//                
//               
//            }
//                
//        }
//        
    }
    

    
    func changePassword(_ sender:UIButton!)
    {
        //DBG: Push View Controller
//        let controller:changePasswordd = self.storyboard!.instantiateViewControllerWithIdentifier("changePasswordd") as! changePasswordd
//        controller.view.frame = self.view.bounds
//        controller.willMoveToParentViewController(self)
//        self.view.addSubview(controller.view)
//        self.addChildViewController(controller)
//        controller.didMoveToParentViewController(self)
        //print("şifre değiştirecek")
        
        let controller:changePasswordd = self.storyboard!.instantiateViewController(withIdentifier: "changePasswordd") as! changePasswordd
        navigationController?.pushViewController(controller, animated: true)
        
    }
    func changePhoto(_ sender:UIButton!)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            //print("Button capture")
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        let selectedImage : UIImage = image
        photo.image = MolocateUtility.RBSquareImageTo(selectedImage, size: CGSize(width: 480, height: 480))
        selected = photo.image
        thumbnail = MolocateUtility.RBSquareImageTo(selectedImage, size: CGSize(width: 92, height: 92))
    
        //print("new image")
        self.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
        //print("picker cancel.")
    }
    
//    
//    //buradan  cinsiyeti yolla
//    func switchValueDidChange(sender:UISwitch!)
//    {
//        if (sender.on == true){
//            print("on")
//            
//        }
//        else{
//            print("off")
//        }
//    }
//    
    
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
