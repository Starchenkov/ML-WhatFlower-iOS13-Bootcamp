//
//  ViewController.swift
//  WhatFlower
//
//  Created by Sergey Starchenkov on 28.01.2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // Add picker object
    let pickerImage = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set picker object parameters
        pickerImage.delegate = self
        pickerImage.allowsEditing  = true
        pickerImage.sourceType = .camera
        
    }

    // Add picker delegate func
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickerImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            imageView.image = userPickerImage
            
        }
        pickerImage.dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(pickerImage, animated: true, completion: nil)
        
    }
}

