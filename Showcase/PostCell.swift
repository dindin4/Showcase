//
//  PostCell.swift
//  Showcase
//
//  Created by Dinesh Vijaykumar on 28/12/2016.
//  Copyright © 2016 Dinesh Vijaykumar. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseDatabase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var request:Request?
    var likeRef: FIRDatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
    }
    
    override func draw(_ rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        showcaseImage.clipsToBounds = true 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(post:Post, image:UIImage?) {
        self.post = post
        self.likeRef = DataService.instance.REF_USER_CURRENT.child("likes").child(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLabel.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            if image != nil {
                self.showcaseImage.image = image
            } else {
                request = Alamofire.request(post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (response: DefaultDataResponse) in
                    if response.error == nil {
                        let img = UIImage(data: response.data!)!
                        self.showcaseImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl! as AnyObject)
                    } else {
                        print(response.error.debugDescription)
                    }
                })
            }
        } else {
            self.showcaseImage.isHidden = true
        }
 
        likeRef.observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            if let _ = snapshot.value as? NSNull {
                // This means we have not liked this specific post 
                self.likeImage.image =  UIImage(named: "heart-empty")
            } else {
                self.likeImage.image =  UIImage(named: "heart-full")
            }
        }
    }
    
    func likeTapped(_ sender:UITapGestureRecognizer) {
        likeRef.observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            if let _ = snapshot.value as? NSNull {
                // This means we have not liked this specific post before
                self.likeImage.image =  UIImage(named: "heart-full")
                self.post.adjustLikes(addLike: true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image =  UIImage(named: "heart-empty")
                self.post.adjustLikes(addLike: false)
                self.likeRef.removeValue()
            }
        }
    }

}
