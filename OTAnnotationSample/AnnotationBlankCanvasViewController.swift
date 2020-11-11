//
//  AnnotationBlankViewController.swift
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//
import UIKit

class AnnotationBlankCanvasViewController: UIViewController {
    
    let topOffset: CGFloat = 20 + 44
    let topOffsetForLandscape: CGFloat = 44
    let heightOfToolbar = CGFloat(50)
    let widthOfToolbar = CGFloat(50)
    let annotationScrollView = OTAnnotationScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        
        annotationScrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - heightOfToolbar - topOffset)
        annotationScrollView.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - heightOfToolbar - topOffset)
        
        annotationScrollView.initializeToolbarView()
        annotationScrollView.toolbarView!.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - heightOfToolbar - topOffset, width: UIScreen.main.bounds.width, height: heightOfToolbar)
        
        view.addSubview(annotationScrollView)
        view.addSubview(annotationScrollView.toolbarView!)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let screenRect = UIScreen.main.bounds;
        var safeAreaOffset: CGFloat = 0
            
        if #available(iOS 11.0, *) {
            safeAreaOffset = self.view.safeAreaInsets.bottom
        }
        
        // portrait
        if screenRect.width < screenRect.height {
            annotationScrollView.frame = CGRect(x: 0, y: 0, width: screenRect.width, height: screenRect.height - heightOfToolbar - topOffset)
            annotationScrollView.scrollView.contentSize = CGSize(width: screenRect.width, height: screenRect.height - heightOfToolbar - topOffset)
            
            annotationScrollView.toolbarView!.frame = CGRect(x: 0, y: screenRect.height - heightOfToolbar - topOffset - safeAreaOffset , width: screenRect.width, height: heightOfToolbar)
            annotationScrollView.toolbarView?.toolbarViewOrientation = .portraitlBottom
        }
        else {
            
            // landscape left
//            annotationScrollView.frame = CGRectMake(widthOfToolbar, 0, CGRectGetWidth(screenRect) - widthOfToolbar, CGRectGetHeight(screenRect) - topOffsetForLandscape)
//            annotationScrollView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(screenRect) - widthOfToolbar, CGRectGetHeight(screenRect) - topOffsetForLandscape)
//
//            annotationScrollView.toolbarView!.frame = CGRectMake(0, 0, widthOfToolbar, CGRectGetHeight(screenRect) - topOffsetForLandscape)
//            annotationScrollView.toolbarView?.toolbarViewOrientation = .LandscapeLeft

            // landscape right
            annotationScrollView.frame = CGRect(x: 0, y: 0, width: screenRect.width - widthOfToolbar, height: screenRect.height - topOffsetForLandscape)
            annotationScrollView.scrollView.contentSize = CGSize(width: screenRect.width - widthOfToolbar, height: screenRect.height - topOffsetForLandscape)
            
            annotationScrollView.toolbarView!.frame = CGRect(x: screenRect.width - widthOfToolbar, y: -safeAreaOffset, width: widthOfToolbar, height: screenRect.height - topOffsetForLandscape)
            annotationScrollView.toolbarView?.toolbarViewOrientation = .landscapeRight
        }
    }
}
