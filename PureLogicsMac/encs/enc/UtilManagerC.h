//
//  UtilManagerC.h
//  googledriveIntegration
//
//  Created by admin on 10/6/21.
//

#ifndef UtilManagerC_h
#define UtilManagerC_h
#import <Foundation/Foundation.h>

@interface UtilManagerC : NSObject

-(id)init;
-(NSString*)readFile:(NSString*)fileName;
-(bool)writeFile:(NSString*)fileName andFileContent:(NSString*)fileContent;
@end

#endif /* UtilManagerC_h */
