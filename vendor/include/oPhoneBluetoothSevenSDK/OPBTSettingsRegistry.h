//
// Created by Glenn R. Martin on 4/1/15.
// Copyright (c) 2015 Vapor Communications. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __OPBTSettingsRegistry_H_
#define __OPBTSettingsRegistry_H_

typedef NS_ENUM(NSUInteger, OPBTLogMode) {
    /** Log some diverse output from the OPBTConnectionManager */
    OPBTLogModeCentralManager = 0,
    /** Log some output from the OPBTConnectionManager (on didDetect, this is very chatty, we made it its own thing.)  */
    OPBTLogModeCentralManagerPeripheral,
    /** Log some diverse output from the OPBTPeripheral */
    OPBTLogModePeripheral
};

@interface OPBTSettingsRegistry : NSObject
/**
 * The last connected peripheral's identifier
 */
@property (nonatomic, readonly, copy) NSString* lastConnectedBluetoothDeviceIdentifier;

+ (instancetype)sharedInstance;

/**
 * A unique identifier for this device given the application scope and this framework, good for log tracking.
 */
- (NSString *)applicationFrameworkInstallationIdentifier;

/**
 * Because the framework will not automatically clear the last connected device upon its disconnection, you must do so manually.
 */
- (void)clearLastConnectedDeviceIdentifier;
@end

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Enable or Disable logging for a given mode.
 */
extern void OPBTSettingsLogSet(OPBTLogMode mode, BOOL enable);


/**
 * Get the status of logging for a given mode.
 */
extern BOOL OPBTSettingsLogEnabled(OPBTLogMode mode);

#ifdef __cplusplus
}
#endif

#endif // __OPBTSettingsRegistry_H_