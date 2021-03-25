// RNMarketingCloudSdk.m
//
// Copyright (c) 2019 Salesforce, Inc
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer. Redistributions in binary
// form must reproduce the above copyright notice, this list of conditions and
// the following disclaimer in the documentation and/or other materials
// provided with the distribution. Neither the name of the nor the names of
// its contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RNMarketingCloudSdk.h"
#import <MarketingCloudSDK/MarketingCloudSDK.h>

const int LOG_LENGTH = 800;

@implementation RNMarketingCloudSdk

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (void)log:(NSString *)msg {
    if (@available(iOS 10, *)) {
        if (self.logger == nil) {
            self.logger = os_log_create("com.salesforce.marketingcloudsdk", "ReactNative");
        }
        os_log_info(self.logger, "%@", msg);
    } else {
        NSLog(@"%@", msg);
    }
}
- (void)splitLog:(NSString *)msg {
    NSInteger length = msg.length;
    for (int i = 0; i < length; i += LOG_LENGTH) {
        NSInteger rangeLength = MIN(length - i, LOG_LENGTH);
        [self log:[msg substringWithRange:NSMakeRange((NSUInteger)i, (NSUInteger)rangeLength)]];
    }
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(isPushEnabled
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    BOOL status = [[MarketingCloudSDK sharedInstance] sfmc_pushEnabled];
    resolve(@(status));
}

RCT_EXPORT_METHOD(enablePush) { [[MarketingCloudSDK sharedInstance] sfmc_setPushEnabled:YES]; }

RCT_EXPORT_METHOD(disablePush) { [[MarketingCloudSDK sharedInstance] sfmc_setPushEnabled:NO]; }

RCT_EXPORT_METHOD(getSystemToken
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    NSString *deviceToken = [[MarketingCloudSDK sharedInstance] sfmc_deviceToken];
    resolve(deviceToken);
}

RCT_EXPORT_METHOD(setContactKey : (NSString *_Nonnull)contactKey) {
    [[MarketingCloudSDK sharedInstance] sfmc_setContactKey:contactKey];
}

RCT_EXPORT_METHOD(getContactKey
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    NSString *contactKey = [[MarketingCloudSDK sharedInstance] sfmc_contactKey];
    resolve(contactKey);
}

RCT_EXPORT_METHOD(addTag : (NSString *_Nonnull)tag) {
    [[MarketingCloudSDK sharedInstance] sfmc_addTag:tag];
}

RCT_EXPORT_METHOD(removeTag : (NSString *_Nonnull)tag) {
    [[MarketingCloudSDK sharedInstance] sfmc_removeTag:tag];
}

RCT_EXPORT_METHOD(getTags
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    NSSet *tags = [[MarketingCloudSDK sharedInstance] sfmc_tags];
    NSArray *arr = [tags allObjects];
    resolve(arr);
}

RCT_EXPORT_METHOD(setAttribute : (NSString *_Nonnull)name value : (NSString *_Nonnull)value) {
    [[MarketingCloudSDK sharedInstance] sfmc_setAttributeNamed:name value:value];
}

RCT_EXPORT_METHOD(clearAttribute : (NSString *_Nonnull)name) {
    [[MarketingCloudSDK sharedInstance] sfmc_clearAttributeNamed:name];
}

RCT_EXPORT_METHOD(getAttributes
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    NSDictionary *attributes = [[MarketingCloudSDK sharedInstance] sfmc_attributes];
    resolve((attributes != nil) ? attributes : @[]);
}

RCT_EXPORT_METHOD(enableVerboseLogging) {
    [[MarketingCloudSDK sharedInstance] sfmc_setDebugLoggingEnabled:YES];
}

RCT_EXPORT_METHOD(disableVerboseLogging) {
    [[MarketingCloudSDK sharedInstance] sfmc_setDebugLoggingEnabled:NO];
}

RCT_EXPORT_METHOD(logSdkState) {
    [self splitLog:[[MarketingCloudSDK sharedInstance] sfmc_getSDKState]];
}

RCT_EXPORT_METHOD(startWatchingLocation) {
  [[MarketingCloudSDK sharedInstance] sfmc_startWatchingLocation];
}

RCT_EXPORT_METHOD(stopWatchingLocation) {
  [[MarketingCloudSDK sharedInstance] sfmc_stopWatchingLocation];
}

RCT_EXPORT_METHOD(isWatchingLocation:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    resolve(@([[MarketingCloudSDK sharedInstance] sfmc_watchingLocation]));
}

RCT_EXPORT_METHOD(getInboxMessages
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {

    NSArray *arrMessages = [[MarketingCloudSDK sharedInstance] sfmc_getAllMessages];
    NSMutableArray *arrTransformedMessages = [NSMutableArray new];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"E MMM dd ',' yyyy 'at' hh:mm:ss a";

    for (NSDictionary *objDic in arrMessages) {

        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setDictionary:objDic];

        if([[dic objectForKey:@"sendDateUtc"] isKindOfClass:[NSDate class]]) {
            NSString *result = [dateFormatter stringFromDate:[dic objectForKey:@"sendDateUtc"]];
            [dic setObject:result forKey:@"sendDateUtc"];
        }

        if([[dic objectForKey:@"endDateUtc"] isKindOfClass:[NSDate class]]) {
            NSString *result = [dateFormatter stringFromDate:[dic objectForKey:@"endDateUtc"]];
            [dic setObject:result forKey:@"endDateUtc"];
        }

        if([[dic objectForKey:@"startDateUtc"] isKindOfClass:[NSDate class]]) {
            NSString *result = [dateFormatter stringFromDate:[dic objectForKey:@"startDateUtc"]];
            [dic setObject:result forKey:@"startDateUtc"];
        }

        NSArray *keys = [dic objectForKey:@"keys"];
        [dic removeObjectForKey:@"keys"];
        NSMutableDictionary *dicForKeys = [NSMutableDictionary new];
        for (NSDictionary *keyValue in keys) {
            [dicForKeys setObject:[keyValue objectForKey:@"value"] forKey:[keyValue objectForKey:@"key"]];
        }
        if(dicForKeys.count) {
            [dic setObject:dicForKeys forKey:@"keys"];
        }
        [arrTransformedMessages addObject:dic];
    }
       if(arrTransformedMessages.count > 0) {
       resolve(arrTransformedMessages);
       }
       else {
       resolve(@[]);
       }
}

RCT_EXPORT_METHOD(refreshMessages
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    resolve(@([[MarketingCloudSDK sharedInstance] sfmc_refreshMessages]));
}


RCT_EXPORT_METHOD(markAllMessagesRead
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {

    BOOL status =[[MarketingCloudSDK sharedInstance] sfmc_markAllMessagesRead];
    resolve(@(status));
}

RCT_EXPORT_METHOD(getMessageCount
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {

    NSInteger totalCount = [[MarketingCloudSDK sharedInstance] sfmc_getAllMessagesCount];
    resolve(@(totalCount));
}

RCT_EXPORT_METHOD(getReadMessageCount
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {

    NSInteger totalCount = [[MarketingCloudSDK sharedInstance] sfmc_getReadMessagesCount];
    resolve(@(totalCount));
}

RCT_EXPORT_METHOD(getUnreadMessageCount
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {

    NSInteger totalCount = [[MarketingCloudSDK sharedInstance] sfmc_getUnreadMessagesCount];
    resolve(@(totalCount));
}

@end
