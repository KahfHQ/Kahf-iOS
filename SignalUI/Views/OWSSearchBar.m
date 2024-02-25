//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSSearchBar.h"
#import "Theme.h"
#import "UIView+SignalUI.h"
#import <SignalUI/SignalUI-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSSearchBar ()

@property (nonatomic) OWSSearchBarStyle currentStyle;

@end

@implementation OWSSearchBar

@synthesize searchFieldBackgroundColorOverride = _searchFieldBackgroundColorOverride;

- (instancetype)init
{
    if (self = [super init]) {
        [self ows_configure];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self ows_configure];
    }

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self ows_configure];
    }

    return self;
}

- (void)ows_configure
{
    _currentStyle = OWSSearchBarStyle_Default;

    [self ows_applyTheme];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeDidChange:)
                                                 name:ThemeDidChangeNotification
                                               object:nil];
}

- (void)ows_applyTheme
{
    [self.class applyThemeToSearchBar:self style:self.currentStyle];
}

+ (void)applyThemeToSearchBar:(UISearchBar *)searchBar
{
    [self applyThemeToSearchBar:searchBar style:OWSSearchBarStyle_Default];
}

+ (void)applyThemeToSearchBar:(UISearchBar *)searchBar style:(OWSSearchBarStyle)style
{
    OWSAssertIsOnMainThread();

    UIColor *foregroundColor = Theme.secondaryTextAndIconColor;
    searchBar.tintColor = Theme.secondaryTextAndIconColor;
    searchBar.barStyle = Theme.barStyle;
    searchBar.barTintColor = Theme.backgroundColor;
    searchBar.layer.cornerRadius = 10.0;
    // Hide searchBar border.
    // Alternatively we could hide the border by using `UISearchBarStyleMinimal`, but that causes an issue when toggling
    // from light -> dark -> light theme wherein the textField background color appears darker than it should
    // (regardless of our re-setting textfield.backgroundColor below).
    searchBar.backgroundImage = [UIImage new];

    if (Theme.isDarkThemeEnabled) {
        UIImage *clearImage = [UIImage imageNamed:@"searchbar_clear"];
        [searchBar setImage:[clearImage asTintedImageWithColor:foregroundColor]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateNormal];

        UIImage *searchImage = [UIImage imageNamed:@"searchbar_search"];
        [searchBar setImage:[searchImage asTintedImageWithColor:foregroundColor]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
    } else {
        [searchBar setImage:nil forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];

        [searchBar setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }

    UIColor *searchFieldBackgroundColor = Theme.searchFieldBackgroundColor;
    if ([searchBar isKindOfClass:[OWSSearchBar class]]
        && ((OWSSearchBar *)searchBar).searchFieldBackgroundColorOverride) {
        searchFieldBackgroundColor = ((OWSSearchBar *)searchBar).searchFieldBackgroundColorOverride;
    }

    [searchBar traverseViewHierarchyDownwardWithVisitor:^(UIView *view) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            textField.backgroundColor = UIColor.ows_gray06Color;
            textField.textColor = Theme.primaryTextColor;
            textField.keyboardAppearance = Theme.keyboardAppearance;
        }
    }];
    // Assuming you have a UISearchBar named "searchBar"
    UITextField *searchTextField = [searchBar valueForKey:@"searchField"];
    searchTextField.translatesAutoresizingMaskIntoConstraints = NO;

    // Add constraints to the text field
    [NSLayoutConstraint activateConstraints:@[
        [searchTextField.leadingAnchor constraintEqualToAnchor:searchBar.leadingAnchor constant:0.0],
        [searchTextField.trailingAnchor constraintEqualToAnchor:searchBar.trailingAnchor constant:0.0],
        [searchTextField.topAnchor constraintEqualToAnchor:searchBar.topAnchor constant:4.0],
        [searchTextField.bottomAnchor constraintEqualToAnchor:searchBar.bottomAnchor constant:-4.0],
    ]];
    
    searchTextField.clearButtonMode = UITextFieldViewModeNever;
    
    // Assuming you have a UISearchBar named "searchBar"
    UIOffset iconOffset = UIOffsetMake(12, 0); // Set the desired offset for the search icon
    [searchBar setPositionAdjustment:iconOffset forSearchBarIcon:UISearchBarIconSearch];
    
    // Assuming you have a UISearchBar named "searchBar"
    UIOffset textOffset = UIOffsetMake(9, 0); // Set the desired offset for the text
    [searchBar setSearchTextPositionAdjustment:textOffset];

}

- (void)switchToStyle:(OWSSearchBarStyle)style
{
    self.currentStyle = style;
    [self ows_applyTheme];
}

- (void)themeDidChange:(NSNotification *)notification
{
    OWSAssertIsOnMainThread();

    [self ows_applyTheme];
}

- (void)setSearchFieldBackgroundColorOverride:(nullable UIColor *)searchFieldBackgroundColorOverride
{
    OWSAssertIsOnMainThread();

    _searchFieldBackgroundColorOverride = searchFieldBackgroundColorOverride;

    [self ows_applyTheme];
}

- (nullable UIColor *)searchFieldBackgroundColorOverride
{
    OWSAssertIsOnMainThread();
    return _searchFieldBackgroundColorOverride;
}

@end

NS_ASSUME_NONNULL_END
