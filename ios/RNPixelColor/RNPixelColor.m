#include "RNPixelColor.h"
#import "RCTImageLoader.h"
#import "UIImage+ColorAtPixel.h"

@implementation RNPixelColor

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(createImage:(NSString *)path
                  callback:(RCTResponseSenderBlock)callback)
{
    [_bridge.imageLoader loadImageWithURLRequest:[RCTConvert NSURLRequest:path] callback:^(NSError *error, UIImage *image) {
        if (error || image == nil) { // if couldn't load from bridge create a new UIImage
            if ([path hasPrefix:@"data:"] || [path hasPrefix:@"file:"]) {
                NSURL *imageUrl = [[NSURL alloc] initWithString:path];
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
            } else {
                image = [[UIImage alloc] initWithContentsOfFile:path];
            }

            if (image == nil) {
                callback(@[@"Could not create image from given path.", @""]);
                return;
            }
        }

        self.image = image;
        callback(@[[NSNull null], @"Create image success"]);

    }];
    return;
}

RCT_EXPORT_METHOD(getHex:(NSDictionary *)options
                  callback:(RCTResponseSenderBlock)callback)
{
    NSInteger x = [RCTConvert NSInteger:options[@"x"]];
    NSInteger y = [RCTConvert NSInteger:options[@"y"]];
    if (options[@"width"] && options[@"height"]) {
        NSInteger scaledWidth = [RCTConvert NSInteger:options[@"width"]];
        NSInteger scaledHeight = [RCTConvert NSInteger:options[@"height"]];
        float originalWidth = self.image.size.width;
        float originalHeight = self.image.size.height;

        //validate event to scale image
        if (originalWidth < scaledWidth) {
            x = x * (scaledWidth / originalWidth);
        } else {
            x = x * (originalWidth / scaledWidth);
        }

        //validate event to scale image
        if (originalHeight < scaledHeight) {
            y = y * (scaledHeight / originalHeight);
        } else {
            y = y * (originalHeight / scaledHeight);
        }

    }

    CGPoint point = CGPointMake(x, y);

    UIColor *pixelColor = [self.image colorAtPixel:point];
    callback(@[[NSNull null], hexStringForColor(pixelColor)]);

}

NSString * hexStringForColor( UIColor* color ) {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];

    return hexString;
}

@end