//
//  CameraViewController.swift
//  Parstagram-IOS
//
//  Created by hpuma on 3/20/21.
//

import UIKit
import AlamofireImage

// Second/Third one is for after camera is used
class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
    }
    
    // Tap gesture recognizer on submit button
    // Launch camera to take picture
    // Quick and dirty approach
    @IBAction func onCameraButton(_ sender: Any) {
        // Built in view controller
        let picker = UIImagePickerController()
        picker.delegate = self // When user is done with taking image, callback here
        picker.allowsEditing = true // Presents a second screen after taking an image
        // When the camera is availible
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        } else { // Camera is not availible so open photos library
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    // After an image has been picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        imageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
    
}
