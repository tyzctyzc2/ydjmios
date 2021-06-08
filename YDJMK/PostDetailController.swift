//
//  PostDetailController.swift
//  YDJMK
//
//  Created by Casinolinkpa on 4/16/21.
//

import UIKit

class PostDetailController : UIViewController, PostDetailLoadedDelegate, ProcessDoneDelegate {
    
    var httpHelper:HTTPHelper = HTTPHelper()
    var myPostData:PostViewData = PostViewData()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    var imageViewList: Array<UIImageView> = []
    var imageURLList: Array<String> = []
    
    var firstShowFlag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let right = UISwipeGestureRecognizer(target : self, action : #selector(swiptToExitOneLevelRight))
        right.direction = .right
                self.view.addGestureRecognizer(right)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tagListLabelTouched))
        contentTextView.addGestureRecognizer(singleTap)
        
        httpHelper.postDetailLoadedDelegate = self
        httpHelper.doneDelegate = self
        
    }
    
    func processDoneDelegatefuc(processRes: Bool, resMessage: String) {
        httpHelper.loadPostDetail(postId: myPostData.postId ?? 0)
    }
    
    func updatePostDisplay() {
        titleLabel.text = myPostData.title
        timeLabel.text = myPostData.createTime
        contentTextView.text = myPostData.content
        if myPostData.tags?.count ?? 0 > 0 {
            let fullTags = myPostData.tags?.joined(separator: ",")
            tagLabel.text = fullTags
        }
        
        if myPostData.files?.count ?? 0 > 0 {
            createImageView()
        }
        
        PickedTagDetail.picked.nameList = myPostData.tags ?? []
    }
    
    func postDetailLoadedDoneDelegateFunc(loadedPost: PostViewData) {
        myPostData = loadedPost
        
        if myPostData.postId == 0 {
            return
        }
        
        DispatchQueue.main.async(execute: {
            self.updatePostDisplay()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstShowFlag == true {
            firstShowFlag = false
            httpHelper.loadPostDetail(postId: myPostData.postId ?? 0)
            return
        }
        
        if PickedTagDetail.picked.list.count == 0 {
            return
        }
        
        var newTagList: [String] = []
        for tag in PickedTagDetail.picked.list {
            newTagList.append(tag.tagName)
            if myPostData.tags?.contains(tag.tagName) == false {
                confirmUpdateTag()
                break
            }
        }
        
        for oldTag in myPostData.tags! {
            if newTagList.contains(oldTag) == false {
                confirmUpdateTag()
            }
        }
    }
    
    func confirmUpdateTag() {
        var newTagNameListString = ""
        for tag in PickedTagDetail.picked.list {
            newTagNameListString = newTagNameListString + tag.tagName + ","
        }
        let messgae = PickedTagDetail.picked.nameList.joined(separator: ",") + "---->" + newTagNameListString
        let alert = UIAlertController(title: "是否修改标签？", message: messgae, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
            if action.title == "Yes" {
                self.httpHelper.updatePost(title: "", content: "", postId: self.myPostData.postId ?? 0)
                print("tapped on Yes")

            }else if action.title == "No" {
                print("tapped on No")
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action) in
            if action.title == "Yes" {
                self.httpHelper.updatePost(title: "", content: "", postId: self.myPostData.postId ?? 0)
                print("tapped on Yes")

            }else if action.title == "No" {
                print("tapped on No")
            }
        }))

        self.present(alert, animated: true)
    }
    
    @objc
    func tagListLabelTouched() {
        print("will edit tag")
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TagView") as? TagViewController
        {
            vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    @objc
    func imageViewTouched(sender: UITapGestureRecognizer) {
        print("!!!!")
        print(sender.view?.tag ?? -1)
        let imageIndex = sender.view?.tag ?? -1
        
        if (imageIndex < 0) {
            return
        }
        
        if let pv = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoView") as? PhotoViewController
        {
            pv.photoURLList = imageURLList
            pv.activePhotoIndex = imageIndex
            pv.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            present(pv, animated: true, completion: nil)
        }
    }
    
    func createImageView() {
        let slotLeft = 20
        let slotBetween = 10
        var imageSize = Int(self.view.bounds.width) - slotLeft * 2 - slotBetween * 2
        imageSize = imageSize / 3
        let totalLine = Int(ceil(Double(myPostData.files?.count ?? 0) / 3))
        var posY = Int(self.view.bounds.height) - slotLeft - imageSize * totalLine - slotBetween * (totalLine - 1) - imageSize
        
        for _ in 0...totalLine - 1 {
            posY = posY + imageSize + slotBetween
            for i in 0...2 {
                let posX = i * imageSize + slotLeft + i * slotBetween
                let curImageView = UIImageView()
                curImageView.frame = CGRect(x: posX, y: posY, width: imageSize, height: imageSize)
                curImageView.backgroundColor = UIColor.brown
                beautyView(forThisView: curImageView)
                curImageView.isHidden = true
                self.view.addSubview(curImageView)
                imageViewList.append(curImageView)
            }
        }
        
        for fileIndex in 0...myPostData.files!.count - 1 {
            let thisFile = myPostData.files?[fileIndex]
            let targetName = httpHelper.baseURL + "/" + (thisFile?.filePath)! + "/" + (thisFile?.fileName)!
            let url = URL(string: targetName)
            imageViewList[fileIndex].isHidden = false
            imageViewList[fileIndex].kf.setImage(with: url)
            imageViewList[fileIndex].clipsToBounds = true
            imageViewList[fileIndex].contentMode = .scaleAspectFill
            
            imageURLList.append(targetName)
            
            let singleTapImage = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTouched))
            imageViewList[fileIndex].isUserInteractionEnabled = true
            imageViewList[fileIndex].tag = fileIndex
            imageViewList[fileIndex].addGestureRecognizer(singleTapImage)
        }
        
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
}


