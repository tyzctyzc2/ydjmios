//
//  MyViewFunction.swift
//  YDJMK
//
//  Created by Casinolinkpa on 3/18/21.
//

import Foundation
import UIKit

var vGlobalSpinner : UIView?

extension UIViewController {
    func beautyView(forThisView: UIView) {
        forThisView.layer.borderWidth = 1
        forThisView.layer.borderColor = UIColor.lightGray.cgColor
        forThisView.layer.cornerRadius = 4
    }
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vGlobalSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vGlobalSpinner?.removeFromSuperview()
            vGlobalSpinner = nil
        }
    }
}
