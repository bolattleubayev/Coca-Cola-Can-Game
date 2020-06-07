//
//  ProfileViewController.swift
//

import UIKit
import Firebase
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        
        print("Save unwind")
        
    }
    
    // MARK:- Firebase
        
    var postfeed: [PhotoCard] = []
    fileprivate var isLoadingPost = false // used for infinite scroll
    
    @objc fileprivate func loadRecentPosts() {
        isLoadingPost = true
        PostService.shared.getRecentPosts(start: postfeed.first?.timestamp, limit: 10) { (newPosts) in
            
            self.postfeed = []
            if newPosts.count > 0 {
                // Add the array to the beginning of the posts arrays
                self.postfeed.insert(contentsOf: newPosts, at: 0)
                self.subtitleLabel.text = "Отправлено фото: \(self.postfeed.count)"
            }
            
            self.isLoadingPost = false
            
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postfeed = []
        loadRecentPosts()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postfeed = []
        loadRecentPosts()
        
        Constants.modifyNavigationController(navigationController: navigationController)
        self.title = "Аккаунт"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let currentUser = Auth.auth().currentUser {
            nameLabel.text = currentUser.displayName
            
            // Getting user photo
            let url = currentUser.photoURL
            
            if let url = url {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.profilePictureImageView.image = UIImage(data: data!)
                    }
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: UIButton) {
        do {
            if let providerData = Auth.auth().currentUser?.providerData {
                let userInfo = providerData[0]
                
                switch userInfo.providerID {
                case "google.com":
                    GIDSignIn.sharedInstance().signOut()
                    
                default:
                    break
                }
            }

            try Auth.auth().signOut()
            
        } catch {
            let alertController = UIAlertController(title: "Logout Error", message: error.localizedDescription, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Present the welcome view
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeView") {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - CollectionView
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return postfeed.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            //Cell with Add button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdditionCell", for: indexPath)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? UserPhotoCollectionViewCell else {
                fatalError("Could not dequeue a cell")
            }
            
            cell.shopNameLabel.text = postfeed[indexPath.row].shopName
            cell.dateLabel.text = "\(Date(timeIntervalSince1970: TimeInterval(postfeed[indexPath.row].timestamp/1000)))"
            
            if postfeed[indexPath.row].imageFileURL != "" {
                let url = URL(string: postfeed[indexPath.row].imageFileURL)
                
                if let url = url {
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        DispatchQueue.main.async {
                            cell.uploadedPhotoView.image = UIImage(data: data!)
                        }
                    }
                }
            } else {
                cell.uploadedPhotoView.image = UIImage(named: "bottle")
            }
            
            return cell
        }
    }
    
    
}
