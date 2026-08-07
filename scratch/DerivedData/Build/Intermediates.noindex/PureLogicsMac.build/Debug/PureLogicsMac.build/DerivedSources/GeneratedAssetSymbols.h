#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "Keyboard" asset catalog image resource.
static NSString * const ACImageNameKeyboard AC_SWIFT_PRIVATE = @"Keyboard";

/// The "Sign_InBackGroung" asset catalog image resource.
static NSString * const ACImageNameSignInBackGroung AC_SWIFT_PRIVATE = @"Sign_InBackGroung";

/// The "features 1 1" asset catalog image resource.
static NSString * const ACImageNameFeatures11 AC_SWIFT_PRIVATE = @"features 1 1";

/// The "ic_round-home" asset catalog image resource.
static NSString * const ACImageNameIcRoundHome AC_SWIFT_PRIVATE = @"ic_round-home";

/// The "upgrade icon 1" asset catalog image resource.
static NSString * const ACImageNameUpgradeIcon1 AC_SWIFT_PRIVATE = @"upgrade icon 1";

#undef AC_SWIFT_PRIVATE
