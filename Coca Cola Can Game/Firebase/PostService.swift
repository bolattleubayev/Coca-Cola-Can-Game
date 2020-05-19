//
//  PostService.swift

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

final class PostService {
    
    // MARK: - Properties
    
    static let shared: PostService = PostService()
    
    private init() { }
    
    // MARK: - Firebase Database References
    
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    
    let POST_DB_REF: DatabaseReference = Database.database().reference().child("PhotoCards")
    
    // MARK: - Firebase Storage Reference
    
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
    
    func getOldPosts(start timestamp: Int, limit: UInt, completionHandler: @escaping ( [PhotoCard]) -> Void) {
        
        let postOrderedQuery = POST_DB_REF.queryOrdered(byChild: PhotoCard.PhotoCardInfoKey.timestamp)
        let postLimitedQuery = postOrderedQuery.queryEnding(atValue: timestamp - 1, childKey: PhotoCard.PhotoCardInfoKey.timestamp).queryLimited(toLast: limit)
        
        postLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newPosts: [PhotoCard] = []
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                print("Post key: \(item.key)")
                let postInfo = item.value as? [String: Any] ?? [:]
                if let post = PhotoCard(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            
            // Order in descending order (i.e. the latest post becomes the first post)
            newPosts.sort(by: { $0.timestamp > $1.timestamp })
            
            completionHandler(newPosts)
        })
    }
    
    
    func getRecentPosts(start timestamp: Int? = nil, limit: UInt, completionHandler: @escaping ([PhotoCard]) -> Void) {
        
        var postQuery = POST_DB_REF.queryOrdered(byChild: PhotoCard.PhotoCardInfoKey.timestamp)
        
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            
            // If the timestamp is specified, we will get the posts with timestamp newer than the given value
            
            postQuery = postQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: PhotoCard.PhotoCardInfoKey.timestamp).queryLimited(toLast: limit)
        } else {
            // Otherwise, we will just get the most recent posts
            postQuery = postQuery.queryLimited(toLast: limit)
        }
        
        // Call Firebase API to retrieve the latest records
        
        postQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newPosts: [PhotoCard] = []
            
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let postInfo = item.value as? [String: Any] ?? [:]
                
                if let post = PhotoCard(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            

            if newPosts.count > 0 {
                // Order in descending order (i.e. the latest post becomes the first posts)
                newPosts.sort(by: { $0.timestamp > $1.timestamp })
            }
            
            completionHandler(newPosts)
        })
    }
    
    func uploadImage(image: UIImage, completionHandler: @escaping () -> Void) {
        
        // Generate a unique ID for the post and prepare the post database reference
        let postDatabaseRef = POST_DB_REF.childByAutoId()
        
        // Use the unique key as the image name and prepare the storage reference
        guard let imageKey = postDatabaseRef.key else {
            return
        }
        
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(imageKey).jpg")
        
        // Resize the image
        let scaledImage = image.scale(newWidth: 640.0)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.9) else {
            return
        }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Prepare the upload task
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        
        // Observe the upload status
        uploadTask.observe(.success) { (snapshot) in
            
            guard let displayName = Auth.auth().currentUser?.displayName else {
                return
            }
            
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else {
                    return
                }
                
                // Add a reference in the database
                
                let imageFileURL = url.absoluteString
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                
                let post: [String : Any] = ["imageFileURL" : imageFileURL,
                                            "votes" : Int(0),
                                            "user" : displayName,
                                            "timestamp" : timestamp]
                
                postDatabaseRef.setValue(post)
            })
            
            completionHandler()
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            
            print("Uploading \(imageKey).jpg... \(percentComplete)% complete")
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
        
    }
}
