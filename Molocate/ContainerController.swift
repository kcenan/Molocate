//
//  ContainerController.swift
//  Molocate
//
//  Created by Kagan Cenan on 14.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class ContainerController: UIViewController,UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    
    //let profileController:ProfileViewController = ProfileViewController(nibName: "ProfileViewController",bundle:nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        dispatch_async(dispatch_get_main_queue()) {
            self.scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.23, y: 0), animated: false)
            self.childViewControllers[1].viewDidLoad()

        }
        
        
        scrollView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeSideBar", name: "closeSideBar", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeSideBarFast", name: "closeSideBarFast", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "openSideBar", name: "openSideBar", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goProfile", name: "goProfile", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "closeProfile", name: "closeProfile", object: nil)
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "openProfile", name: "openProfile", object: nil)
       
        
        // Do any additional setup after loading the view.
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func closeSideBar(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.23, y: 0), animated: true)
    }
    
    func openSideBar(){
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func closeSideBarFast(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.23, y: 0), animated: false)
    }
    
    func goProfile(){
  //      self.addChildViewController(profileController)
   //     scrollView.addSubview(profileController.view)
    //    profileController.didMoveToParentViewController(self)
     //   profileController.view.frame = CGRect(x: 0.4*self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    func closeProfile(){
      //  profileController.willMoveToParentViewController(nil)
        //profileController.view.removeFromSuperview()
        //profileController.removeFromParentViewController()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.pagingEnabled = true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollView.pagingEnabled = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView.contentOffset.x == 0) {
            sideClicked = true
        } else{
            sideClicked = false
        }
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



