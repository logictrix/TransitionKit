//
//  CircleTransition.swift
//  TransitionKit
//
//  Created by CP3 on 16/8/3.
//  Copyright © 2016年 CP3. All rights reserved.
//

import UIKit

open class CircleTransition: NSObject, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    fileprivate var animator = CircleAnimatedTransitioning()
    open var clickedPoint = CGPoint.zero {
        didSet {
            animator.clickedPoint = clickedPoint
        }
    }
    
    public init(duration: TimeInterval = 0.3) {
        super.init()
        animator.duration = duration
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
    
    open func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
}
