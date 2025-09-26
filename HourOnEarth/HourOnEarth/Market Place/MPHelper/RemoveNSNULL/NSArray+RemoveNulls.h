
#include <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSMutableArray (Custom)
- (NSMutableArray *)replaceNullsWithObject:(id)object;
@end

@interface NSMutableDictionary (Custom)
- (NSMutableDictionary *)replaceNullsWithObject:(id)object;
@end
