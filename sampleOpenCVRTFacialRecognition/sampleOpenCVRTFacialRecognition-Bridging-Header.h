//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <UIKit/UIKit.h>

@interface OpenCVHelper: NSObject
+ (UIImage *)detect:(UIImage *)srcImage cascade:(NSString *)cascadeFilename;
@end
