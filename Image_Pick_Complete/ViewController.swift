//
//  ViewController.swift
//  Image_Pick_Complete
//
//  Created by Mr. Naveen Kumar on 18/04/21.
//

import UIKit
import Photos
import CropViewController
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var photoPickerButtonTapped: UIBarButtonItem!
    @IBOutlet weak var pickImageView: UIImageView!
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentCropViewController((pickImageView.image ?? UIImage(named: "oppsInternet.jpg"))!)
        photoPickerButtonTapped.target = self
        photoPickerButtonTapped.action = #selector(handlePhotoButtonTappedAction(sender: ))
    }
    
    @objc func handlePhotoButtonTappedAction(sender: UIBarButtonItem) {
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: "Pick Images from sources", preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.checkCameraAccess()
        }
        let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertAction.Style.default){
            UIAlertAction in
            self.checkGalleryAcess()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel){
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

 // MARK:- Action Method
extension ViewController {
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            picker.sourceType = UIImagePickerController.SourceType.camera
            self.picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary(){
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
}

// MARK:- Picker extension
extension ViewController:  UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            pickImageView.contentMode = .scaleAspectFit
            pickImageView.image = pickedImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // ImagePicker cancel Delegate method
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("picker cancel.")
        self.dismiss(animated: true, completion: nil)
    }
}

 // MARK:- Handle Photo-Gallery-Authorization
extension ViewController {
    func checkGalleryAcess() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .denied:
            print("User has denied the permission.")
            presentGallerySettings()
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .authorized:
            print("Access is granted by user")
            openGallary()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (success) in
                print("status is \(success)")
                if success ==  PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        self.openGallary()
                    }
                }else {
                    print("Permission denied")
                    DispatchQueue.main.async {
                        self.presentGallerySettings()
                    }
                }
            })
            print("It is not determined until now")
        default:
            break
        }
    }
    
    func presentGallerySettings() {
        let alertController = UIAlertController(title: "Error", message: "Photos access is denied", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        self.present(alertController, animated: true)
    }
}

 // MARK:- Handle Camera-Authorization
extension ViewController {
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
            self.openCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                    DispatchQueue.main.async {
                        self.openCamera()
                    }
                } else {
                    print("Permission denied")
                    DispatchQueue.main.async {
                        self.presentCameraSettings()
                    }
                }
            }
        default:
            break
        }
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error", message: "Camera access is denied", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        self.present(alertController, animated: true)
    }
}


// ------------------------------------------------------------------------
// To Crop Image using 3rd party -> CropViewController
extension ViewController: CropViewControllerDelegate {
   func presentCropViewController(_ img: UIImage) {
       // let image: UIImage = ... //Load an image
       let cropViewController = CropViewController(image: img)
       cropViewController.delegate = self
       self.present(cropViewController, animated: true, completion: nil)
   }
   
   func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
       // 'image' is the newly cropped version of the original image
       pickImageView.image = image
       cropViewController.dismiss(animated: true, completion: nil)
   }
   
   func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
       cropViewController.dismiss(animated: true) {
           print("cancelled called")
       }
   }
}
