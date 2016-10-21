//
//  AppDesignStyle.m
//  WebWatcher
//
//  Created by Kyle Genoe on 2016-10-21.
//  Copyright © 2016 Kyle Genoe. All rights reserved.
//

#import "AppDesignStyle.h"

@implementation AppDesignStyle


- (void) setCustomNavigationTitleFont:(UIFont *)font withColor:(UIColor *)fontColor{
    
    //Set custom font for navigation bar title
    NSDictionary *navTitleAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                  fontColor,
                                  NSForegroundColorAttributeName,
                                  font,
                                  NSFontAttributeName,
                                  nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navTitleAttr];
}

- (void) setCustomNavigationItemFont:(UIFont *)font withColor:(UIColor *)fontColor{
    
    //Set custom font for navigation bar items
    NSDictionary *navItemAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                 fontColor,
                                 NSForegroundColorAttributeName,
                                 font,
                                 NSFontAttributeName,
                                 nil];

    [[UIBarButtonItem appearance] setTitleTextAttributes:navItemAttr forState:UIControlStateNormal];
}

- (void) setCustomNavigationTintColor:(UIColor *)color{
    //used to set component color like the navigation back button color
    [[UINavigationBar appearance] setTintColor:color];
}



@end
