//
//  TabBar.m
//  Cordova Plugin
//
//  Created by Lifetime.com.eg Technical Team (Amr Hossam / Emad ElShafie) on 6 January 2016.
//  Copyright (c) 2016 Lifetime.com.eg. All rights reserved.
//

#import <objc/runtime.h>
#import "TabBar.h"
#import <UIKit/UINavigationBar.h>
#import <QuartzCore/QuartzCore.h>

@implementation TabBar


- (void) pluginInitialize {
    
//    UIWebView *uiwebview = nil;
//    if ([self.webView isKindOfClass:[UIWebView class]]) {
//        uiwebview = ((UIWebView*)self.webView);
//    }
    tabBarItems = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    // -----------------------------------------------------------------------
    // This code block is the same for both the navigation and tab bar plugin!
    // -----------------------------------------------------------------------
    
    // The original web view frame must be retrieved here. On iPhone, it would be 0,0,320,460 for example. Since
    // Cordova seems to initialize plugins on the first call, there is a plugin method init() that has to be called
    // in order to make Cordova call *this* method. If someone forgets the init() call and uses the navigation bar
    // and tab bar plugins together, these values won't be the original web view frame and layout will be wrong.
    originalWebViewFrame = self.viewController.view.frame;
    
    
    navBarHeight = 44.0f;
    tabBarHeight = 49.0f;
    tabBarAtBottom = true;
    
}

- (UIColor*)colorStringToColor:(NSString*)colorStr
{
    NSArray *rgba = [colorStr componentsSeparatedByString:@","];
    return [UIColor colorWithRed:[[rgba objectAtIndex:0] intValue]/255.0f
                           green:[[rgba objectAtIndex:1] intValue]/255.0f
                            blue:[[rgba objectAtIndex:2] intValue]/255.0f
                           alpha:[[rgba objectAtIndex:3] intValue]/255.0f];
}

/**
 * Create a native tab bar at either the top or the bottom of the display.
 */
- (void)create:(CDVInvokedUrlCommand*)command
{
    if (tabBar) return;
    NSLog(@"Create TabBar");
    tabBar = [UITabBar new];
    [tabBar sizeToFit];
    tabBar.delegate = self;
    tabBar.multipleTouchEnabled   = NO;
    tabBar.autoresizesSubviews    = YES;
    tabBar.hidden                 = NO;
    tabBar.userInteractionEnabled = YES;
    tabBar.opaque = YES;
    tabBar.unselectedItemTintColor = [UIColor systemGrayColor];
    tabBar.tintColor = [self colorStringToColor:@"151,88,235,255"];
    
    CGRect f = tabBar.frame;
    f.origin.x = 0;
    f.origin.y = [UIScreen mainScreen].bounds.size.height + 100.0f;
    [tabBar setFrame: f];
    
    self.webView.superview.autoresizesSubviews = YES;
    
    [self.webView.superview addSubview:tabBar];
}

-(void) init:(CDVInvokedUrlCommand*)command
{
    // Dummy function, see initWithWebView
}

/**
 * Show the tab bar after its been created.
 * @brief show the tab bar
 * @param arguments unused
 * @param options used to indicate options for where and how the tab bar should be placed
 * - \c height integer indicating the height of the tab bar (default: \c 49)
 * - \c position specifies whether the tab bar will be placed at the \c top or \c bottom of the screen (default: \c bottom)
 */
- (void)show:(CDVInvokedUrlCommand*)command
{
    if (!tabBar) return;
    
    [UIView animateWithDuration:0.3 animations:^() {
        CGRect f = self->tabBar.frame;
        CGFloat y = [UIScreen mainScreen].bounds.size.height - self->tabBarHeight - self.viewController.view.safeAreaInsets.bottom;
        f.origin.y = y;
        [self->tabBar setFrame:f];
    } completion:^(BOOL finished) {
        
    }];
}

/**
 * Resize the tab bar (this should be called on orientation change)
 * @brief resize the tab bar on rotation
 * @param arguments unused
 * @param options unused
 */
- (void)resize:(CDVInvokedUrlCommand*)command
{
//    [self correctWebViewFrame];
}

/**
 * Hide the tab bar
 * @brief hide the tab bar
 * @param arguments unused
 * @param options unused
 */
- (void)hide:(CDVInvokedUrlCommand*)command
{
    if (!tabBar) return;
    [UIView animateWithDuration:0.3 animations:^() {
        CGRect f = self->tabBar.frame;
        CGFloat y = [UIScreen mainScreen].bounds.size.height + 100.0f;
        f.origin.y = y;
        [self->tabBar setFrame:f];
        
    } completion:^(BOOL finished) {
        
//        [self correctWebViewFrame];
    }];
    
}

/**
 * Create a new tab bar item for use on a previously created tab bar.  Use ::showTabBarItems to show the new item on the tab bar.
 *
 * If the supplied image name is one of the labels listed below, then this method will construct a tab button
 * using the standard system buttons.  Note that if you use one of the system images, that the \c title you supply will be ignored.
 * - <b>Tab Buttons</b>
 *   - tabButton:More
 *   - tabButton:Favorites
 *   - tabButton:Featured
 *   - tabButton:TopRated
 *   - tabButton:Recents
 *   - tabButton:Contacts
 *   - tabButton:History
 *   - tabButton:Bookmarks
 *   - tabButton:Search
 *   - tabButton:Downloads
 *   - tabButton:MostRecent
 *   - tabButton:MostViewed
 * @brief create a tab bar item
 * @param arguments Parameters used to create the tab bar
 *  -# \c name internal name to refer to this tab by
 *  -# \c title title text to show on the tab, or null if no text should be shown
 *  -# \c image image filename or internal identifier to show, or null if now image should be shown
 *  -# \c tag unique number to be used as an internal reference to this button
 * @param options Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if nil or unspecified, the badge will be hidden
 */
- (void)createItem:(CDVInvokedUrlCommand*)command
{
    if (!tabBar)
        [self create:nil];
    
    const id options = [command argumentAtIndex:4];
    
    NSString  *name      = [command argumentAtIndex:0];
    NSString  *title     = [command argumentAtIndex:1];
    NSDictionary  *imageName = [command argumentAtIndex:2];
    int tag              = [[command argumentAtIndex:3] intValue];
    
    UITabBarItem *item = nil;
    NSString * img = [imageName valueForKey:@"img"];
    NSString * img1 = [imageName valueForKey:@"img1"];
    CGFloat size = [[imageName valueForKey:@"size"] floatValue];
    UIImage * image = [self resize:[UIImage imageWithContentsOfFile:img] to: size];
    UIImage * image1 = [self resize:[UIImage imageWithContentsOfFile:img1] to: size];
    item = [[UITabBarItem alloc] initWithTitle:title image: image tag:tag];
    [item setSelectedImage: image1];
    
    if(options && options != [NSNull null])
    {
        id badgeOpt = [options objectForKey:@"badge"];
        
        if(badgeOpt && badgeOpt != [NSNull null])
            item.badgeValue = [badgeOpt stringValue];
    }
    
    [tabBarItems setObject:item forKey:name];
}


/**
 * Update an existing tab bar item to change its badge value.
 * @brief update the badge value on an existing tab bar item
 * @param arguments Parameters used to identify the tab bar item to update
 *  -# \c name internal name used to represent this item when it was created
 * @param options Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if nil or unspecified, the badge will be hidden
 */
- (void)updateItem:(CDVInvokedUrlCommand*)command
{
    if (!tabBar) [self create:nil];
    
    const NSDictionary *options = [command argumentAtIndex:1];
    
    if(!options)
    {
        NSLog(@"Missing options parameter in tabBar.updateItem");
        return;
    }
    
    NSString  *name = [command argumentAtIndex:0];
    UITabBarItem *item = [tabBarItems objectForKey:name];
    if(item)
    {
        
        if([options valueForKey:@"badge"] != nil){
            int badge = [[options valueForKey:@"badge"] intValue];
            if(badge > 0)
                item.badgeValue = [NSString stringWithFormat:@"%d", badge];
            else
                item.badgeValue = nil;
        }
    }
}


/**
 * Show previously created items on the tab bar
 * @brief show a list of tab bar items
 * @param arguments the item names to be shown
 * @param options dictionary of options, notable options including:
 *  - \c animate indicates that the items should animate onto the tab bar
 * @see createItem
 * @see create
 */
- (void)showItems:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Show Items");
    if (!tabBar) [self create:nil];
    NSLog(@"Arguments: %@", [command argumentAtIndex:0]);
    int i;
    NSUInteger count = [[command argumentAtIndex:0] count];
    NSLog(@"arguments: %lu", (unsigned long)count);
    //NSDictionary *options = nil;
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:MAX(count - 1, 1)];
    
    for(i = 0; i < count; ++i)
    {
        
        NSString *itemName = [[command argumentAtIndex:0] objectAtIndex:i];
        UITabBarItem *item = [tabBarItems objectForKey:itemName];
        if(item)
            [items addObject:item];
        else
            NSLog(@"Cannot show tab with unknown tag '%@'", itemName);
    }
    
    //BOOL animateItems = YES;
    //if(options && [options objectForKey:@"animate"])
    //animateItems = [(NSString*)[options objectForKey:@"animate"] boolValue];
    [tabBar setItems:items animated:NO];
}

/**
 * Manually select an individual tab bar item, or nil for deselecting a currently selected tab bar item.
 * @brief manually select a tab bar item
 * @param arguments the name of the tab bar item to select
 * @see createItem
 * @see showItems
 */
- (void)selectItem:(CDVInvokedUrlCommand*)command
{
    if (!tabBar)
        [self create:nil];
    
    NSString *itemName = [command argumentAtIndex:0];
    UITabBarItem *item = [tabBarItems objectForKey:itemName];
    if(item)
    {
        // Not called automatically when selectItem is called manually
        [self tabBar:tabBar didSelectItem:item];
        
        tabBar.selectedItem = item;
    }
    else
        tabBar.selectedItem = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSString * jsCallBack = [NSString stringWithFormat:@"tabbar.onItemSelected(%ld);", (long)item.tag];

    [self.commandDelegate evalJs:jsCallBack];
    
}

-(UIImage *)resize:(UIImage*)img to:(CGFloat)size
{
    CGSize itemSize = CGSizeMake(size, size); // 假设你想要的大小
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0);
    [img drawInRect:CGRectMake(0, 0, itemSize.width, itemSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end


@implementation UIView (NavBarCompat)

- (void)setTabBarAtBottom:(bool)tabBarAtBottom
{
    objc_setAssociatedObject(self, @"NavBarCompat_tabBarAtBottom", [NSNumber numberWithBool:tabBarAtBottom], OBJC_ASSOCIATION_COPY);
}

- (bool)tabBarAtBottom
{
    return [(objc_getAssociatedObject(self, @"NavBarCompat_tabBarAtBottom")) boolValue];
}

@end

