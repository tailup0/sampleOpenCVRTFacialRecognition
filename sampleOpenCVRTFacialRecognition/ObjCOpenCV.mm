//
//  ObjCOpenCV.m
//  sampleOpenCVRTFacialRecognition
//
//  Created by Muneharu Onoue on 2017/03/29.
//  Copyright © 2017年 Muneharu Onoue. All rights reserved.
//

#import "sampleOpenCVRTFacialRecognition-Bridging-Header.h"
#import <opencv2/opencv.hpp>

@interface OpenCVHelper()
{
    cv::CascadeClassifier cascade;
}
@end

@implementation OpenCVHelper: NSObject

- (id)init {
    self = [super init];
    
    // 分類器の読み込み
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
    std::string cascadeName = (char *)[path UTF8String];
    
    if(!cascade.load(cascadeName)) {
        return nil;
    }
    
    return self;
}

- (UIImage *)detect:(UIImage *)srcImage {
    
    cv::Mat srcMat = [self cvMatFromUIImage:srcImage];
    
    // グレースケール画像に変換
    cv::Mat grayMat;
    cv::cvtColor(srcMat, grayMat, CV_BGR2GRAY);
    
    // 探索
    std::vector<cv::Rect> objects;
    cascade.detectMultiScale(grayMat, objects,      // 画像，出力矩形
                             1.1, 1,                // 縮小スケール，最低矩形数
                             CV_HAAR_SCALE_IMAGE,   // （フラグ）
                             cv::Size(40, 40));     // 最小矩形
    
    // 結果の描画
    std::vector<cv::Rect>::const_iterator r = objects.begin();
    for(; r != objects.end(); ++r) {
        cv::Point center;
        int radius;
        center.x = cv::saturate_cast<int>((r->x + r->width*0.5));
        center.y = cv::saturate_cast<int>((r->y + r->height*0.5));
        radius = cv::saturate_cast<int>((r->width + r->height)*0.25);
        cv::circle(srcMat, center, radius, cv::Scalar(80,80,255), 3, 8, 0 );
    }
    
    return [self UIImageFromCVMat:srcMat];
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
