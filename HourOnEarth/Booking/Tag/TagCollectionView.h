//
//  TagCollectionView.h
//  Pods
//
//  Created by zorro on 15/12/26.
//
//

#import <UIKit/UIKit.h>

@class TagCollectionView;

/**
 * Tags scroll direction
 */
typedef NS_ENUM(NSInteger, TagCollectionScrollDirection) {
    TagCollectionScrollDirectionVertical = 0, // Default
    TagCollectionScrollDirectionHorizontal = 1
};

/**
 * Tags alignment
 */
typedef NS_ENUM(NSInteger, TagCollectionAlignment) {
    TagCollectionAlignmentLeft = 0,                           // Default
    TagCollectionAlignmentCenter,                             // Center
    TagCollectionAlignmentRight,                              // Right
    TagCollectionAlignmentFillByExpandingSpace,               // Expand horizontal spacing and fill
    TagCollectionAlignmentFillByExpandingWidth,               // Expand width and fill
    TagCollectionAlignmentFillByExpandingWidthExceptLastLine  // Expand width and fill, except last line
};

/**
 * Tags delegate
 */
@protocol TagCollectionViewDelegate <NSObject>
@required
- (CGSize)tagCollectionView:(TagCollectionView *)tagCollectionView sizeForTagAtIndex:(NSUInteger)index;

@optional
- (BOOL)tagCollectionView:(TagCollectionView *)tagCollectionView shouldSelectTag:(UIView *)tagView atIndex:(NSUInteger)index;

- (void)tagCollectionView:(TagCollectionView *)tagCollectionView didSelectTag:(UIView *)tagView atIndex:(NSUInteger)index;

- (void)tagCollectionView:(TagCollectionView *)tagCollectionView updateContentSize:(CGSize)contentSize;
@end

/**
 * Tags dataSource
 */
@protocol TagCollectionViewDataSource <NSObject>
@required
- (NSUInteger)numberOfTagsInTagCollectionView:(TagCollectionView *)tagCollectionView;

- (UIView *)tagCollectionView:(TagCollectionView *)tagCollectionView tagViewForIndex:(NSUInteger)index;
@end

@interface TagCollectionView : UIView
@property (nonatomic, weak) id <TagCollectionViewDataSource> dataSource;
@property (nonatomic, weak) id <TagCollectionViewDelegate> delegate;

// Inside scrollView
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

// Tags scroll direction, default is vertical.
@property (nonatomic, assign) TagCollectionScrollDirection scrollDirection;

// Tags layout alignment, default is left.
@property (nonatomic, assign) TagCollectionAlignment alignment;

// Number of lines. 0 means no limit, default is 0 for vertical and 1 for horizontal.
@property (nonatomic, assign) NSUInteger numberOfLines;
// The real number of lines ignoring the numberOfLines value
@property (nonatomic, assign, readonly) NSUInteger actualNumberOfLines;

// Horizontal and vertical space between tags, default is 4.
@property (nonatomic, assign) CGFloat horizontalSpacing;
@property (nonatomic, assign) CGFloat verticalSpacing;

// Content inset, default is UIEdgeInsetsMake(2, 2, 2, 2).
@property (nonatomic, assign) UIEdgeInsets contentInset;

// The true tags content size, readonly
@property (nonatomic, assign, readonly) CGSize contentSize;

// Manual content height
// Default = NO, set will update content
@property (nonatomic, assign) BOOL manualCalculateHeight;
// Default = 0, set will update content
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;

// Scroll indicator
@property (nonatomic, assign) BOOL showsHorizontalScrollIndicator;
@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;

// Tap blank area callback
@property (nonatomic, copy) void (^onTapBlankArea)(CGPoint location);
// Tap all area callback
@property (nonatomic, copy) void (^onTapAllArea)(CGPoint location);

/**
 * Reload all tag cells
 */
- (void)reload;

/**
 * Returns the index of the tag located at the specified point.
 * If item at point is not found, returns NSNotFound.
 */
- (NSInteger)indexOfTagAt:(CGPoint)point;

@end
