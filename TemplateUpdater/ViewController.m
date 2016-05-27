//
//  ViewController.m
//  TemplateUpdater
//
//  Created by Chandan on 1/7/15.
//  Copyright (c) 2015 FluidTouch. All rights reserved.
//

#import "ViewController.h"

#define DOCUMENT_EXT @"whink"
//#define EXTRA_CHECKS 1

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityViewController;
@property (weak, nonatomic) IBOutlet UILabel *statusString;

@property (weak, nonatomic) IBOutlet UITextField *dataTypeTextField;
@property (weak, nonatomic) IBOutlet UITextField *templateNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *replaceKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *replaceValueTextField;
@property (weak, nonatomic) IBOutlet UITextField *packageNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *templateFolderPathTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueCompareTextField;
@property (weak, nonatomic) IBOutlet UITextField *whatTodoTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.activityViewController.hidden = YES;
    self.templateFolderPathTextField.text = @"/Projects/Whink/Whink/FTWhink/Templates/iPhone";

    
    self.packageNameTextField.text = @"";
    self.dataTypeTextField.text = @"string"; //data type
    self.templateNameTextField.text = @"DocumentAnnotations"; //plist name
    
    self.replaceKeyTextField.text = @"boundingRect"; //Key in the dictionary which you want to change
    self.replaceValueTextField.text = @"{{22, 253}, {348, 96}}";     //New Value
    
    self.valueCompareTextField.text = @"{{22, 253}, {348, 63}}"; //any comparistion required? like oldvalue == 1024 then only replace
    self.whatTodoTextField.text = @"update"; //update,add
}

- (IBAction)handleUpdateButton:(id)sender
{
    self.statusString.text = @"";
    
    [self.activityViewController startAnimating];
    self.activityViewController.hidesWhenStopped = YES;
    [self readFiles];
    [self.activityViewController stopAnimating];
}

-(BOOL)isContainer:(id)data
{
    BOOL isContainer = YES;
    if([data isKindOfClass:[NSDictionary class]]){
        isContainer = true;
    }
    else if([data isKindOfClass:[NSArray class]]){
        isContainer = true;
    }
    else{
        isContainer = NO;
    }
    return isContainer;
}

-(id)getNewValue
{
    id value = nil;
    if([self.dataTypeTextField.text isEqualToString:@"int"]){
        value = @(self.replaceValueTextField.text.integerValue);
    }
    else if([self.dataTypeTextField.text isEqualToString:@"float"]){
        value = @(self.replaceValueTextField.text.floatValue);
    }
    else if([self.dataTypeTextField.text isEqualToString:@"bool"]){
        value = @(self.replaceValueTextField.text.boolValue);
    }
    else{
        value = self.replaceValueTextField.text;
    }
    return value;
}

-(BOOL)canReplaceValue:(id)value
{
    BOOL status = NO;
    if(self.valueCompareTextField.text.length <= 0){
        status = YES;
    }
    else{
        if([value isKindOfClass:[NSNumber class]]){
            if(self.valueCompareTextField.text.floatValue == [value floatValue]){
                status = YES;
            }
        }
        else{
            if([self.valueCompareTextField.text isEqualToString:value]){
                status = YES;
            }
        }
    }
    return status;
}

-(void)replaceValueInDictionary:(id)data
{
    BOOL isAddingNewValue = NO;
    if([self.whatTodoTextField.text isEqualToString:@"add"]){
        isAddingNewValue = YES;
    }
    
    if([data isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *dictionary = (NSMutableDictionary*)data;
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([self isContainer:obj]){
                [self replaceValueInDictionary:obj];
            }
            else{
                if([self.replaceKeyTextField.text isEqualToString:key] || isAddingNewValue){
                    id oldValue = [dictionary objectForKey:key];
                    
                    BOOL extraCheck = YES;
                    #ifdef EXTRA_CHECKS
                    extraCheck = NO;
                        NSInteger type = [[dictionary objectForKey:@"templateType"] integerValue];
                        if(type == 2){
                            extraCheck = YES;
                        }
                    #endif
                    
                    BOOL canReplace = [self canReplaceValue:oldValue];
                    if(canReplace && extraCheck){
                        if([self.whatTodoTextField.text isEqualToString:@"update"]){
                            id newValue = [self getNewValue];
                            
//                            CGFloat scalefactor = 375.0f/768.0f;

//                            NSString *string = [dictionary objectForKey:self.replaceKeyTextField.text];
//                            CGRect rect = CGRectFromString(string);
//                            rect.origin.x = ceil(scalefactor*rect.origin.x);
//                            rect.origin.y = ceil(scalefactor*rect.origin.y);
//                            rect.size.width = ceil(scalefactor*rect.size.width);
//                            rect.size.height = ceil(scalefactor*rect.size.height);
//                            newValue = NSStringFromCGRect(rect);
                            
//                            NSNumber *lineheight = [dictionary objectForKey:self.replaceKeyTextField.text];
//                            newValue = @((NSInteger)ceil((lineheight.integerValue*scalefactor)));
                            
//                            NSNumber *fontSize = [dictionary objectForKey:self.replaceKeyTextField.text];
//                            newValue = @((NSInteger)ceil((fontSize.integerValue*scalefactor)));
                            
                            [dictionary setObject:newValue forKey:self.replaceKeyTextField.text];
                            self.statusString.text = [NSString stringWithFormat:@"Updated %@ with value %@(Old value: %@)",self.replaceKeyTextField.text,newValue,oldValue];
                        }
                        else if([self.whatTodoTextField.text isEqualToString:@"remove"]){
                            [dictionary removeObjectForKey:self.replaceKeyTextField.text];
                            self.statusString.text = [NSString stringWithFormat:@"Removed %@(Old value: %@)",self.replaceKeyTextField.text,oldValue];
                        }
                        else if([self.whatTodoTextField.text isEqualToString:@"add"]){
                            [dictionary setObject:[self getNewValue] forKey:self.replaceKeyTextField.text];
                            self.statusString.text = [NSString stringWithFormat:@"Added %@(Old value: %@)",self.replaceKeyTextField.text,oldValue];
                        }
                    }
                    else{
                        self.statusString.text = [NSString stringWithFormat:@"Old value(%@) is not equal to value in compare filed(%@) : empty the compare field and update again",oldValue,self.valueCompareTextField.text];
                    }
                }
            }
        }];
    }
    else if([data isKindOfClass:[NSArray class]]){
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self replaceValueInDictionary:obj];
        }];
    }
    else{
    }
}

-(void)updatePlist:(NSString*)plistPath
{
    NSDictionary *pListData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [self replaceValueInDictionary:pListData];
    [pListData writeToFile:plistPath atomically:YES];
    NSLog(@"%@ File updated",plistPath);
}

-(void)openFile:(NSString*)path
{
    NSString *fileType = [path pathExtension];
    if([fileType isEqualToString:@"plist"]){
        self.statusString.text = [NSString stringWithFormat:@"template '%@' Found",self.templateNameTextField.text];
        [self updatePlist:path];
    }
}

-(void)openFolder:(NSString*)path
{
    NSArray *filelist = [self getFilesInFolder:path];
    [filelist enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        //Update the key values here
        NSString *pathExtenstion = [obj pathExtension];
        if(pathExtenstion.length > 0){
            if(self.templateNameTextField.text.length == 0){
                [self openFile:[NSString stringWithFormat:@"%@/%@",path,obj]];
            }
            else if([self.templateNameTextField.text isEqualToString:[obj stringByDeletingPathExtension]]){
                [self openFile:[NSString stringWithFormat:@"%@/%@",path,obj]];
            }
        }
        else{
            [self openFolder:[NSString stringWithFormat:@"%@/%@",path,obj]];
        }
    }];

}

-(void)openAPNPackage:(NSString*)apnPackagePath
{
    [self openFolder:apnPackagePath];
}

-(void)readFiles
{
    NSString *mainPath = self.templateFolderPathTextField.text;
    NSArray *filelist = [self getFilesInFolder:mainPath];
    [filelist enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSString *packageName = [obj stringByDeletingPathExtension];
        if(self.packageNameTextField.text.length == 0){
            NSString *path = [obj pathExtension];
            if([path isEqualToString:DOCUMENT_EXT]){
                [self openAPNPackage:[NSString stringWithFormat:@"%@/%@",mainPath,obj]];
            }
        }
        else if([packageName isEqualToString:self.packageNameTextField.text]){
            NSString *path = [obj pathExtension];
            if([path isEqualToString:DOCUMENT_EXT]){
                [self openAPNPackage:[NSString stringWithFormat:@"%@/%@",mainPath,obj]];
            }
        }
    }];
}

-(NSArray*)getFilesInFolder:(NSString*)path
{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist = [filemgr contentsOfDirectoryAtPath:path  error: nil];
    return filelist;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
