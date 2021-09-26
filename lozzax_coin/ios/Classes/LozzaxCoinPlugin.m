#import "LozzaxCoinPlugin.h"
#import <lozzax_coin/lozzax_coin-Swift.h>
//#include "../External/android/monero/include/wallet2_api.h"

@implementation LozzaxCoinPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLozzaxCoinPlugin registerWithRegistrar:registrar];
}
@end
