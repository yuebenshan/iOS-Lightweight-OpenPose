//
//  HeatmapsController.swift
//  OpenPose
//
//  Created by ben on 2019/7/22.
//  Copyright © 2019 ben. All rights reserved.
//

import UIKit

class HeatmapController: UIViewController {

    typealias FilterCompletion = ((UIImage?, InferenceError) -> ())
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true)
        } else {
            print("Photo library is not available")
        }
    }
    
    // MARK: - fuctions relative to CoreML
    
    func process(input: UIImage, complition: @escaping FilterCompletion) {
        let model = pose_368()
        
        DispatchQueue.global().async {
            
            // resize the image
            guard let inputImage = input.resize(to: CGSize(width: 368, height: 368)) else {
                complition(nil, InferenceError.resizeError)
                return
            }
            
            // convert the image
            guard let cvBufferInput = inputImage.pixelBuffer() else{
                complition(nil, InferenceError.pixelBufferError)
                return
            }
            
            // feed the image to the neural network
            let start = CFAbsoluteTimeGetCurrent()
            guard let output = try? model.prediction(input_image: cvBufferInput) else {
                complition(nil, InferenceError.predictionError)
                return
            }
            let delta = CFAbsoluteTimeGetCurrent() - start
            print("Time elapsed for OpenPose process \(delta) s")
            
            //
            // process the heatnap
            // output.heat_map_2 => (1,1,n, w, h)
            //
            let keypoint_number = output.heat_map_2.shape[2].int32Value
            let heatmap_w = output.heat_map_2.shape[3].int32Value
            let heatmap_h = output.heat_map_2.shape[4].int32Value
            
            var tensorShape:[Int32] = [heatmap_w, heatmap_h, keypoint_number]
            let convertedHeatMap = OpenCVWrapper.visualizeHeatmap(
                                                    output.heat_map_2,
                                                    heatmapShape: &tensorShape,
                                                    inputImage: self.imageView.image)
            
            DispatchQueue.main.sync {
                self.imageView.image = convertedHeatMap
            }
        }
    } // process
    
    @IBAction func drawKeypoints(_ sender: Any) {
        let image = self.imageView.image!
        
        self.process(input: image) { filteredImage, error in
            print(error)
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension HeatmapController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.imageView.image = pickedImage
            self.imageView.backgroundColor = .clear
        }
        self.dismiss(animated: true)
    }
}

