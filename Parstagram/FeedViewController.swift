//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Jose Zindia on 11/15/19.
//  Copyright © 2019 Jose Zindia. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MessageInputBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
   override func viewDidLoad() {
       
       super.viewDidLoad()
       
       commentBar.inputTextView.placeholder = "Add a comment..."
       commentBar.sendButton.title = "Post"
       commentBar.delegate = self
       
       DataRequest.addAcceptableImageContentTypes(["application/octet-stream"])
       
       tableView.delegate = self
       tableView.dataSource = self
       
       tableView.keyboardDismissMode = .interactive
       
       let center = NotificationCenter.default
       center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       // Do any additional setup after loading the view.
   }
    
    @objc func keyboardWillBeHidden(note: Notification) {
          commentBar.inputTextView.text = nil
          showsCommentBar = false
          becomeFirstResponder()
      }
      
      override var inputAccessoryView: UIView? {
          return commentBar
      }
      
      override var canBecomeFirstResponder: Bool {
          return showsCommentBar
      }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier:"LoginViewController")
        
        //let delegate = UIApplication.shared.delegate as! AppDelegate
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        delegate.window?.rootViewController = loginViewController
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let query = PFQuery(className: "Posts")
       // query.includeKey(["author","comments","comments.author"])
        query.includeKeys(["author","comments","comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
    
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
                
            } else {
                print("error saving comment")
            }
    }
    
    tableView.reloadData()
    
    // clear and dismiss
    commentBar.inputTextView.text = nil
    showsCommentBar = false
    commentBar.inputTextView.resignFirstResponder()
    
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let post = posts[section]
    let comments = (post["comments"] as? [PFObject]) ?? []
    return comments.count + 2
    
    }
         
        
  func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username

            cell.captionLabel.text = post["caption"] as! String

            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!

            cell.photoView.af_setImage(withURL: url)
            return cell
            
    } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }

        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
    }
        
}

