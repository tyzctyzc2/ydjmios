//
//  HttpHelper.swift
//  YDJMK
//
//  Created by Casinolinkpa on 3/8/21.
//

import Foundation
import UIKit

typealias Codable = Encodable & Decodable

struct FileData: Codable {
    var fileName:String?
    var filePath:String?
    var fileType:String?
    var fileBody:String?
}

struct PostData: Codable {
    var title:String
    var content: String
    var postId:Int
    var tags:[IDNamePair]
    var files:[FileData]
}

struct PostViewData: Codable {
    var title:String?
    var content: String?
    var postId: Int?
    var path:String?
    var createTime:String?
    var tags:[String]?
    var files:[FileData]?
}

struct IDNamePair: Codable {
    var tagId: Int
    var tagName: String
}

protocol ProcessDoneDelegate {
    func processDoneDelegatefuc(processRes: Bool, resMessage:String)
}

protocol PairListLoadDoneDelegate {
    func pairListLoadDoneDelegateFuc(loadList: Array<IDNamePair>)
}

protocol PostDataLoadedDelegate {
    func postDataLoadedDelegateFunc(pageNo: Int, loadPosts: Array<PostViewData>)
}

protocol BinaryLoadedDelegate {
    func binaryLoadDoneDelegateFunc(loadData:Data, refId:Int)
}

protocol PostDetailLoadedDelegate {
    func postDetailLoadedDoneDelegateFunc(loadedPost: PostViewData)
}

class HTTPHelper {
    var doneDelegate:ProcessDoneDelegate?
    var pairLoadDelegate:PairListLoadDoneDelegate?
    var postLoadedDelegate:PostDataLoadedDelegate?
    var binaryLoadDoneDelegate:BinaryLoadedDelegate?
    var postDetailLoadedDelegate:PostDetailLoadedDelegate?
    
    var baseURL = "http://192.168.0.100:8080/ydjm"
    
    func updatePost(title: String, content: String, postId: Int) {
        let url = URL(string: baseURL + "/api/post/update")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let imageBase64List:Array<FileData> = []
        
        let postData = PostData(title: title, content:content, postId: postId, tags: PickedTagDetail.picked.list, files:imageBase64List)
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(postData)

        let jsonString = String(data: jsonData!, encoding: .utf8)
        print("send update string:\n \(jsonString ?? "--------")")
        
        // Set HTTP Request Body
        request.httpBody = jsonString!.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    if((self.doneDelegate) != nil) {
                        self.doneDelegate?.processDoneDelegatefuc(processRes: false, resMessage: "")
                    }
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    if((self.doneDelegate) != nil) {
                        self.doneDelegate?.processDoneDelegatefuc(processRes: true, resMessage: "")
                    }
                    print("Response data string:\n \(dataString)")
                }
        }
        task.resume()
    }
    
    func createPost(title: String, content: String, photoFiles: Array<UIImage>) {
        let url = URL(string: baseURL + "/api/post/create")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var imageBase64List:Array<FileData> = []
        for oneImage in photoFiles {
            let imageData = oneImage.jpegData(compressionQuality: 1)
            let imageBase64String = imageData?.base64EncodedString()
            let oneFileData = FileData(fileName: "", filePath: "", fileType: "jpg", fileBody: imageBase64String!)
            imageBase64List.append(oneFileData)
        }
        
        let postData = PostData(title: title, content:content, postId: 0, tags: PickedTagDetail.picked.list, files:imageBase64List)
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(postData)

        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        // Set HTTP Request Body
        request.httpBody = jsonString!.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    if((self.doneDelegate) != nil) {
                        self.doneDelegate?.processDoneDelegatefuc(processRes: false, resMessage: "")
                    }
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    if((self.doneDelegate) != nil) {
                        self.doneDelegate?.processDoneDelegatefuc(processRes: true, resMessage: "")
                    }
                    print("Response data string:\n \(dataString)")
                }
        }
        task.resume()
    }
    
    func createTag(tagName: String) -> Void {
        let url = URL(string: baseURL + "/api/tag/create")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let postData = IDNamePair(tagId: 0, tagName: tagName)
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(postData)

        let jsonString = String(data: jsonData!, encoding: .utf8)
        request.httpBody = jsonString!.data(using: String.Encoding.utf8);
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error took place \(error)")
                    if((self.doneDelegate) != nil) {
                        self.doneDelegate?.processDoneDelegatefuc(processRes: false, resMessage: "")
                    }
                    return
                }
         
                // Convert HTTP Response Data to a String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    if((self.doneDelegate) != nil) {
                        self.doneDelegate?.processDoneDelegatefuc(processRes: true, resMessage: "")
                    }
                    print("Response data string:\n \(dataString)")
                }
        }
        task.resume()
    }
    
    func loadTagList() -> Void {
        let url = URL(string: baseURL + "/api/tag/list")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var loadTags : Array<IDNamePair> = []
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    if((self.pairLoadDelegate) != nil) {
                        self.pairLoadDelegate?.pairListLoadDoneDelegateFuc(loadList: loadTags)
                    }
                    return
                }
         
                // Convert HTTP Response Data to a String
            if let data = data, let _ = String(data: data, encoding: .utf8) {
                    if((self.pairLoadDelegate) != nil) {
                        let jsonDecoder = JSONDecoder()
                        do {
                            let tags = try jsonDecoder.decode([IDNamePair].self, from: data)
                            loadTags = tags
                        } catch { print(error) }
                        self.pairLoadDelegate?.pairListLoadDoneDelegateFuc(loadList: loadTags)
                    }
                }
        }
        task.resume()
    }
    
    func loadPostDetail(postId:Int) {
        if postId == 0 {
            return
        }
        let url = URL(string: baseURL + "/api/post/detail?postid=" + String(postId))
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var postDetail : PostViewData = PostViewData()
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                if((self.postLoadedDelegate) != nil) {
                    self.postDetailLoadedDelegate?.postDetailLoadedDoneDelegateFunc(loadedPost: postDetail)
                }
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                if((self.postDetailLoadedDelegate) != nil) {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let ps = try jsonDecoder.decode(PostViewData.self, from: data)
                        postDetail = ps
                    } catch { print(error) }
                    self.postDetailLoadedDelegate?.postDetailLoadedDoneDelegateFunc(loadedPost: postDetail)
                }
                print("Response data string:\n \(dataString)")
            }
        }
        task.resume()
    }
    
    func loadPostData(page:Int) -> Void {
        let url = URL(string: baseURL + "/api/post/list?page=" + String(page))
        guard let requestUrl = url else { fatalError() }
        doHttpGetData(requestUrl, page)
    }
    
    func searchPostData(page:Int, keyword:String) -> Void {
        let url = baseURL + "/api/post/list/find?page=" + String(page) + "&keyword=" + keyword
        let newUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlObj = URL(string: newUrl)
        guard let requestUrl = urlObj else { fatalError() }
        doHttpGetData(requestUrl, page)
    }
    
    fileprivate func doHttpGetData(_ requestUrl: URL, _ page: Int) {
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var posts : Array<PostViewData> = []
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                if((self.postLoadedDelegate) != nil) {
                    self.postLoadedDelegate?.postDataLoadedDelegateFunc(pageNo: page, loadPosts: posts)
                }
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                if((self.postLoadedDelegate) != nil) {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let ps = try jsonDecoder.decode([PostViewData].self, from: data)
                        posts = ps
                    } catch { print(error) }
                    self.postLoadedDelegate?.postDataLoadedDelegateFunc(pageNo: page, loadPosts: posts)
                }
                print("Response data string:\n \(dataString)")
            }
        }
        task.resume()
    }
    
    func loadStaticBinaryData(sourceName:String, postId:Int) -> Void {
        if sourceName.isEmpty {
            return
        }
        
        let url = URL(string: baseURL + "/" + sourceName)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
         
            if((self.binaryLoadDoneDelegate) != nil) {
                self.binaryLoadDoneDelegate?.binaryLoadDoneDelegateFunc(loadData: data!, refId: postId)
            }
            print("load image done:\n \(sourceName)")
         }
        task.resume()
    }
}
