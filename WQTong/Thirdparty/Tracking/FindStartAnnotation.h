//
//  FindStartAnnotation.h
//  waiqintong
//
//  Created by Apple on 11/12/15.
//  Copyright © 2015 cnbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FindStartAnnotation :  MAPointAnnotation
/*!
 @brief 标注对应的annotation
 */
@property (nonatomic, strong) MAPointAnnotation *annotation;
@end
