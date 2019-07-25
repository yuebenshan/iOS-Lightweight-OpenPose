//
//  DeviceInput.swift
//  iOS-OpenCV
//
//  Created by ben on 2019/3/18.
//  Copyright © 2019 ben. All rights reserved.
//

//import Foundation
import AVFoundation

class DeviceInput: NSObject {
    
    // MARK: attributes
    
    var frontWildAngleCamera: AVCaptureDeviceInput?
    var backWildAngleCamera: AVCaptureDeviceInput?
    var backTelephotoCamera: AVCaptureDeviceInput?
    var backDualCamera: AVCaptureDeviceInput?
    var microphone: AVCaptureDeviceInput?
    
    // MARK: init
    
    override init() {
        super.init()
        getAllCameras()
        getMicrophone()
    }
    
    // MARK: get all camera devices
    
    func getAllCameras() {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInDualCamera,
                                                         .builtInTelephotoCamera,
                                                         .builtInWideAngleCamera]
        
        let cameraDevices = AVCaptureDevice.DiscoverySession(
                                                deviceTypes: deviceTypes,
                                                mediaType: .video,
                                                position: .unspecified).devices
        for camera in cameraDevices {
            let inputDevice = try! AVCaptureDeviceInput(device: camera)
            switch(camera.deviceType, camera.position) {
            case (.builtInWideAngleCamera, .front):
                frontWildAngleCamera = inputDevice
            case (.builtInWideAngleCamera, .back):
                backWildAngleCamera = inputDevice
            case (.builtInTelephotoCamera, _):
                backTelephotoCamera = inputDevice
            case(.builtInDualCamera, _):
                backDualCamera = inputDevice
            default:
                continue
            }
        }
    }
    
    // MARK: get microphone
    
    func getMicrophone() {
        if let mic = AVCaptureDevice.default(for: .audio) {
            microphone = try! AVCaptureDeviceInput(device: mic)
        }
    }
    
}
