//
//  ViewController.m
//  DemoSign
//
//  Created by Sergiy Lyahovchuk on 29.09.17.
//  Copyright © 2017 HardCode. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface ViewController () <FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

//@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.fbLoginBtn.delegate = self;
//    self.fbLoginBtn.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    
    NSLog(@"Token : %@", [FBSDKAccessToken currentAccessToken].tokenString);
    if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
        NSLog(@"User logged!!!");
        [self fetchProfile];
    }
    
    NSLog(@"SignIn = %d", [GIDSignIn sharedInstance].hasAuthInKeychain);
//    [GIDSignIn sharedInstance].scopes = @[@"https://www.googleapis.com/auth/plus.login",@"https://www.googleapis.com/auth/plus.me"];
    if ([GIDSignIn sharedInstance].hasAuthInKeychain) {
        /* Code to show your tab bar controller */
        NSLog(@"User Logged by Google");
        GIDGoogleUser *user = [GIDSignIn sharedInstance].currentUser;
        if(!user) {
            [[GIDSignIn sharedInstance] signInSilently];
        }
    } else {
        /* code to show your login VC */
        NSLog(@"User Don't Logged by Google");
    }
}
- (void)fetchProfile {
    NSDictionary *params = @{@"fields" : @"email, name, first_name, last_name, picture.type(large)"};
//    NSDictionary *params = @{@"fields" : @"id, name, link, first_name, last_name, picture.type(large), email, birthday ,location ,friends ,hometown , friendlists"};
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error == nil) {
            NSLog(@"User Info : %@", result);
        } else {
            NSLog(@"Error Getting Info : %@", error.debugDescription);
        }
    }];
}

- (IBAction)onBtnFBPressed:(id)sender {
    FBSDKLoginManager* flm = [[FBSDKLoginManager alloc]init];
    [flm logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
               fromViewController:self
                          handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                              if (error != nil) {
                                  NSLog(@"Error: %@", error.debugDescription);
                              } else if (result.isCancelled) {
                                  NSLog(@"User canceled Facebook authentification");
                              } else {
                                  NSLog(@"Sucessfully auth with FaceBook");
                                  NSLog(@"Credential = %@", [FBSDKAccessToken currentAccessToken].tokenString);
                              }
                          }];
}

- (IBAction)onBtnSignInPressed:(id)sender {
    GIDSignIn *gmanager = [GIDSignIn sharedInstance];
    GIDGoogleUser * currentUser = gmanager.currentUser;
    [GIDSignIn sharedInstance].scopes = @[@"https://www.googleapis.com/auth/plus.login"];
                                           
    if (currentUser == nil) {
        [[GIDSignIn sharedInstance] signIn];
    }
    
}

- (IBAction)onBtnSignOutPressed:(id)sender {
    GIDSignIn *gmanager = [GIDSignIn sharedInstance];
    GIDGoogleUser * currentUser = gmanager.currentUser;
    
    if (currentUser != nil) {
        [gmanager signOut];
    }
    
}

#pragma mark - GIDSignInDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    NSLog(@"User completed login");
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"User log out");
}

#pragma mark - FBSDKLoginButtonDelegate

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *fullName = user.profile.name;
    NSString *givenName = user.profile.givenName;
    NSString *familyName = user.profile.familyName;
    NSString *email = user.profile.email;
    NSURL *imageUrl = [user.profile imageURLWithDimension:400];
    NSLog(@"Sign In USER ID = %@, Token = %@, Name = %@, GivenName = %@, FamilyName = %@, Email = %@ ImageUrl = %@", userId, idToken, fullName,givenName, familyName,email,imageUrl);
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    NSLog(@"Sign Out USER = %@", user);
}

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
//    [myActivityIndicator stopAnimating];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
