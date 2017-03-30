//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <UIKit/UIKit.h>

@interface OpenCVHelper: NSObject
- (id)init;
- (UIImage *)detect:(UIImage *)srcImage;
@end
