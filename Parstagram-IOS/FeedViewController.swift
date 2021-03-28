//
//  FeedViewController.swift
//  Parstagram-IOS
//
//  Created by hpuma on 3/20/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
  
    var posts = [PFObject]()
    var numberOfPosts = 20;
    let refreshControl = UIRefreshControl()
    let commentBar = MessageInputBar() // Object used for post comment creation
    var showsCommentBar = false // Boolean value that allows message bar to appear
    var selectedPost: PFObject! // Keeping track for creating a comment on current post
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fill in messages for comment keyboard
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive // Adds ability to dismiss keyboard by pulling it down
        // Do any additional setup after loading the view.
        
        // Broadcast all notifications
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object:nil )
    }
    // Makes keyboard to clear its text and dismiss itself
    @objc func keyboardWillBeHidden(note: Notification){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    
    // Input accessor bar functions, get it to show up in feed
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
        refreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    @objc func loadPosts(){
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.user"])
        query.limit = 20
        query.findObjectsInBackground{(posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        
    }
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create comments
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        comment["post"] = selectedPost
        comment["user"] = PFUser.current()
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground(){ (success, error) in
            if success {
                print("Comment Saved")
            } else {
                print("Error saving comment")
            }
            self.tableView.reloadData()
        }
        
        // Clear and dismiss the input prompt after the comment has been created
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableVIew: UITableView) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 { // If row is actually the post itself
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            return cell
        } else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["user"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    
    @IBAction func userLogout(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let delegate = windowScene.delegate as? SceneDelegate
            else {
            return
          }
        delegate.window?.rootViewController = loginViewController

    }
    // When we tap a post
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section] // Post that I selected
        let comment = PFObject(className: "Comments")
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder() // Causess calls become first responder to  reevaluate itself
            selectedPost = post
        }

    }
}
