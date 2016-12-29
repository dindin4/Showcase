//
//  FeedVC.swift
//  Showcase
//
//  Created by Dinesh Vijaykumar on 28/12/2016.
//  Copyright © 2016 Dinesh Vijaykumar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImageView: UIImageView!
    
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 358
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let ref = FIRDatabase.database().reference()
        ref.child("posts").observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as? PostCell {
            cell.request?.cancel()
            
            var image: UIImage?
            if let url = post.imageUrl {
                image = FeedVC.imageCache.object(forKey: url as AnyObject) as? UIImage
            }
            cell.configureCell(post: post, image: image)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageSelectorImageView.image = image
    }
    
    @IBAction func selectimage(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(_ sender: Any) {
        if let txt = postField.text, txt != "" {
            if let img = imageSelectorImageView.image {
                let urlString = "https://post.imageshack.us/upload_api.php"
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".data(using: String.Encoding.utf8)!
                let keyJSON = "json".data(using: String.Encoding.utf8)!
                
                Alamofire.upload(multipartFormData: { (data:MultipartFormData) in
                    data.append(imgData, withName: "fileupload", fileName: "image", mimeType: "image/jpg")
                    data.append(keyData, withName: "key")
                    data.append(keyJSON, withName: "format")
                }, to: urlString, encodingCompletion: { (encodingResult:SessionManager.MultipartFormDataEncodingResult) in
                    switch encodingResult {
                    case .success(let request, _, _):
                        request.responseJSON(completionHandler: { (response:DataResponse<Any>) in
                            if let info = response.result.value as? Dictionary<String, AnyObject> {
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let imageLink = links["image_link"] as? String {
                                        print("LINK: \(imageLink)")
                                    }
                                }
                            }
                        })
                    case .failure(let error):
                        print(error)
                    }
                })
            }
        }
    }
}
