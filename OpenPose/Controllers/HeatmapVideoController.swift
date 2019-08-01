//
//  HeatmapVideoController.swift
//  OpenPose
//
//  Created by ben on 2019/7/29.
//  Copyright © 2019 ben. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class HeatmapVideoController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let model = pose_368()
    let session = AVCaptureSession()
    let deviceInput = DeviceInput()
    let output = AVCaptureVideoDataOutput()
    
    typealias FilterCompletion = ((UIImage?, InferenceError) -> ())
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // set input, output and session
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video-stream"))
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        
        // session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        // session.sessionPreset = AVCaptureSession.Preset.cif352x288
        session.addInput(deviceInput.backWildAngleCamera!)
        session.addOutput(output)
        
        
        let connection = output.connection(with: .video)
        connection?.videoOrientation = .portrait
        
        session.startRunning()

    }

    // MARK: - fuctions relative to CoreML
    
    func process(input: UIImage, complition: @escaping FilterCompletion) {
        
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
        guard let output = try? self.model.prediction(input_image: cvBufferInput) else {
            complition(nil, InferenceError.predictionError)
            return
        }
        
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
                                                inputImage: input)
        self.imageView.image = convertedHeatMap
    } // process
    
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension HeatmapVideoController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Fail to get pixel buffer")
            return
        }

        if let captureImage = buffer.toUIImage() {
            DispatchQueue.main.sync {
                self.imageView.image = captureImage
                self.process(input: self.imageView.image!) { image, error in
                    print(error)
                }
            }
        }
    }
    
}

