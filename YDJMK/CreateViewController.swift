//
//  ViewController.swift
//  YDJMK
//
//  Created by Casinolinkpa on 3/4/21.
//

import UIKit
import PhotosUI


class CreateViewController: UIViewController, PHPickerViewControllerDelegate, ProcessDoneDelegate {
    var httpHelper:HTTPHelper = HTTPHelper()
    
    var currentImageIndex = 0
    
    var imageDataList:  Array<UIImage> = []

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var pushButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    
    @IBOutlet weak var addImageViewLine1A: UIImageView!
    @IBOutlet weak var addImageViewLine1B: UIImageView!
    @IBOutlet weak var addImageViewLine1C: UIImageView!
    
    @IBOutlet weak var addVideoImageButton: UIImageView!
    
    var pickPhotoMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beautyView(forThisView: titleTextField)
        beautyView(forThisView: contentTextView)
        beautyView(forThisView: addImageViewLine1A)
        beautyView(forThisView: addImageViewLine1B)
        beautyView(forThisView: addImageViewLine1C)
        beautyView(forThisView: addVideoImageButton)
        beautyView(forThisView: pushButton)
        beautyView(forThisView: tagButton)
        
        addImageViewLine1B.isHidden = true
        addImageViewLine1C.isHidden = true
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(addPhotoButtonTouch))
        addImageViewLine1A.isUserInteractionEnabled = true
        addImageViewLine1A.addGestureRecognizer(singleTap)
        
        let singleTapVideo = UITapGestureRecognizer(target: self, action: #selector(addVideoButtonTouch))
        addVideoImageButton.isUserInteractionEnabled = true
        addVideoImageButton.addGestureRecognizer(singleTapVideo)
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(swiptToExitOneLevelRight))
        right.direction = .right
                self.view.addGestureRecognizer(right)
        
        httpHelper.doneDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if PickedTagDetail.picked.list.count == 0 {
            return
        }
        
        var tagListLongName = ""
        for tag in PickedTagDetail.picked.list {
            tagListLongName = tagListLongName + tag.tagName + " "
        }
        self.tagButton.setTitle(tagListLongName, for: .normal)
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
    
    func Toast(Title:String ,Text:String, delay:Int) -> Void {
            let alert = UIAlertController(title: Title, message: Text, preferredStyle: .alert)
            self.present(alert, animated: true)
            let deadlineTime = DispatchTime.now() + .seconds(delay)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        }
    
    func resetUI() {
        self.titleTextField.text = ""
        self.contentTextView.text = ""
        PickedTagDetail.picked.list = []
        self.tagButton.setTitle("TAG", for: .normal)
        
        resetImageUI()
    }
    
    func resetImageUI() {
        self.addImageViewLine1A.image = UIImage(named:"AddIcon")
        self.addImageViewLine1B.image = nil
        self.addImageViewLine1C.image = nil
        
        addImageViewLine1B.isHidden = true
        addImageViewLine1C.isHidden = true
        
        currentImageIndex = 0
        self.imageDataList = []
    }
    
    func processDoneDelegatefuc(processRes: Bool, resMessage: String) {
        self.removeSpinner()
        if processRes == true {
            DispatchQueue.main.async(execute: {
                self.resetUI()
                self.pushButton.isEnabled = true
                self.pushButton.alpha = 1
                self.Toast(Title: "成功", Text: "数据成功发布", delay: 3)
            })
        } else {
            DispatchQueue.main.async(execute: {
                self.pushButton.isEnabled = true
                self.pushButton.alpha = 1
            self.Toast(Title: "失败", Text: "\n无法连接服务器，请检查服务器", delay: 3)
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    fileprivate func pickPhotoCase(_ results: [PHPickerResult]) {
        resetImageUI()
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        print("Selected image: \(image)")
                        self.imageDataList.append(image)
                        switch self.currentImageIndex {
                        case 0:
                            self.addImageViewLine1A.image = image
                            self.currentImageIndex = self.currentImageIndex + 1
                            break;
                        case 1:
                            self.addImageViewLine1B.isHidden = false
                            self.addImageViewLine1B.image = image
                            self.currentImageIndex = self.currentImageIndex + 1
                            break;
                        case 2:
                            self.addImageViewLine1C.isHidden = false
                            self.addImageViewLine1C.image = image
                            self.currentImageIndex = self.currentImageIndex + 1
                            break;
                        default:
                            return
                        }
                    }
                }
            })
        }
    }
    
    fileprivate func pickVideoCase(_ results: [PHPickerResult]) {
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        print("Selected image: \(image)")
                        self.imageDataList.append(image)
                        switch self.currentImageIndex {
                        case 0:
                            self.addImageViewLine1A.image = image
                            self.currentImageIndex = self.currentImageIndex + 1
                            break;
                        case 1:
                            self.addImageViewLine1B.isHidden = false
                            self.addImageViewLine1B.image = image
                            self.currentImageIndex = self.currentImageIndex + 1
                            break;
                        case 2:
                            self.addImageViewLine1C.isHidden = false
                            self.addImageViewLine1C.image = image
                            self.currentImageIndex = self.currentImageIndex + 1
                            break;
                        default:
                            return
                        }
                    }
                }
            })
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if pickPhotoMode == true {
            pickPhotoCase(results)
        } else {
            pickVideoCase(results)
        }
    }
    
    @IBAction func addPhotoButtonTouch(_ sender: Any) {
        pickPhotoMode = true
        var config = PHPickerConfiguration()
        config.selectionLimit = 9
        config.filter = PHPickerFilter.images

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func addVideoButtonTouch(_ sender: Any) {
        pickPhotoMode = false
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.videos

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func pushTouchDown(_ sender: Any) {
        if ((titleTextField.text?.isEmpty) == true) || ((contentTextView.text?.isEmpty) == true){
            return
        }
        self.showSpinner(onView: self.view)
        
        pushButton.isEnabled = false
        pushButton.alpha = 0.5
        httpHelper.createPost(title: titleTextField.text!, content: contentTextView.text, photoFiles: self.imageDataList)
    }
    @IBAction func tagButtonTouchDown(_ sender: Any) {
    }
}

