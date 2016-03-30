//
//  ViewController.m
//  AccelerometerDemo
//
//  Created by Omar Faruqe on 2016-03-29.
//  Copyright © 2016 Omar Faruqe. All rights reserved.
//
@import CoreMotion;
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *staticLabel;
@property (weak, nonatomic) IBOutlet UILabel *dynamicLabel;
@property (weak, nonatomic) IBOutlet UIButton *staticButton;
@property (weak, nonatomic) IBOutlet UIButton *dynamicStartButton;
@property (weak, nonatomic) IBOutlet UIButton *dynamicStopButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (assign, nonatomic) double x, y, z;

@property (strong, nonatomic) CMMotionManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.staticLabel.text = @"No Data";
    self.dynamicLabel.text = @"No Data";
    self.staticButton.enabled = NO;
    self.dynamicStartButton.enabled = NO;
    self.dynamicStopButton.enabled = NO;
    
    self.x = 0.0;
    self.y = 0.0;
    self.z = 0.0;
    
    self.manager = [[CMMotionManager alloc] init];
    if(self.manager.accelerometerAvailable){
        self.staticButton.enabled = YES;
        self.dynamicStopButton.enabled = YES;
        self.dynamicStartButton.enabled = YES;
    }
    else{
        self.staticLabel.text = @"No Accelerometer Available";
        self.dynamicLabel.text = @"No Accelerometer Available";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)staticRequest:(id)sender {
    CMAccelerometerData *aData = self.manager.accelerometerData;
    NSLog(@"\nx:%f\ny:%f\nz:%f",aData.acceleration.x, aData.acceleration.y, aData.acceleration.z);
    if(aData != nil){
        CMAcceleration acceleration = aData.acceleration;
        self.staticLabel.text = [NSString stringWithFormat:@"x:%f\ny:%f\nz:%f",acceleration.x,acceleration.y,acceleration.z];
    }
    else{
        NSLog(@"Accelerometer Data Reading error");
    }
}
- (IBAction)dynamicStart:(id)sender {
    self.dynamicStartButton.enabled = NO;
    self.dynamicStopButton.enabled = YES;
    
    self.manager.accelerometerUpdateInterval = 0.01;
    
    ViewController * __weak wekSelf = self;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [self.manager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * data, NSError *error) {
        double x = data.acceleration.x;
        double y = data.acceleration.y;
        double z = data.acceleration.z;
        
        self.x = 0.9 * self.x + 0.1 * x;
        self.y = 0.9 * self.y + 0.1 * y;
        self.z = 0.9 * self.z + 0.1 * z;
        
        double rotation = -atan2(self.x, -self.y);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Update UI
            wekSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
            wekSelf.dynamicLabel.text = [NSString stringWithFormat:@"x:%f\ny:%f\nz:%f",x,y,z];
        }];
    }];
}
- (IBAction)dynamicStop:(id)sender {
    [self.manager stopAccelerometerUpdates];
    self.dynamicStartButton.enabled = YES;
    self.dynamicStopButton.enabled = NO;
}



@end
