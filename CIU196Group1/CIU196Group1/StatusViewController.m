//
//  StatusViewController.m
//  CIU196Group1
//
//  Created by saqirltu on 08/12/13.
//  Copyright (c) 2013 Eric Zhang, Robert Sebescen. All rights reserved.
//

#import "StatusViewController.h"
#import "Game.h"
#import "MyMarker.h"
@interface StatusViewController ()

@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
//@property (strong, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) IBOutlet UIView *actionView;

@property (strong, nonatomic) IBOutlet UILabel *targetLable;
- (IBAction)actionButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;
- (IBAction)skipButtonClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *player1;
@property (strong, nonatomic) IBOutlet UIImageView *player2;
@property (strong, nonatomic) IBOutlet UIImageView *player3;
@property (strong, nonatomic) IBOutlet UIImageView *player4;
@property (strong, nonatomic) IBOutlet UIImageView *player5;
@property (strong, nonatomic) IBOutlet UIImageView *player6;
@property (strong, nonatomic) IBOutlet UIImageView *player7;
@property (strong, nonatomic) IBOutlet UIImageView *player8;
@property (strong, nonatomic) IBOutlet UIImageView *player9;
@property (strong, nonatomic) IBOutlet UIImageView *player10;
@property (strong, nonatomic) IBOutlet UIImageView *player11;
@property (strong, nonatomic) IBOutlet UIImageView *player12;

@property (strong, nonatomic) IBOutlet MyMarker *turnMarker;


@end

@implementation StatusViewController

@synthesize timerLabel, infoLabel, actionView, targetLable, skipButton, player1, player2, player3, player4, player5, player6, player7, player8, player9, player10, player11, player12, turnMarker;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



NSMutableArray *players;
NSTimer *loopTimer;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    players = [NSMutableArray arrayWithObjects: player1, player2, player3, player4, player5, player6, player7, player8, player9, player10, player11, player12, player12 ,nil];
    
    
    UIImageView *tempIV;
    for (int i=0; i < [[Game sharedGame] count]; i++) {
        tempIV = (UIImageView*)[players objectAtIndex:i];
        [tempIV setImage:[[[Game sharedGame] heroAtIndex:i] image]];
    }

    //Not gonna have skip in plan
    [skipButton setHidden:TRUE];
    [skipButton setEnabled:FALSE];
    [actionView setHidden:TRUE];
    
   
    
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                   selector:@selector(loop) userInfo:nil repeats:YES];
}

- (IBAction)playerClicked:(id)sender {
    
    targetLable.text = [NSString stringWithFormat:@"%@ selected", [[[Game sharedGame] heroAtIndex:[sender tag]] name]];
    [[Game sharedGame] setTargetID:[sender tag]];
    NSLog(@"Sender of the click: %d", [sender tag]);
}

NSInteger count;
- (void)loop{

    // update the timer and the information all the time
    timerLabel.text = [NSString stringWithFormat:@"%d sec", [[Game sharedGame] readTimer]];
    infoLabel.text = [[Game sharedGame] news];
    
    for (int i = 0; i < [[Game sharedGame] count]; i++) {
        if ([[[Game sharedGame] heroAtIndex:i] isAlive]) {
            [(UIImageView*)[players objectAtIndex:i] setAlpha:1];
        } else{
            [(UIImageView*)[players objectAtIndex:i] setAlpha:0.5];
        }
    }
    
    //visilize the turn
    if ([[Game sharedGame] whoseTurn] >= 0) {
        UIImageView *tempIV = (UIImageView*)[players objectAtIndex:[[Game sharedGame] whoseTurn]];;
        
        turnMarker.frame = CGRectMake(tempIV.frame.origin.x, tempIV.frame.origin.y, tempIV.frame.size.width, tempIV.frame.size.height); // position in the parent view and set the size of the button
        
        // add to a view
        [self.view addSubview: turnMarker];
    }
    else{
        [turnMarker removeFromSuperview];
    }
    
    // TOTEST: seems we are not updating the myself.isalive, so need to check this
    
    if ([[Game sharedGame] turnFinished] && [[[Game sharedGame] myself] isAlive]) {
        //only case we show the action buttons
        [actionView setHidden:FALSE];
        UIImageView* tempIV;
        for (int i=0; i < [[Game sharedGame] count]; i++) {
            tempIV = (UIImageView*)[players objectAtIndex:i];
            if([[[Game sharedGame] heroAtIndex:i] isAlive]){
                UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                actionButton.frame = CGRectMake(tempIV.frame.origin.x, tempIV.frame.origin.y, tempIV.frame.size.width, tempIV.frame.size.height); // position in the parent view and set the size of the button
                [actionButton setTitle:@"select" forState:UIControlStateNormal];
                [actionButton setTag:i];
                // add targets and actions
                [actionButton addTarget:self action:@selector(playerClicked:) forControlEvents:UIControlEventTouchUpInside];
                // add to a view
                [actionView addSubview:actionButton];
            }
        }
        
    } else{
        [actionView setHidden:TRUE];
        [[actionView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        targetLable.text = @"";
    }
    
    //winning condition check
    if ([[Game sharedGame] winningCondition]) {
        if ([[Game sharedGame] winningCondition] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Well done!" message:@"Detectives Won!" delegate:self cancelButtonTitle:nil otherButtonTitles:nil,nil];
            [alert show];
            [self performSelector:@selector(autoDismiss:) withObject:alert afterDelay:4];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wohoo!" message:@"The Killer Won!" delegate:self cancelButtonTitle:nil otherButtonTitles:nil,nil];
            [alert show];
            [self performSelector:@selector(autoDismiss:) withObject:alert afterDelay:4];
        }
        
        [loopTimer invalidate];
    }
}

-(void)autoDismiss:(UIAlertView*)x{
	[x dismissWithClickedButtonIndex:-1 animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    [[Game sharedGame] endGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"did receive memory warning");
}


- (IBAction)actionButtonClicked:(id)sender {
    NSLog(@"it's clicked");
    [[[Game sharedGame] sessionController] commitAction: -1];
    [[Game sharedGame] setTargetID:-1];
    targetLable.text = @"";
}
- (IBAction)skipButtonClicked:(id)sender {
}

@end
