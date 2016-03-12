//
//  denemeViewController.swift
//  Molocate
//
//  Created by MellonCorp on 3/11/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class denemeViewController: UIViewController {

    @IBOutlet var myLabel: UILabel!
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    let font = UIFont(name: "Helvetica", size: 20.0)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // FLT_MAX here simply means no constraint in height
       

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
