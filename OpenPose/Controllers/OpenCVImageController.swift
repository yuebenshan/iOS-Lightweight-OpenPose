//
//  OpenCVImageController.swift
//  OpenPose
//
//  Created by ben on 2019/7/24.
//  Copyright © 2019 ben. All rights reserved.
//

import UIKit

class OpenCVImageController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var counter = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func changeColor(_ sender: Any) {
        let image = UIImage(named: "pose")
        if counter%2 == 0 {
            imageView.image = OpenCVWrapper.color2Gray(image, alphaExist: false)
        } else {
            imageView.image = image
        }
        counter = counter+1
    }
}
