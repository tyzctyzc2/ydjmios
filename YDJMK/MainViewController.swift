//
//  MainViewController.swift
//  YDJMK
//
//  Created by Casinolinkpa on 3/15/21.
//

import UIKit
import Kingfisher

class PostTableCell : UITableViewCell {
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postTextLabel: UITextView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postCreateTime: UILabel!
}

class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PostDataLoadedDelegate {
    @IBOutlet weak var NewButton: UIButton!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var searchBarView: UISearchBar!
    
    var httpHelper:HTTPHelper = HTTPHelper()
    var postList:Array<PostViewData> = []
    var postImageMap:Dictionary<Int, Data> = [:]
    var searchKeyword:String = ""
    var nextPage:Int = 0
    var maxTextLength = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beautyView(forThisView: NewButton)
        httpHelper.postLoadedDelegate = self
        //httpHelper.binaryLoadDoneDelegate = self
        httpHelper.loadPostData(page: nextPage)
        self.postTableView.dataSource = self
        self.postTableView.delegate = self
        self.postTableView.separatorStyle = .none
        
        searchBarView.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar")
        self.searchBarView.becomeFirstResponder()
        if searchText.isEmpty {
            postList = []
            nextPage = 0
            searchKeyword = ""
            httpHelper.loadPostData(page: nextPage)
            return
        }
        
        print("want searchText: \(searchText)")
        postList = []
        searchKeyword = searchText
        nextPage = 0
        httpHelper.searchPostData(page: nextPage, keyword: searchKeyword)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        searchBar.resignFirstResponder()
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("搜索历史")
    }
    
    func postDataLoadedDelegateFunc(pageNo: Int, loadPosts: Array<PostViewData>) {
        // no new post found
        if loadPosts.count == 0 {
            if searchKeyword.isEmpty == false {
                DispatchQueue.main.async(execute: {
                    self.searchBarView.resignFirstResponder()
                })
            }
            return
        }
        
        if pageNo == 0 {
            postList = loadPosts
            nextPage = nextPage + 1
            DispatchQueue.main.async(execute: {
                self.postTableView.reloadData()
            })
        } else if nextPage == pageNo {
            nextPage = nextPage + 1
            postList = postList + loadPosts
            DispatchQueue.main.async(execute: {
                self.postTableView.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == postList.count {
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            if nextPage > 0 {
                print("load page " + String(nextPage))
                if searchKeyword.isEmpty {
                    httpHelper.loadPostData(page: nextPage)
                } else {
                    httpHelper.searchPostData(page: nextPage, keyword: searchKeyword)
                }
            }
            return loadingCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableCell
        let thisPost =  postList[indexPath.row]
        cell.postTitleLabel?.text = postList[indexPath.row].title
        var bodyText = postList[indexPath.row].content
        if postList[indexPath.row].content?.count ?? 0 > maxTextLength {
            bodyText = bodyText?.substring(to: maxTextLength)
        }
        cell.postTextLabel?.text = bodyText
        cell.postCreateTime?.text = postList[indexPath.row].createTime
        
        if thisPost.files?.count ?? 0 > 0 {
            let fileSample = thisPost.files?[0]
            let targetName = httpHelper.baseURL + "/" + (fileSample?.filePath)! + "/" + (fileSample?.fileName)!
            let url = URL(string: targetName)
            cell.postImageView.kf.setImage(with: url)
        } else {
            cell.postImageView.image = nil
        }
        
        self.beautyView(forThisView: cell.postImageView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tagPicked = postList[indexPath.row]
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostDetail") as? PostDetailController
        {
            vc.myPostData = tagPicked
            vc.firstShowFlag = true
            PickedTagDetail.picked.nameList = tagPicked.tags ?? []
            vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}
