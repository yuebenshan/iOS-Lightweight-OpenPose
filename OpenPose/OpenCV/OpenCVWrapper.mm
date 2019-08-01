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

    /**
     * Convert a UIImage to grayscale.
     *
     * @param inputImage: Source image.
     * @param alphaExist: Existence of the alpha channel.
     *
     * @return A grayscale UIImage.
     */
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

    /**
     * Visualize the heatmap.
     *
     * @param heatmap: Heatmap of joints.
     * @param heatmapShape: The shape of the heatmap.
     *
     * @return A image which shows the position of the joints.
     */
    +(UIImage *) visualizeHeatmap: (MLMultiArray *) heatmap
                                   heatmapShape:(const int *) heatmapShape
                                   inputImage: (UIImage *) inputImage {
        int heatmap_w = heatmapShape[0];
        int heatmap_h = heatmapShape[1];
        int keypoint_number = heatmapShape[2] - 4; // remove eyes, ears and background
        
        int sizes[] = {heatmap_w, heatmap_h, keypoint_number};
        Mat imgFloat = Mat(2, sizes, CV_32FC1, Scalar(0));
        Mat imgUchar = Mat(2, sizes, CV_8UC1, Scalar(0));
        
        // gather the confidence of each joint
        unsigned int minValue = 0;
        unsigned int maxValue = 0;
        for(int k=0; k<keypoint_number; k++) {
            for(int i=0; i<heatmap_h; i++) {
                for(int j=0; j<heatmap_w; j++) {
                    int index = k * (heatmap_h * heatmap_w) + i * (heatmap_h) + j;
                    imgFloat.at<float>(i,j) += heatmap[index].floatValue;
                    
                    minValue = imgFloat.at<float>(i,j) < minValue ? imgFloat.at<float>(i,j) : minValue;
                    maxValue = imgFloat.at<float>(i,j) > maxValue ? imgFloat.at<float>(i,j) : maxValue;
                }
            }
        }
        
        unsigned int scale = 255/(maxValue - minValue);
        for(int i=0; i<heatmap_h; i++) {
            for(int j=0; j<heatmap_w; j++) {
                imgFloat.at<float>(i,j) = (imgFloat.at<float>(i,j) - minValue) * scale;
            }
        }
        imgFloat.convertTo(imgUchar, CV_8UC1);
        
        // create mask to filter the confidence below 100
        Mat mask = Mat::zeros(imgUchar.size(), CV_8UC1);
        threshold(imgUchar, mask, 100, 255, THRESH_BINARY);
        resize(mask, mask, cv::Size(inputImage.size.width, inputImage.size.height));
        
        // filter the color map
        Mat colorMap = Mat(2, sizes, CV_8UC3, Scalar(0));
        applyColorMap(imgUchar, colorMap, COLORMAP_JET);
        cvtColor(colorMap, colorMap, COLOR_BGR2RGB);
        resize(colorMap, colorMap, cv::Size(inputImage.size.width, inputImage.size.height));
        Mat filteredColorMap;
        colorMap.copyTo(filteredColorMap, mask);
        
        // blend the heatmap with the confidence map
        Mat inputImageMat, outputImageMat;
        UIImageToMat(inputImage, inputImageMat, false);
        
        cvtColor(inputImageMat, inputImageMat, COLOR_RGBA2RGB);
        addWeighted(inputImageMat, 0.8, filteredColorMap, 0.5, 0.0, outputImageMat);
        
        UIImage *output = MatToUIImage(outputImageMat);
        return output;
    }

@end

