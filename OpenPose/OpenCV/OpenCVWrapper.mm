//
//  OpenCVWrapper.mm
//  OpenPose
//
//  Created by ben on 2019/7/24.
//  Copyright © 2019 ben. All rights reserved.
//

#include<opencv2/opencv.hpp>
#include<opencv2/imgcodecs/ios.h>
#include"OpenCVWrapper.h"

using namespace cv;
using namespace std;

@implementation OpenCVWrapper: NSObject

    +(UIImage *) color2Gray: (UIImage *)inputImage alphaExist:(bool) alphaExist {
        Mat image;
        Mat gray;
        
        UIImageToMat(inputImage, image, alphaExist);
        
        if (alphaExist) {
            cvtColor(image, gray, CV_RGBA2GRAY);
        } else {
            cvtColor(image, gray, CV_RGB2GRAY);
        }
        
        UIImage *output = MatToUIImage(gray);
        return output;
    }

@end
