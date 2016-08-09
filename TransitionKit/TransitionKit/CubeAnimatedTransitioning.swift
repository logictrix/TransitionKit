//
//  CubeAnimatedTransitioning.swift
//  TransitionKit
//
//  Created by CP3 on 16/8/6.
//  Copyright © 2016年 CP3. All rights reserved.
//

import UIKit

public class CubeAnimatedTransitioning: BaseAnimatedTransitioning {
    
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private var viewWidth: CGFloat = UIScreen.mainScreen().bounds.width
    
    override public func animateTransition(transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController, containerView: UIView) {
        self.transitionContext = transitionContext
        
        let fromView = fromVC.view
        let toView = toVC.view
        viewWidth = fromVC.view.bounds.width
        
        containerView.layer.sublayerTransform = perspectiveTransform
        
        let wrapperView: UIView = CubeTransitionView(frame: fromView.frame)
        wrapperView.autoresizesSubviews = true
        wrapperView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        containerView.addSubview(wrapperView)
        fromView.frame.origin = CGPoint.zero
        toView.frame.origin = CGPoint.zero
        wrapperView.addSubview(fromView)
        wrapperView.addSubview(toView)
        
        CATransaction.setCompletionBlock { [weak self] in
            self?.shouldLayersRasterize([fromView.layer, toView.layer], shouldRasterize: false)
            
            fromView.layer.transform = CATransform3DIdentity
            toView.layer.transform = CATransform3DIdentity
            wrapperView.layer.transform = CATransform3DIdentity
            
            fromView.frame = wrapperView.frame
            toView.frame = containerView.frame
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
            wrapperView.removeFromSuperview()
        }
        
        fromView.layer.doubleSided = false
        toView.layer.doubleSided = false
        shouldLayersRasterize([fromView.layer, toView.layer], shouldRasterize: true)
        
        toView.layer.transform = CATransform3DIdentity
        fromView.layer.transform = fromTransform()
        
        wrapperView.layer.transform = CATransform3DInvert(CATransform3DIdentity)
        wrapperView.layer.addAnimation(animation(), forKey: nil)
    }
    
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let containerView = transitionContext?.containerView()
        containerView?.layer.sublayerTransform = CATransform3DIdentity
        
        let cancelled = transitionContext?.transitionWasCancelled() ?? false
        transitionContext?.completeTransition(!cancelled)
    }
}

// MARK: - Help
private extension CubeAnimatedTransitioning {
    func fromTransform() -> CATransform3D {
        let factor: CGFloat = dismiss ? -1 : 1
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, -M_PI_2.f * factor, 0.0, 1.0, 0.0)
        transform = CATransform3DTranslate(transform, -viewWidth/2 * factor, 0.0, viewWidth/2)
        
        return transform
    }
    
    func animation() -> CAAnimationGroup {
        let factor: CGFloat = dismiss ? -1 : 1
        var rotation = CATransform3DIdentity
        rotation = CATransform3DTranslate(rotation, viewWidth/2 * factor, 0.0, -viewWidth/2)
        rotation = CATransform3DRotate(rotation, M_PI_2.f * factor, 0.0, 1.0, 0.0)
        
        let cubeRotation: CABasicAnimation = CABasicAnimation(keyPath: "transform")
        cubeRotation.fromValue = NSValue(CATransform3D: rotation)
        cubeRotation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        cubeRotation.duration = duration
        
        let zPositionAnimation = CAKeyframeAnimation(keyPath: "zPosition")
        zPositionAnimation.values = [0.0, -36.0, 0.0]
        zPositionAnimation.timingFunctions = getCircleApproximationTimingFunctions()
        zPositionAnimation.duration = duration
        
        let animation = CAAnimationGroup()
        animation.animations = [cubeRotation, zPositionAnimation]
        animation.duration = duration
        animation.delegate = self
        
        return animation
    }
    
    func getCircleApproximationTimingFunctions() -> [CAMediaTimingFunction] {
        // The following CAMediaTimingFunction mimics zPosition = sin(t)
        // Empiric (possibly incorrect, but it does the job) implementation based on the circle approximation with bezier cubic curves
        // ( http://www.whizkidtech.redprince.net/bezier/circle/ )
        // sin(t) tangent for t=0 is a diagonal. But we have to remap x=[0PI/2] to t=[01]. => scale with M_PI/2.0f factor
        
        let kappa: Float = 4.0/3.0 * (sqrt(2.0) - 1.0) / sqrt(2.0)
        let firstQuarterCircleApproximationFuction = CAMediaTimingFunction(controlPoints: kappa/Float(M_PI_2), kappa, 1.0 - kappa, 1.0)
        let secondQuarterCircleApproximationFuction = CAMediaTimingFunction(controlPoints: kappa, 0.0, 1.0 - kappa/Float(M_PI_2), 1.0 - kappa)
        return [firstQuarterCircleApproximationFuction, secondQuarterCircleApproximationFuction]
    }
}

class CubeTransitionView : UIView {
    override class func layerClass() -> AnyClass {
        return CATransformLayer.self
    }
}


