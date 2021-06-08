//
//  TagViewController.swift
//  YDJMK
//
//  Created by Casinolinkpa on 3/15/21.
//
import UIKit

struct PickedTagDetail {
    static var picked: PickedTagDetail = PickedTagDetail()

    var list:Array<IDNamePair> = []
    var nameList:Array<String> = []
}

class TagListCell : UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }
}

class TagViewController: UITableViewController, UISearchBarDelegate, PairListLoadDoneDelegate, ProcessDoneDelegate {
    
    var allTagList:Array<IDNamePair> = []
    var showTagList:Array<IDNamePair> = []
    var pickedTagList:Array<Int> = []
    
    var httpHelper: HTTPHelper = HTTPHelper()
    @IBOutlet weak var searchBar: UISearchBar!
    
    func processDoneDelegatefuc(processRes: Bool, resMessage: String) {
        httpHelper.loadTagList()
    }
    
    func pairListLoadDoneDelegateFuc(loadList: Array<IDNamePair>) {
        print("load data is done")
        allTagList = loadList
        showTagList = loadList
        
        //convert picked name list to picked object
        if PickedTagDetail.picked.nameList.count > 0 {
            for tag in allTagList {
                if PickedTagDetail.picked.nameList.contains(tag.tagName) {
                    print("found picked item \(tag.tagName)")
                    pickedTagList.append(tag.tagId)
                }
            }
        }
        DispatchQueue.main.async(execute: {
            self.searchBar.text = ""
            self.tableView.reloadData()
        })
    }
    
    func swipeRightBack() {
        let right = UISwipeGestureRecognizer(target : self, action : #selector(swiptToExitOneLevelRight))
        right.direction = .right
                self.view.addGestureRecognizer(right)
    }
    
    @objc
    func swiptToExitOneLevelRight(){
        NSLog("do swipe....")
        //collect data first
        var pickedTags:Array<IDNamePair> = []
        for tag in allTagList {
            if pickedTagList.contains(tag.tagId) {
                pickedTags.append(tag)
            }
        }
        PickedTagDetail.picked.list = pickedTags
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Add"
        
        httpHelper.pairLoadDelegate = self
        httpHelper.loadTagList()
        httpHelper.doneDelegate = self
        
        swipeRightBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(PickedTagDetail.picked.nameList)

        let jsonString = String(data: jsonData!, encoding: .utf8)
        print("picked name = \(jsonString ?? "0000000000")")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBar.becomeFirstResponder()
        if searchText.isEmpty {
            self.showTagList = self.allTagList
            self.tableView.reloadData()
            return
        }
        
        print("want searchText: \(searchText)")
        self.showTagList.removeAll()
        for curTag in self.allTagList {
            if curTag.tagName.contains(searchText) {
                self.showTagList.append(curTag)
            }
        }
        
        //nothing to show, so we show 'add' button
        if self.showTagList.count == 0 {
            searchBar.showsCancelButton = true
        }
        
        // 刷新tableView 数据显示
        self.tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("搜索历史")
    }

    //使用这个功能来添加新tag
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("add new tag" + searchBar.text!)
        searchBar.showsCancelButton = false
        
        httpHelper.createTag(tagName: searchBar.text!)
        //httpHelper.loadTagList()
        //self.showTagList = self.allTagList
        //self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showTagList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)
        cell.textLabel?.text = showTagList[indexPath.row].tagName
        if pickedTagList.contains(showTagList[indexPath.row].tagId) {
            print("picked tag \(showTagList[indexPath.row].tagName)")
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            let tagPicked = showTagList[indexPath.row]
            if pickedTagList.contains(tagPicked.tagId) {
                cell.accessoryType = .none
                let index = pickedTagList.firstIndex(of: tagPicked.tagId)
                pickedTagList.remove(at: index!)
            } else {
                cell.accessoryType = .checkmark
                pickedTagList.append(tagPicked.tagId)
            }

        }
    }
}
