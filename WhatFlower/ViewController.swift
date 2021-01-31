//
//  ViewController.swift
//  WhatFlower
//
//  Created by Sergey Starchenkov on 28.01.2021.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    // Add picker object
    let pickerImage = UIImagePickerController()
    // Add URL API wikipedia
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
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
                self.requestInfo(flowerName: firstResult.capitalized)
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
    
    // Add request to Wiki use with API -> get info about flower
    func requestInfo(flowerName: String) {
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
        AF.request(wikipediaURl, method: .get, parameters: parameters).responseJSON
        { (response) in
            if case .success = response.result {
                
                let flowerJSON : JSON = JSON(response.value!)
                
                let pagesID = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pagesID]["extract"].stringValue
                
                let flowerImage = flowerJSON["query"]["pages"][pagesID]["thumbnail"]["source"].string
                
                self.imageView.sd_setImage(with: URL(string: flowerImage ?? ""))
                self.textLabel.text = flowerDescription
                
                
            }
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(pickerImage, animated: true, completion: nil)
        
    }
}

