//
//  ViewController.swift
//  WhatFlower
//
//  Created by Sergey Starchenkov on 28.01.2021.
//

import UIKit
import CoreML
import Vision

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
            
            guard let ciimage = CIImage(image: userPickerImage) else {
                fatalError("Error creating ciimage")
            }
            
            detect(imageFlower: ciimage)
            
        }
        pickerImage.dismiss(animated: true, completion: nil)
    }
    
    // Add detect function with MLModel
    func detect(imageFlower: CIImage) {
        
        // Create model ML
        guard let model = try? VNCoreMLModel(for: FlowerClassifier(configuration: .init()).model) else {
            fatalError("Error creating model ML")
        }
        
        // Create request
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Error request")
            }
            if let firstResult = result.first?.identifier {
                self.navigationItem.title = firstResult.capitalized
            } 
        }
        
        // Create handler
        let handler = VNImageRequestHandler(ciImage: imageFlower)
        do{
            try handler.perform([request])
        }catch{
            print ("Error request perfome \(error)")
        }
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(pickerImage, animated: true, completion: nil)
        
    }
}

