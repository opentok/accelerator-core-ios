//
//  SendAnnotationViewController.swift
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 9/10/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import UIKit
import Foundation

class SendAnnotationViewController: UIViewController, OTOneToOneCommunicatorDataSource, OTAnnotatorDataSource, OTAnnotationToolbarViewDataSource {
    
    let annotator = OTAnnotator()
    var sharer: OTOneToOneCommunicator?
    
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var toolbarContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        sharer = OTOneToOneCommunicator(view: shareView)
        sharer?.dataSource = self
        sharer?.connect{
            (signal, error) in
            if error == nil {
                if signal == .publisherCreated {
                    self.sharer?.isPublishAudio = false
                    self.sharer?.isPublishVideo = false
                }
                else if signal == .subscriberReady {
                    self.sharer?.subscriberView.frame = self.shareView.bounds
                    self.shareView.addSubview(self.sharer!.subscriberView)
                    
                    self.annotator.dataSource = self
                    self.annotator.connect {
                        (signal, error) in
                        if error == nil {
                            if signal == .sessionDidConnect {
                                self.annotator.annotationScrollView.frame = self.shareView.bounds
                                self.annotator.annotationScrollView.scrollView.contentSize = self.shareView.bounds.size
                                self.shareView.addSubview(self.annotator.annotationScrollView)
                                self.annotator.annotationScrollView.annotationView.currentAnnotatable = OTAnnotationPath.init(stroke: UIColor.yellow)
                                
                                self.annotator.annotationScrollView.initializeToolbarView()
                                self.annotator.annotationScrollView.toolbarView?.toolbarViewDataSource = self
                                self.annotator.annotationScrollView.toolbarView?.frame = self.toolbarContainer.frame
                                self.view.addSubview(self.annotator.annotationScrollView.toolbarView!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        annotator.annotationScrollView?.removeFromSuperview()
        annotator.annotationScrollView?.toolbarView?.removeFromSuperview()
        annotator.disconnect()
        sharer?.subscriberView?.removeFromSuperview()
        let _ = sharer?.disconnect()
    }
    
    func annotationToolbarViewForRootView(forScreenShot toolbarView: OTAnnotationToolbarView!) -> UIView! {
        return shareView
    }
    
    func sessionOfOTOne(_ oneToOneCommunicator: OTOneToOneCommunicator!) -> OTAcceleratorSession! {
        return (UIApplication.shared.delegate as? AppDelegate)?.getSharedAcceleratorSession()
    }
    
    func session(of annotator: OTAnnotator!) -> OTAcceleratorSession! {
        return (UIApplication.shared.delegate as? AppDelegate)?.getSharedAcceleratorSession()
    }
}
