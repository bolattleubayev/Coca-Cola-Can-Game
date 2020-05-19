//
//  SendPhotoTableViewController.swift
//  Coca Cola Can Game
//
//  Created by macbook on 5/19/20.
//  Copyright © 2020 bolattleubayev. All rights reserved.
//

import UIKit
import Firebase

class SendPhotoTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //MARK: - Variables
    
    // Data and Firebase
    private var timestamp: Int = Int(Date().timeIntervalSince1970 * 1000)
    private var imageFileURL: String = ""
    
    // View
    var isPickerHidden = true
    var imagePicker = UIImagePickerController()
    
    // MARK: - Outlets
    
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopPickerView: UIPickerView!
    @IBOutlet weak var barCodeTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func unwindToPhotoUpload(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveScan" else { return }
        //let sourceViewController = segue.source as! BarCodeScannerViewController
        
        //barCodeTextField.text = String(sourceViewController.scannedNumber)
    }
    
    @IBAction func barCodeEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func barEnterPressed(_ sender: UITextField) {
        barCodeTextField.resignFirstResponder()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        // Data upload
        let POST_DB_REF: DatabaseReference = Database.database().reference().child("CocaColaCanGameItems").childByAutoId()
        
//        let post: [String : Any] = ["imageFileURL": "",
//                                    "user": "Assylkhan Tleubayev",
//                                    "timestamp": timestamp,
//                                    "shopName": Constants.colaPlaces[shopPickerView.selectedRow(inComponent: 0)].name,
//                                    "barCode": Int(barCodeTextField.text ?? "0") ?? 0,
//                                    "longitude": 51.0,
//                                    "latitude": 42.0,
//                                    "comments": notesTextView.text ?? "https://google.com"]

        //POST_DB_REF.setValue(post)
        
        // Image upload
        
        //let POST_DB_REF: DatabaseReference = Database.database().reference().child("CocaColaCanGameItems")
        let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
        
        // Generate a unique ID for the post and prepare the post database reference
        //let postDatabaseRef = POST_DB_REF.child(item.postID)
        
        // Use the unique key as the image name and prepare the storage reference
        guard let imageKey = POST_DB_REF.key else {
            return
        }
        
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(imageKey).jpg")
        
        // Resize the image
        let scaledImage = photoImageView.image!.scale(newWidth: 640.0)
        
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
            
//            guard let displayName = Auth.auth().currentUser?.displayName else {
//                return
//            }
            
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else {
                    return
                }
                
                // Add a reference in the database
                
                let imageFileURL = url.absoluteString
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                
                
                let post: [String : Any] = ["imageFileURL": imageFileURL,
                                            "user": "Assylkhan Tleubayev",
                                            "timestamp": timestamp,
                                            "shopName": Constants.colaPlaces[self.shopPickerView.selectedRow(inComponent: 0)].name,
                                            "barCode": Int(self.barCodeTextField.text ?? "0") ?? 0,
                                            "longitude": 51.0,
                                            "latitude": 42.0,
                                            "comments": self.notesTextView.text ?? "https://google.com"]
                
                POST_DB_REF.setValue(post)
            })
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
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    
    func updateSaveButtonState() {
        let barCodeText = barCodeTextField.text ?? ""
        saveButton.isEnabled = !barCodeText.isEmpty
    }
    
    func updateExpiryLabel() {
        shopNameLabel.text = "\(Constants.colaPlaces[shopPickerView.selectedRow(inComponent: 0)].name)"
    }
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        shopPickerView.delegate = self
        shopPickerView.dataSource = self
        
        Constants.modifyNavigationController(navigationController: navigationController)
    }
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(90)
        let largeCellHeight = CGFloat(200)
        
        switch(indexPath) {
        case [0, 0]: // Shop Picker View Cell
            return isPickerHidden ? CGFloat(44) : largeCellHeight
        case [1, 0]: // Photo Cell
            return largeCellHeight
        case [2, 0]: // Comment Cell
            return largeCellHeight
        default: return normalCellHeight
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath) {
        case [0, 0]: // Shop Picker View Cell
            
            isPickerHidden = !isPickerHidden
            
            shopNameLabel.textColor = isPickerHidden ? .black : tableView.tintColor
            
            tableView.beginUpdates()
            tableView.endUpdates()
        case [1, 0]: // Image Cell
            callImagePicker()
        default: break
        }
    }
    
    // MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.colaPlaces.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Constants.colaPlaces[row].name)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        shopNameLabel.text = "\(Constants.colaPlaces[row].name)"
        updateExpiryLabel()
        self.view.endEditing(true)
    }
    
    // MARK: - Image Picker
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            

            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFit
            photoImageView.clipsToBounds = true
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func callImagePicker() {
        let alert = UIAlertController(title: "Select Image Source", message: "Please choose the image source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                let alert  = UIAlertController(title: "Warning", message: "This source type is not available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })

        let photoGalleryAction = UIAlertAction(title: "Photo Gallery", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        
        alert.addAction(cameraAction)
        alert.addAction(photoGalleryAction)
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        // Handling the iPad action sheet representation
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }

        self.present(alert, animated: true, completion: nil)
    }
    
}
