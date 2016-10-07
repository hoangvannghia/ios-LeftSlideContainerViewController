//
//  ContainerViewController.swift
//  vnToeic
//
//  Created by hoang van nghia on 10/6/16.
//  Copyright © 2016 hoang van nghia. All rights reserved.
//

import UIKit

class LeftSideContainerViewController: UIViewController, UIScrollViewDelegate {
   @IBOutlet weak var rightView: UIView!             //Left Container view
   @IBOutlet weak var leftView: UIView!              //Right Container view
   @IBOutlet weak var scrollView: UIScrollView!      //SuperView of left and right container view
   
   //For animation
   private var leftSnapshot : UIView?
   private var rightSnapshot : UIView?
   //Fraction is used to determine progress of animation
   private var fraction = 0.0 {
      didSet {
         leftView.isHidden = fraction < 1 && fraction != 0
         leftSnapshot?.isHidden = fraction == 1
         rightSnapshot?.isHidden = fraction == 1
         
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      rightView.layer.shadowColor = UIColor.black.cgColor
      rightView.layer.shadowOpacity = 0.5
      rightView.layer.shadowOffset = CGSize(width: -5, height: -5)
      
      //Change perspective of scrollView's layer for 3D effect. 
      //It affect all subview, including left and right snapshot, which will be added later
      scrollView.delegate = self
      var perspective = CATransform3DIdentity
      perspective.m34 = -1 / 1000.0
      scrollView.layer.sublayerTransform = perspective
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      scrollView.setContentOffset(CGPoint(x: leftView.bounds.width, y: 0), animated: false)
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      //prepare for fisrt time animation.
      //At this, UIView's snapshotView doesn't work due to absence of leftView on screen
      settupAnimation()
      scrollView.setContentOffset(CGPoint(x: leftView.bounds.width, y: 0), animated: false)
   }
   
   //This func using when UIView's snapshotView func doesn't work
   private func settupAnimation() {
      leftSnapshot?.removeFromSuperview()
      rightSnapshot?.removeFromSuperview()
      UIGraphicsBeginImageContextWithOptions(leftView.bounds.size, true, UIScreen.main.scale)
      let context = UIGraphicsGetCurrentContext()
      leftView.layer.render(in: context!)
      
      let image = UIGraphicsGetImageFromCurrentImageContext()
      leftSnapshot = UIImageView(image: image)
      rightSnapshot = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
      UIGraphicsEndImageContext()
      
      
      //This layer is used to dark effect on left snapshot
      let layer = CAShapeLayer()
      layer.path = UIBezierPath(rect: CGRect(x: leftView.bounds.width / 2, y: 0, width: leftView.bounds.width / 2, height: leftView.bounds.height)).cgPath
      layer.fillColor = UIColor.black.cgColor
      rightSnapshot?.layer.addSublayer(layer)
      layer.opacity = 0.0
      
      leftSnapshot?.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
      rightSnapshot?.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
      leftSnapshot?.sizeToFit()
      rightSnapshot?.sizeToFit()
      leftSnapshot?.frame.origin = CGPoint(x: 0, y: 0)
      rightSnapshot?.frame.origin = CGPoint(x: 0, y: 0)
      
      //rasterize for best display on screen
      rightSnapshot?.layer.shouldRasterize = true
      leftSnapshot?.layer.shouldRasterize = true
      rightSnapshot?.layer.rasterizationScale = UIScreen.main.scale
      leftSnapshot?.layer.rasterizationScale = UIScreen.main.scale
   }
   
   
   //MARK: ScrollViewDelegate for animation 
   func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      if fraction == 1 {
         leftSnapshot?.removeFromSuperview()
         rightSnapshot?.removeFromSuperview()
         leftSnapshot = leftView.snapshotView(afterScreenUpdates: false)
         rightSnapshot = leftView.snapshotView(afterScreenUpdates: false)
         
         //This layer is used to dark effect on left snapshot
         let layer = CAShapeLayer()
         layer.path = UIBezierPath(rect: CGRect(x: leftView.bounds.width / 2, y: 0, width: leftView.bounds.width / 2, height: leftView.bounds.height)).cgPath
         layer.fillColor = UIColor.black.cgColor
         rightSnapshot?.layer.addSublayer(layer)
         layer.opacity = 0.0
         
         leftSnapshot?.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
         rightSnapshot?.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
         leftSnapshot?.frame.origin = CGPoint(x: 0, y: 0)
         rightSnapshot?.frame.origin = CGPoint(x: 0, y: 0)
         
         //rasterize for best display on screen
         rightSnapshot?.layer.shouldRasterize = true
         leftSnapshot?.layer.shouldRasterize = true
         rightSnapshot?.layer.rasterizationScale = UIScreen.main.scale
         leftSnapshot?.layer.rasterizationScale = UIScreen.main.scale
      } else if fraction == 0 {
         settupAnimation()
      }
      
      scrollView.insertSubview(leftSnapshot!, at: 1)
      scrollView.insertSubview(rightSnapshot!, at: 1)
   }
   
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
      fraction = 1.0 - Double(max(min(scrollView.contentOffset.x / leftView.bounds.width, 1), 0))
      
      let angle = acos(fraction)
      
      let translationLeft = CATransform3DTranslate(CATransform3DIdentity, scrollView.contentOffset.x, 0, 0)
      leftSnapshot?.layer.transform = CATransform3DConcat(CATransform3DRotate(CATransform3DIdentity, CGFloat(angle), 0, 1, 0), translationLeft)
      rightSnapshot?.layer.transform = CATransform3DRotate(CATransform3DIdentity, -(CGFloat)(angle), 0, 1, 0)
      
      //change sublayer to display dark effect
      if let subsRight = rightSnapshot?.layer.sublayers {
         subsRight[subsRight.count - 1].opacity = Float(0.5 * (1 - fraction))
      }
   }
}





