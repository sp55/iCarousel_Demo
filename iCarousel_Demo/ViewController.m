//
//  ViewController.m
//  iCarousel_Demo
//
//  Created by admin on 16/6/1.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "ViewController.h"
#import "iCarousel.h"

@interface ViewController ()<iCarouselDataSource, iCarouselDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) iCarousel *carousel;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ViewController


- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _wrap = YES;
    
    
    //set up data
    //添加数据源
    self.items = [NSMutableArray array];
    for (int i = 0; i < 20; i++)
    {
        [_items addObject:@(i)];
    }
    
    //add background
    //添加背景
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.image = [UIImage imageNamed:@"background.png"];
    [self.view addSubview:backgroundView];
    
    //create carousel
    //旋转木马初始化
    _carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
    _carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    /*
     iCarouselTypeLinear = 0,
     iCarouselTypeRotary,
     iCarouselTypeInvertedRotary,
     iCarouselTypeCylinder,
     iCarouselTypeInvertedCylinder,
     iCarouselTypeWheel,
     iCarouselTypeInvertedWheel,
     iCarouselTypeCoverFlow,
     iCarouselTypeCoverFlow2,
     iCarouselTypeTimeMachine,
     iCarouselTypeInvertedTimeMachine,
     iCarouselTypeCustom
     */
    _carousel.type = iCarouselTypeCoverFlow2;//旋转类型
    _carousel.delegate = self;
    _carousel.dataSource = self;
    
    //add carousel to view
    //添加到view上
    [self.view addSubview:_carousel];
    
    //add top bar
    //添加头
    UINavigationBar *navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    navbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navItem = [[UINavigationItem alloc] initWithTitle:@"Coverflow2"];
    _navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Switch Type" style:UIBarButtonItemStylePlain target:self action:@selector(switchCarouselType)];
    _navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Wrap: ON" style:UIBarButtonItemStylePlain target:self action:@selector(toggleWrap)];
    [navbar setItems:@[_navItem]];
    [self.view addSubview:navbar];
    
    //add bottom bar
    //底部  添加和删除
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [toolbar setItems:@[[[UIBarButtonItem alloc] initWithTitle:@"Insert Item" style:UIBarButtonItemStylePlain target:self action:@selector(insertItem)],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                        [[UIBarButtonItem alloc] initWithTitle:@"Delete Item" style:UIBarButtonItemStylePlain target:self action:@selector(removeItem)]]];
    [self.view addSubview:toolbar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.carousel = nil;
    self.navItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)switchCarouselType
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select Carousel Type"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Linear", @"Rotary", @"Inverted Rotary", @"Cylinder", @"Inverted Cylinder", @"Wheel", @"Inverted Wheel",  @"CoverFlow", @"CoverFlow2", @"Time Machine", @"Inverted Time Machine", @"Custom", nil];
    [sheet showInView:self.view];
}

- (void)toggleWrap
{
    _wrap = !_wrap;
    _navItem.rightBarButtonItem.title = _wrap? @"Wrap: ON": @"Wrap: OFF";
    [_carousel reloadData];
}

- (void)insertItem
{
    NSInteger index = _carousel.currentItemIndex;
    [_items insertObject:@(_carousel.numberOfItems) atIndex:index];
    [_carousel insertItemAtIndex:index animated:YES];
}

- (void)removeItem
{
    if (_carousel.numberOfItems > 0)
    {
        NSInteger index = _carousel.currentItemIndex;
        [_carousel removeItemAtIndex:index animated:YES];
        [_items removeObjectAtIndex:index];
    }
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0)
    {
        //map button index to carousel type
        iCarouselType type = buttonIndex;
        
        //carousel can smoothly animate between types
        [UIView beginAnimations:nil context:nil];
        _carousel.type = type;
        [UIView commitAnimations];
        
        //update title
        _navItem.title = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
    /*
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [_items[index] stringValue];
    
    return view;
    
    */
    
    
    /**/
     UIButton *button = (UIButton *)view;
     if (button == nil)
     {
     //no button available to recycle, so create new one
     UIImage *image = [UIImage imageNamed:@"page.png"];
     button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
     [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     [button setBackgroundImage:image forState:UIControlStateNormal];
     button.titleLabel.font = [button.titleLabel.font fontWithSize:50];
     [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
     }
     
     //set button label
     [button setTitle:[NSString stringWithFormat:@"%ld", index] forState:UIControlStateNormal];
     
     return button;
     /**/
}

#pragma mark Button tap event

- (void)buttonTapped:(UIButton *)sender
{
    //get item index for button
    NSInteger index = [_carousel indexOfItemViewOrSubview:sender];
    
    [[[UIAlertView alloc] initWithTitle:@"Button Tapped"
                                message:[NSString stringWithFormat:@"You tapped button number %ld", index]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}


- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return _wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

@end
