//
//  editProfile.swift
//  Molocate
//
//  Created by MellonCorp on 3/10/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//
//kare foto seçme ekle

import UIKit

extension UIImageView {
    func downloadedFrom(url url:NSURL, contentMode mode: UIViewContentMode) {
        contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
            }
        }).resume()
    }
}

class editProfile: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
    
    
    @IBOutlet var toolBar: UIToolbar!
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
   
    var name : UILabel!
    var mail : UILabel!
    var gender : UILabel!
    var birthday : UILabel!
    var konum : UILabel!
    var mailText : UITextField!
    var nameText : UITextField!
    var surnameText : UITextField!
    var switchDemo : UISwitch!
    var erkek : UILabel!
    var kadın : UILabel!
    var photo : UIImageView!
    var saveButton : UIButton!
    var password : UIButton!
    var changePhoto : UIButton!
    
    
    let imagePicker = UIImagePickerController()
    
    
    @IBAction func back(sender: AnyObject) {
         self.performSegueWithIdentifier("goBackProfile", sender: self)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        //self.toolBar.frame = CGRectMake(0, 16, screenWidth, 44)
        
        imagePicker.delegate = self
        
        let scr = screenHeight - 60
        
        let datepicker = UIDatePicker(frame:CGRectMake(screenWidth / 3 + 5  , 60 + (scr * (60 / 120)), screenWidth - (screenWidth / 3 - 10)     , (scr * 20) / 120 ))
        
        datepicker.locale = NSLocale(localeIdentifier: "tr_TR")
        datepicker.datePickerMode = UIDatePickerMode.Date
        datepicker.tintColor = UIColor.whiteColor()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        datepicker.setValue(UIColor.blackColor(), forKeyPath: "textColor")
        
        //date pickerdan string al, max min value ata
        let selectedDate = dateFormatter.stringFromDate(datepicker.date)
        print(selectedDate)
        datepicker.transform = CGAffineTransformMakeScale(0.8 , 0.9 )
        //datepicker.transform = CGAffineTransformMakeScale(0. , 1)
        self.view.addSubview(datepicker)
        
        
        //datepicker.frame = CGRectMake(screenWidth / 3   , 60 + (scr * (62 / 120)), screenWidth / 2 , (scr * 6) / 120)
        // datepicker.transform = CGAffineTransformMakeScale(0.7, 0.7)
        
        
        addlines()
        photo = UIImageView()
        //ppyi ata
       // let image: UIImage = UIImage(named: "elmander.jpg")!
        photo = UIImageView()
        photo.downloadedFrom(url: currentUser.profilePic, contentMode: UIViewContentMode.ScaleToFill)

        photo!.frame = CGRectMake(10 , 60 + (scr * 2) / 120 , (scr * 26) / 120 , (scr * 26) / 120)
        self.view.addSubview(photo!)
        
        mailText = UITextField()
        mailText.frame = CGRectMake(screenWidth / 3 + 10 , 60 + (scr * (42 / 120)), screenWidth - (screenWidth / 3) - 20, (scr * 6) / 120)
        mailText.borderStyle = .RoundedRect
        mailText.textColor = UIColor.blackColor()
        mailText.keyboardType = .EmailAddress
        mailText.text = currentUser.email
        view.addSubview(mailText)
        
        name = UILabel()
        name.frame = CGRectMake(0, 60 + (scr * (32 / 120)), screenWidth / 3, (scr * 6) / 120)
        name.text = "İsim Soyisim:"
        name.textAlignment = .Right
        name.font = UIFont (name: "Lato-Regular", size: 16)
        view.addSubview(name)
        
        nameText = UITextField()
        nameText.frame = CGRectMake(screenWidth / 3 + 10 , 60 + (scr * (32 / 120)), (screenWidth - (screenWidth / 3) - 20) / 2 - 5, (scr * 6) / 120)
        nameText.borderStyle = .RoundedRect
        nameText.textColor = UIColor.blackColor()
        nameText.keyboardType = .Default
        nameText.text = currentUser.first_name
        view.addSubview(nameText)
        
        surnameText = UITextField()
        surnameText.frame = CGRectMake(2 * screenWidth / 3 + 10  , 60 + (scr * (32 / 120)), (screenWidth - (screenWidth / 3) - 20) / 2 - 5 , (scr * 6) / 120)
        surnameText.borderStyle = .RoundedRect
        surnameText.textColor = UIColor.blackColor()
        surnameText.keyboardType = .EmailAddress
        surnameText.text = currentUser.last_name
        view.addSubview(surnameText)
        
        mail = UILabel()
        mail.frame = CGRectMake(0, 60 + (scr * (42 / 120)), screenWidth / 3, (scr * 6) / 120)
        mail.text = "E-posta:"
        mail.textAlignment = .Right
        mail.font = UIFont (name: "Lato-Regular", size: 16)
        view.addSubview(mail)
        
        gender = UILabel()
        gender.frame = CGRectMake(0, 60 + (scr * (52 / 120)), screenWidth / 3, (scr * 6) / 120)
        gender.text = "Cinsiyet:"
        gender.textAlignment = .Right
        gender.font = UIFont (name: "Lato-Regular", size: 16)
        view.addSubview(gender)
        
        birthday = UILabel()
        birthday.font = UIFont (name: "Lato-Regular", size: 16)
        birthday.frame = CGRectMake(0, 60 + (scr * (62 / 120)), screenWidth / 3, (scr * 16) / 120)
        birthday.text = "Doğum Tarihi:"
        birthday.textAlignment = .Right
        view.addSubview(birthday)
        
        switchDemo = UISwitch()
        var a : CGFloat = (screenWidth - screenWidth / 3 ) / 2 + screenWidth / 3
        switchDemo.center.x = a
        var b : CGFloat = 60 + (scr * (55 / 120))
        switchDemo.center.y = b
        switchDemo.transform = CGAffineTransformMakeScale( screenHeight / 667 , screenHeight / 667 )
        switchDemo.on = true
        switchDemo.setOn(true, animated: false)
        switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
        self.view.addSubview(switchDemo)
        
        kadın = UILabel()
        kadın.frame = CGRectMake((screenWidth - screenWidth / 3 ) / 2 + screenWidth / 3 - 80, 60 + (scr * (52 / 120)), 50, (scr * 6) / 120)
        kadın.text = "Kadın"
        kadın.textAlignment = .Right
        view.addSubview(kadın)
        
        let saveButton   = UIButton(type: UIButtonType.System) as UIButton
        saveButton.frame = CGRectMake(30 , 60 + (scr * 100) / 120 , screenWidth - 60 , (scr * 12) / 120 )
        saveButton.backgroundColor = swiftColor
        saveButton.setTitle("Değişiklikleri Kaydet", forState: UIControlState.Normal)
        saveButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.borderWidth = 0
        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        saveButton.titleLabel!.font =  UIFont(name: "Lato-Bold.tff", size: 18)
        self.view.addSubview(saveButton)
        
        let changePhoto   = UIButton(type: UIButtonType.System) as UIButton
        changePhoto.frame = CGRectMake(10 , 60 + (scr * 2) / 120 , (scr * 26) / 120 , (scr * 26) / 120)
        changePhoto.backgroundColor = .None
        changePhoto.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        changePhoto.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        changePhoto.titleLabel!.font =  UIFont(name: "Lato-Regular.tff", size: 20)
        changePhoto.setTitle("Fotoğrafı\nDeğiştir", forState: UIControlState.Normal)
        changePhoto.addTarget(self, action: "changePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        changePhoto.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.view.addSubview(changePhoto)
        
        let password   = UIButton(type: UIButtonType.System) as UIButton
        password.frame = CGRectMake(30 , 60 + (scr * 82) / 120 , screenWidth - 60 , (scr * 6) / 120 )
        password.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        password.titleLabel!.font =  UIFont(name: "Lato-Bold.tff", size: 16)
        password.backgroundColor = swiftColor
        password.setTitle("Şifre Değiştir", forState: UIControlState.Normal)
        password.addTarget(self, action: "changePassword:", forControlEvents: UIControlEvents.TouchUpInside)
        
        password.layer.cornerRadius = 10
        password.layer.borderWidth = 0
        self.view.addSubview(password)
        
        
        erkek = UILabel()
        erkek.frame = CGRectMake((screenWidth - screenWidth / 3 ) / 2 + screenWidth / 3 + 30, 60 + (scr * (52 / 120)) , 50, (scr * 6) / 120)
        erkek.text = "Erkek"
        erkek.textAlignment = .Left
        view.addSubview(erkek)
        
        
        kadın.alpha = 0.5
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        imagePicker.delegate = self
    }
    
    
    
    func buttonAction(sender:UIButton!)
    {
        print("Button tapped")
    }
    func changePassword(sender:UIButton!)
    {
        
        let controller:changePasswordd = self.storyboard!.instantiateViewControllerWithIdentifier("changePasswordd") as! changePasswordd
        controller.view.frame = self.view.bounds
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        

        
        print("şifre değiştirecek")
        
    }
    func changePhoto(sender:UIButton!)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            print("Button capture")
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imag.allowsEditing = false
            self.presentViewController(imag, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        let selectedImage : UIImage = image
        photo.image=selectedImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
    }
    
    
    
    
    
    //buradan  cinsiyeti yolla
    func switchValueDidChange(sender:UISwitch!)
    {
        if (sender.on == true){
            print("on")
            self.erkek.alpha = 1
            self.kadın.alpha = 0.5
        }
        else{
            print("off")
            self.erkek.alpha = 0.5
            self.kadın.alpha = 1
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    func addlines(){
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let scr = screenHeight - 60
        
        let line1 = UIView(frame: CGRectMake(0 , 60 + (scr * (31 / 120)) , screenWidth , 1.0))
        line1.layer.borderWidth = 1.0
        line1.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line1)
        
        let line2 = UIView(frame: CGRectMake(0 , 60 + (scr * (39 / 120)) , screenWidth , 1.0))
        line2.layer.borderWidth = 1.0
        line2.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line2)
        
        let line3 = UIView(frame: CGRectMake(0 , 60 + (scr * (41 / 120)) , screenWidth , 1.0))
        line3.layer.borderWidth = 1.0
        line3.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line3)
        
        let line4 = UIView(frame: CGRectMake(0 , 60 + (scr * (49 / 120)) , screenWidth , 1.0))
        line4.layer.borderWidth = 1.0
        line4.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line4)
        
        let line5 = UIView(frame: CGRectMake(0 , 60 + (scr * (51 / 120)) , screenWidth , 1.0))
        line5.layer.borderWidth = 1.0
        line5.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line5)
        
        let line6 = UIView(frame: CGRectMake(0 , 60 + (scr * (59 / 120)) , screenWidth , 1.0))
        line6.layer.borderWidth = 1.0
        line6.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line6)
        
        let line7 = UIView(frame: CGRectMake(0 , 60 + (scr * (61 / 120)) , screenWidth , 1.0))
        line7.layer.borderWidth = 1.0
        line7.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line7)
        
        let line10 = UIView(frame: CGRectMake(0 , 60 + (scr * (79 / 120)) , screenWidth , 1.0))
        line10.layer.borderWidth = 1.0
        line10.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line10)
        
        let line11 = UIView(frame: CGRectMake(0 , 60 + (scr * (81 / 120)) , screenWidth , 1.0))
        line11.layer.borderWidth = 1.0
        line11.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line11)
        
        let line12 = UIView(frame: CGRectMake(0 , 60 + (scr * (89 / 120)) , screenWidth , 1.0))
        line12.layer.borderWidth = 1.0
        line12.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line12)
        
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
}
