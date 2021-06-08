//
//  PhotoViewController.swift
//  YDJMK
//
//  Created by Casinolinkpa on 4/22/21.
//

import UIKit

class PhotoViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var photoURLList: Array<String> = []
    var imageView = UIImageView()
    
    var activePhotoIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(swiptToExitOneLevelRight))
        right.direction = .right
                self.view.addGestureRecognizer(right)
        
        let left = UISwipeGestureRecognizer(target : self, action : #selector(switchImage))
        left.direction = .left
                self.view.addGestureRecognizer(left)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resetZoom))
        gestureRecognizer.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(gestureRecognizer)
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        imageView.backgroundColor = UIColor.black
        let url = URL(string: photoURLList[activePhotoIndex])
        imageView.kf.setImage(with: url)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.isScrollEnabled = true
        scrollView.delegate = self

    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc
    func resetZoom() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
    @objc
    func swiptToExitOneLevelRight(){
        NSLog("do swipe....")
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc
    func switchImage() {
        activePhotoIndex = activePhotoIndex + 1
        
        if (activePhotoIndex > photoURLList.count - 1) {
            activePhotoIndex = 0
        }
        let url = URL(string: photoURLList[activePhotoIndex])
        imageView.kf.setImage(with: url)
    }
}
