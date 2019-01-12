//
//  ViewController.swift
//  Photos
//
//  Created by Alex Paul on 1/12/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController {
  
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
  @IBOutlet weak var imageView: UIImageView!
  
  private var imagePickerController: UIImagePickerController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupImagePickerController()
    
    // set image content mode
    //imageView.contentMode = .scaleToFill // changes the aspect ratio to fill the frame
    imageView.contentMode = .scaleAspectFit // keeps aspect ratio
    //imageView.contentMode = .scaleAspectFill // fills frame keeping aspect ratio
  }
  
  private func setupImagePickerController() {
    imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      cameraButton.isEnabled = false
    }
  }
  
  private func showImagePickerController() {
    present(imagePickerController, animated: true, completion: nil)
  }
  
  @IBAction func photoLibraryButtonPressed(_ sender: UIBarButtonItem) {
    imagePickerController.sourceType = .photoLibrary
    showImagePickerController()
  }
  
  @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
    imagePickerController.sourceType = .camera
    
    // App will crash if you attempt to present the UIImagePickerViewController and you haven't included
    // the NSCameraUsageDescription key with a String explanation of the reason your app is using the camera.
    /*
     This app has crashed because it attempted to access privacy-sensitive data without a usage description.
     The app's Info.plist must contain an NSCameraUsageDescription key with a string value explaining to the user how the app uses this data.
    */
    
    checkAVAuthorizationStatus()
  }
  
  func showAlert() {
    let alertController = UIAlertController(title: "Settings Alert", message: "In order to use the camera you need to allow camera access", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { alert in }
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { alert in
      self.goToAppSettings()
    }
    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func goToAppSettings() {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
      print("url not valid for settings")
      return
    }
    if UIApplication.shared.canOpenURL(settingsURL) {
      UIApplication.shared.open(settingsURL, options: [:]) { (success) in
        // settings opened
        if !success {
          print("failed to open app settings")
        }
      }
    }
  }
  
  private func checkAVAuthorizationStatus() {
    let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    switch authorizationStatus {
    case .authorized:
      showImagePickerController()
    case .denied:
      // take user to phone settings to grant access
      showAlert()
    case .restricted:
      showAlert()
      // take user to phone settings to grant access
    case .notDetermined:
      requestAccess()
    }
  }
  
  private func requestAccess() {
    AVCaptureDevice.requestAccess(for: .video) { (granted) in
      if granted {
        self.showImagePickerController()
      }
    }
  }
}

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    print("\ninfo: \(info)\n") // keys: UIImagePickerController.InfoKey.originalImage
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      print("no image found")
      return
    }
    imageView.image = image
    dismiss(animated: true, completion: nil)
  }
}

