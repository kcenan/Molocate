//
//  tutorialViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 26.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//


import UIKit

class tutorialViewController: UIPageViewController, UIPageViewControllerDataSource
{
    
    var arrPagePhoto: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if MolocateDevice.size.height > 710{
        arrPagePhoto = ["plushosgeldin.jpg", "plushaber.jpg", "pluskesfet.jpg","pluspaylas.jpg"]
        }
        else if is4s{
            arrPagePhoto = ["4hosgeldin.jpg", "4haber.jpg", "4kesfet.jpg","4paylas.jpg"]
        }
        if MolocateDevice.size.height < 710 && MolocateDevice.size.height > 650   {
            arrPagePhoto = ["6hosgeldin.jpg", "6haber.jpg", "6kesfet.jpg","6paylas.jpg"]
        }
        else{
            arrPagePhoto = ["5hosgeldin.jpg", "5haber.jpg", "5kesfet.jpg","5paylas.jpg"]
           
        }
        self.dataSource = self
        
        self.setViewControllers([getViewControllerAtIndex(0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward,  animated: true, completion: nil)
        view.backgroundColor = swiftColor
    }
    
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let pageContent: tutorialPageContentViewController = viewController as! tutorialPageContentViewController
        
        var index = pageContent.pageIndex
       
        if index < 3 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "fontSmaller"), object: nil)
            
        }
        if ((index == 0) || (index == NSNotFound))
        {
            return nil
        }
        
        index -= 1;
       
        
        return getViewControllerAtIndex(index)
    }
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let pageContent: tutorialPageContentViewController = viewController as! tutorialPageContentViewController
        
        var index = pageContent.pageIndex
        
        if index > 2 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "fontBigger"), object: nil)
            
        }
       
       
        if (index == NSNotFound)
        {
            return nil;
        }
      
        if index > 2 {
        index = 2
            
            return nil
        }
        else {
            index += 1
  
          
            return getViewControllerAtIndex(index) }
        

        
    }
    
    
    
    
    
    
    
    // MARK:- Other Methods
    func getViewControllerAtIndex(_ index: NSInteger) -> tutorialPageContentViewController
    {
        // Create a new view controller and pass suitable data.
        let tutorialpageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "tutorialPageContentViewController") as! tutorialPageContentViewController
        
        
        tutorialpageContentViewController.strPhotoName = "\(arrPagePhoto[index])"
        tutorialpageContentViewController.pageIndex = index
        
        
        
        return tutorialpageContentViewController
    }
}
