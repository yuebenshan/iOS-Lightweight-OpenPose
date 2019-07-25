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

@interface OpenCVWrapper : NSObject

    +(UIImage *) color2Gray: (UIImage *)inputImage alphaExist:(bool) alphaExist;

@end

#endif /* OpenCVWrapper_h */
