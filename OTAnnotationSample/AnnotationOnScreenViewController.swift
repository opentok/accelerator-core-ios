//
//  AnnotationOnScreenViewController.swift
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import UIKit

class AnnotationOnScreenViewController: UIViewController {
    private let annotationOverContentViewController = OTFullScreenAnnotationViewController()
    private var statusBarHidden = false
    @IBOutlet weak var holderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Annotate", style: .plain, target: self, action: #selector(startAnnotation))
        
        let statusButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        statusButton.addTarget(self, action: #selector(stopAnnotation), for: .touchUpInside)
        statusButton.backgroundColor = UIColor(red: 118.0/255.0, green: 206.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        statusButton.setTitle("You are annotating your screen, Tap here to dismiss", for: .normal)
        statusButton.titleLabel!.font = UIFont.systemFont(ofSize: 12.0)
        annotationOverContentViewController?.view.addSubview(statusButton)
    }
    
    @IBAction func viewPressed(_ sender: UIView!) {
        holderView.bringSubviewToFront(sender)
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    @objc func startAnnotation() {
        self.statusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        let navigationBarFrame = navigationController!.navigationBar.frame
        let newFrame = CGRect(x: navigationBarFrame.origin.x, y: navigationBarFrame.origin.y, width: navigationBarFrame.size.width, height: 64)
        navigationController!.navigationBar.frame = newFrame
        self.present(annotationOverContentViewController!, animated: true, completion: nil)
    }
    
    @objc func stopAnnotation() {
        self.statusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
        self.dismiss(animated: true, completion: nil)
    }
}
