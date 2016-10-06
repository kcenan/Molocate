//  ContainerController.swift
//  Molocate


import UIKit

class ContainerController: UIViewController,UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
       
        if let tabbar = self.childViewControllers[1] as? UITabBarController {
           // print("tabbar reloaded \(choosedIndex)")
            tabbar.selectedIndex = choosedIndex
            tabbar.viewDidLoad()
        }
        
        //broadcasting functions. They may called from any viewcontroller.
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerController.closeSideBar), name: NSNotification.Name(rawValue: "closeSideBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerController.closeSideBarFast), name: NSNotification.Name(rawValue: "closeSideBarFast"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerController.openSideBar), name: NSNotification.Name(rawValue: "openSideBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerController.pushNotification), name: NSNotification.Name(rawValue: "pushNotification"), object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
    func pushNotification(){
        if let tabbar = self.childViewControllers[1] as? UITabBarController {
            choosedIndex = 3
            tabbar.selectedIndex = choosedIndex
            tabbar.viewDidLoad()
        }
    }
    func closeSideBar(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.4, y: 0), animated: true)
        //setStatusBarBackgroundColor(swiftColor)
    }
    
    func openSideBar(){
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            //setStatusBarBackgroundColor(UIColor.blackColor())
    }
    
    func closeSideBarFast(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.4, y: 0), animated: false)
        
        //setStatusBarBackgroundColor(swiftColor)
    }

 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        adjustViewLayout(UIScreen.main.bounds.size)
        
       // setStatusBarBackgroundColor(swiftColor)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.x == 0) {
            sideClicked = true
         
        } else{
            sideClicked = false
        }
        if(scrollView.contentOffset.x < self.view.frame.width*0.2){
            
            MolocateUtility.setStatusBarBackgroundColor(UIColor.black)
        

        
        }
        else{
            MolocateUtility.setStatusBarBackgroundColor(swiftColor)

        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustViewLayout(size)
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    func adjustViewLayout(_ size: CGSize) {
        
        
        switch(size.width, size.height) {
        case (480, 320):
            break                        // iPhone 4S in landscape
            
        case (320, 480):
            is4s = true                    // iPhone 4s pportrait
            break
        case (414, 736):                        // iPhone 6 Plus in portrait
            
            break
        case (736, 414):                        // iphone 6 Plus in landscape
            
            break
        default:
            break
        }
    }

}



