//
//  ObjCOpenCV.h
//  sampleOpenCVRTFacialRecognition
//
//  Created by Muneharu Onoue on 2017/03/29.
//  Copyright © 2017年 Muneharu Onoue. All rights reserved.
//

#ifndef ObjCOpenCV_h
#define ObjCOpenCV_h

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
//#import <opencv2/imgcodecs/ios.h>

@interface OpenCVHelper: NSObject
+ (UIImage *)detect:(UIImage *)srcImage cascade:(NSString *)cascadeFilename;
@end

#endif /* ObjCOpenCV_h */
