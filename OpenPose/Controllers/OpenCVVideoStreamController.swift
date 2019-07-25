//
//  OpenCVVideoStreamController.swift
//  OpenPose
//
//  Created by ben on 2019/7/24.
//  Copyright © 2019 ben. All rights reserved.
//

import UIKit
import AVFoundation

class OpenCVVideoStreamController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gray: UISwitch!
    
    let session = AVCaptureSession()
    let deviceInput = DeviceInput()
    let output = AVCaptureVideoDataOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // rotate the imageView
        imageView.contentMode = .scaleAspectFill
        let rotationAngle = CGFloat(Double.pi/2)
        imageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        // set input, output and session
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video-stream"))
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        
        // session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        // session.sessionPreset = AVCaptureSession.Preset.cif352x288
        session.addInput(deviceInput.backWildAngleCamera!)
        session.addOutput(output)
        session.startRunning()
    }
    
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension OpenCVVideoStreamController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Fail to get pixel buffer")
            return
        }
        
        if let captureImage = buffer.toUIImage() {
            DispatchQueue.main.async {
                if self.gray.isOn {
                    let grayImage = OpenCVWrapper.color2Gray(captureImage, alphaExist: true)
                    self.imageView.image = grayImage
                } else {
                    self.imageView.image = captureImage
                }
            }
        }
    }
    
}
