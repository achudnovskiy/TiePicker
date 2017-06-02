//
//  IntroViewController.swift
//  TiePicker
//
//  Created by Andrey Chudnovskiy on 2016-10-18.
//  Copyright © 2016 Simple Matters. All rights reserved.
//

import UIKit


class IntroViewController: UIPageViewController, UIPageViewControllerDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTie: UILabel!
    
    @IBOutlet weak var lblJacket: UILabel!
    @IBOutlet weak var lblPants: UILabel!
    
    @IBOutlet weak var imgJacket: UIImageView!
    @IBOutlet weak var imgPants: UIImageView!
//
//    @IBOutlet weak var lblSwipe: UILabel!
    
    var tutorialControllersNames:[String] = []

    var tutorialControllers:[String:UIViewController] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tutorialControllersNames = ["Step0ViewController", "Step1ViewController", "Step2ViewController"]
        tutorialControllersNames.forEach { (controllerName) in
            tutorialControllers[controllerName] = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: controllerName)
        }
        self.dataSource = self
        let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Step0ViewController")

        setViewControllers([firstController], direction: .forward, animated: true) { (finished) in
            
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = tutorialControllersNames.index(of: viewController.restorationIdentifier!)!
        return index < tutorialControllersNames.endIndex - 1 ? tutorialControllers[tutorialControllersNames[index + 1]] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = tutorialControllersNames.index(of: viewController.restorationIdentifier!)!
        return index != 0 ? tutorialControllers[tutorialControllersNames[index - 1]] : nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return tutorialControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    // MARK: - Animations
    func animateSwipeRight(imageViewConstraint:NSLayoutConstraint, textViewConstraint:NSLayoutConstraint) {
//        for view in viewsToBeSwiped {
//            
//        }
    }
    
    
    func animateSubtitleAppearance() {
        UIView.animate(withDuration: 1.0) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func animateSwipeHint(hide:Bool) {
        if hide {
            //animate hide of the SWIPE signz
        }
        else {
            //animate pulse SWIPE sign
        }
    }
}
