//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Jose Zindia on 11/16/19.
//  Copyright © 2019 Jose Zindia. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onSubmitButton(_ sender: Any) {
        
        let post = PFObject(className: "Posts")
               
               post["caption"] = commentField.text
               post["author"] = PFUser.current()!
               
               let imageData = imageView.image!.pngData()
               let file = PFFileObject(data: imageData!)
               
               post["image"] = file
        
               post.saveInBackground { (success, error) in
                   if success {
                       self.dismiss(animated: true, completion: nil)
                       print("saved!")
                   } else{
                       print("errror!")
                   }
               }
    
    }
    
    
    
    @IBAction func onCameraButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
            
        }else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    

}