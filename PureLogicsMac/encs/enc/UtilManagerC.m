//
//  UtilManagerC.m
//  googledriveIntegration
//
//  Created by admin on 10/6/21.
//

#import "UtilManagerC.h"

#define d_rootDirectoryOnly [NSHomeDirectory() stringByAppendingString:@"/"];
#define d_DocumentPhoto @"Documents/GoogleDriveData/"

@implementation UtilManagerC

-(id)init {
    self = [super init];
    return self;
}

-(NSString*)readFile:(NSString*)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"IN read file method");

////    NSString *documentsPath =
////        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
////    documentsPath = [self getRootPath];
////    NSLog(@"document path %@",documentsPath);
//
//
//    ///Users/macbookpro/Desktop/Project iOS/FolderLock/Free/encs
//    /**
//
//
//
//
//     NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//     NSString *miscellaneousFolder = [documentPath stringByAppendingString:@"/FolderLockAdvanced/Miscellaneous/"];
//     */
//
//
//    NSString *bundleRoot = d_rootDirectoryOnly;
//    NSLog(@"root directory: %@",bundleRoot);
//
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//
//    //NSString *newDocuentPath = @"/Users/macbookpro/Desktop/Project iOS/FolderLock/Free/encs/manager/";
//    NSString *newDocuentPath = [documentPath stringByAppendingString:@"/encs/manager/"];
//
//    //@"/encs/manager/";
//    NSLog(@"new document path %@",newDocuentPath);
//
////    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
////    NSLog(@"read file path: %@",filePath);
//
//    NSString *newFilePath = [newDocuentPath stringByAppendingPathComponent:fileName];
//    NSLog(@"new file path %@",newFilePath);
//
//    ///FolderLockAdvanced/Miscellaneous/
//    //encs/manager/
////    NSString* content = [NSString stringWithContentsOfFile:filePath
////                                                  encoding:NSUTF8StringEncoding
////                                                     error:NULL];
//
//
//    NSString* content = [NSString stringWithContentsOfFile:newFilePath
//                                                  encoding:NSUTF8StringEncoding
//                                                     error:NULL];
//
//    ///Users/macbookpro/Desktop/Project iOS/FolderLock/Free/encs/manager/
//    ///
//    ///
//    ///

    NSString *documentsPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentsPath = [self getRootPath];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    
        NSString* content = [NSString stringWithContentsOfFile:filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
    NSLog(@"file path: %@",filePath);
    NSLog(@"contents: %@", content);
    if (content == NULL) {
        content = @"";
    }
    
    return content;
}

-(bool)writeFile:(NSString*)fileName andFileContent:(NSString*)fileContent {
    if (fileContent == NULL) {
        return false;
    }
    
    NSLog(@"IN write file method");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentsPath = [self getRootPath];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSLog(@"write file path: %@",filePath);
    NSError *err;
    BOOL b = [fileContent writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:&err];
    if(b){
        NSLog(@"Sucessfully write");
    }
    else{
        NSLog(@"Not writed");
    }
    return true;
}

-(NSString*)getRootPath {
    NSString *bundleRoot = d_rootDirectoryOnly;
    
    bundleRoot = [bundleRoot stringByAppendingString:d_DocumentPhoto];
    //NSArray  *paths              = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //bundleRoot = [bundleRoot stringByAppendingString:@"My Vault/"];

    NSString *strMyVaultLocalPath = [self createNewFolderAtLocation:bundleRoot WithFolderName:@"info"];
    return strMyVaultLocalPath;
}

- (NSString*)createNewFolderAtLocation:(NSString *)aLocAddress
                  WithFolderName:(NSString *)aFolderName{
    NSString *path = [aLocAddress stringByAppendingString:aFolderName];
  // Check if the directory already exists
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    // Directory does not exist so create it
    NSError* error = nil;
   BOOL bDirCreated = [[NSFileManager defaultManager] createDirectoryAtPath:path
                  withIntermediateDirectories:YES
                           attributes:nil
                            error:&error];
    if (error != nil)
      return nil;
    
    return path;
        
  }
  return path;
}

@end
