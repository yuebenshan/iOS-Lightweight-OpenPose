//
//  OpenCVWrapper.h
//  OpenPose
//
//  Created by ben on 2019/7/24.
//  Copyright © 2019 ben. All rights reserved.
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import<UIKit/UIkit.h>
#import<Foundation/Foundation.h>
#import<CoreML/MLMultiArray.h>

@interface OpenCVWrapper : NSObject

    /**
     * Convert a UIImage to grayscale.
     *
     * @param inputImage: Source image.
     * @param alphaExist: Existence of the alpha channel.
     *
     * @return A grayscale UIImage.
     */
    +(UIImage *) color2Gray: (UIImage *)inputImage alphaExist:(bool) alphaExist;


    /**
     * Visualize the heatmap.
     *
     * @param heatmap: Heatmap of joints.
     * @param heatmapShape: The shape of the heatmap.
     *
     * @return A image which shows the position of the joints.
     */
    +(UIImage *) visualizeHeatmap: (MLMultiArray *) array
                                   heatmapShape:(const int *) heatmapShape
                                   inputImage: (UIImage *) inputImage;
@end

#endif /* OpenCVWrapper_h */
