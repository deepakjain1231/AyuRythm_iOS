#import "NSArray+RemoveNulls.h"
#import <Foundation/Foundation.h>

@implementation NSArray (Custom)

- (NSMutableArray *)replaceNullsWithObject:(id)object
{
    NSMutableArray *tmp_array = [self mutableCopy];
    int count = tmp_array.count;
    for (int i = 0; i < count; ++i)
    {
        id tmp = [tmp_array objectAtIndex:i];
        if ([tmp isKindOfClass:[NSArray class]])
        {
            tmp = [tmp replaceNullsWithObject:object];
            [tmp_array replaceObjectAtIndex:i withObject:tmp];
        }
        else if ([tmp isKindOfClass:[NSDictionary class]])
        {
            tmp = [tmp replaceNullsWithObject:object];
            [tmp_array replaceObjectAtIndex:i withObject:tmp];
        }
        else if ([tmp isEqual:[NSNull null]])
        {
            [tmp_array replaceObjectAtIndex:i withObject:object];
        }
    }
    return tmp_array;
}

@end


@implementation NSDictionary (Custom)

- (NSMutableDictionary *)replaceNullsWithObject:(id)object
{
    NSMutableDictionary *tmp_dict = [self mutableCopy];
    for (NSString *key in [tmp_dict allKeys])
    {
        id tmp = [tmp_dict objectForKey:key];
        if ([tmp isKindOfClass:[NSArray class]])
        {
            tmp = [tmp replaceNullsWithObject:object];
            [tmp_dict setObject:tmp forKey:key];
        }
        else if ([tmp isKindOfClass:[NSDictionary class]])
        {
            tmp = [tmp replaceNullsWithObject:object];
            [tmp_dict setObject:tmp forKey:key];
        }
        else if ([tmp isEqual:[NSNull null]])
        {
            [tmp_dict setObject:object forKey:key];
        }
    }
    return tmp_dict;
}

@end
