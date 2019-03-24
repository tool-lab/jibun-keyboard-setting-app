//
//  FootKeyboard.m
//  FootKeyboardSetter
//
//  Created by Tool Labs on 2013/03/31.
//  Revised by Tool Labs on 2016/05/08
//  Copyright 2016 Tool Labs
//

#import "FootKeyboard.h"

// USB OUTバッファ定義
// USB OUT buffer definition
unsigned char USBOUTBuffer[outBufferLen];

// コールバック関数用に自分のインスタンスを格納するポインタ
// (コールバック関数の第一引数(context)はFootKeyboardAppDelegate)
// Pointer to save self instance for callback function
// (The first argument of callback function (context) is FootKeyboarAppDelegate)
void *selfInstance;

@implementation FootKeyboard
@synthesize isConnected;

#pragma mark -
#pragma mark 初期化/Initializatoin

// 初期化
// Initialization
- (id) init {
    // FootKeyboardインスタンス初期化
	// Initialize FootKeyboard instance
	if(!(self = [super init])) {
		NSLog(@"Failed to initialze FootKeyboard instance.");
		return nil;
	}
	
    // 接続ステータスをFALSEに設定
	// Set FALSE to connection status
	isConnected = FALSE;
	
    // コールバック関数用に自分のインスタンスポインタを格納
	// Save self instance pointer for callback functions
	selfInstance = (__bridge void *)(self);
	
    // HID Managerの初期化
	// Initialize HID Manager
	hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
	
    // デバイスマッチ辞書にFootKeyboardのVendor IDとProduct IDをセット
    // Set device matching dictionary with Vendor ID and Product ID
	NSMutableDictionary *deviceDictionary = [NSMutableDictionary dictionary];
	[deviceDictionary setObject:[NSNumber numberWithLong:productID]
						 forKey:[NSString stringWithCString:kIOHIDProductIDKey encoding:NSUTF8StringEncoding]];
	[deviceDictionary setObject:[NSNumber numberWithLong:vendorID]
						 forKey:[NSString stringWithCString:kIOHIDVendorIDKey encoding:NSUTF8StringEncoding]];
	IOHIDManagerSetDeviceMatching(hidManager, (__bridge CFMutableDictionaryRef)deviceDictionary);
	
    // HID Manageをオープン
	// Open HID Manager
	IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);
	
    // デバイス接続検知
	// New device detection
	[self NewDeviceDetection];
	
    return self;
}

#pragma mark -
#pragma mark デバイス検知/Device Detection

// デバイス接続検知
// New Device Detection
- (void) NewDeviceDetection {
    // デバイスを検知してデータを送るだけなので、デフォルトモードでHID Manageを設定
    // Set default mode to HID manager since we only need device detection and sending data to the Foot Keyboard
	IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

	// Vendor IDとProduct IDに一致するUSBデバイスリストを取得
    // Get current connected devices that match Vendor ID and Product ID
	NSSet *allDevices = (NSSet *)CFBridgingRelease(IOHIDManagerCopyDevices(hidManager));
	NSArray *myUSBDevices = [allDevices allObjects];

	// リストされたはじめのの1台を取得。1台のみのサポートとする
    // Get the first USB device in the list since we only support one device, not plural
    myUSBDevice = ([myUSBDevices count]) ? (__bridge IOHIDDeviceRef)[myUSBDevices objectAtIndex:0] : nil;
    
    // フットキーボードが接続されている場合
	// If the Foot Keyboard is connected,
	if(myUSBDevice) {
        // 接続ステータスをTRUEに設定
		// Set TRUE to connection status
		isConnected = TRUE;

		// デバイス取り外しのコールバック関数を登録
		// Register the callback functions to handle device removal
		IOHIDManagerRegisterDeviceRemovalCallback(hidManager, DeviceRemovedCallback, NULL);
		
        // デバイス接続検知のコールバック関数を解除
		// Unregister the callback function to handle device detection
        IOHIDManagerRegisterDeviceMatchingCallback(hidManager, NULL, NULL);
	}
    // フットキーボードが接続されていない場合
	// If the Foot Keyboard is not connected
	else {
		[self  DeviceRemoved];
	}
    
}


// デバイス取り外し検知
// Device removal detection
- (void) DeviceRemoved {
    // デバイスリストをクリアする
    // Clear the device list
	myUSBDevice = nil;

    // 接続ステータスをFALSEに設定
	// Set FALSE to connection status
	isConnected = FALSE;

	// デバイス取り外しのコールバック関数を解除
    // Unregister the callback function to handle device removal
    IOHIDManagerRegisterDeviceRemovalCallback(hidManager, NULL, NULL);

    // デバイス接続検知のコールバック関数を登録
    // Register the callback function to handle device detection
	IOHIDManagerRegisterDeviceMatchingCallback(hidManager, DeviceDetectedCallback, NULL);
}

#pragma mark -
#pragma mark データ送信/Send Data

// キー登録データをフットキーボードに送信
// Send data to the Foot Keyboard
- (void) SendKeyDataToFootKeyboard:(NSString *)selectedString
                     withKeyNumber:(unsigned char)keyNumber
                         withShift:(bool)shiftStatus
                    withAltCommand:(bool)altCommand
                      withAltShift:(bool)altShift
                     withAltOption:(bool)altOption
                    withAltControl:(bool)altControl {

    // 修飾キーデータ変数
    // Variable for modifier key code
    unsigned char modifierCode;
    
    // キー番号を算出
    // Specify Key Number
    if( shiftStatus ) {
        keyNumber = keyNumber | 0x80;
    }
    
    // キーコードの文字列を16進数に変換
    // Convert key code string to hexa-decimal
    NSString *keyCodeString;
    keyCodeString = [selectedString substringWithRange:NSMakeRange([selectedString length]-3, 2)];
    
    NSScanner* codeScanner = [NSScanner scannerWithString:keyCodeString];
    unsigned int keyCodeValue;
    [codeScanner scanHexInt: &keyCodeValue];
    
    // Modifierコードの生成
    // Generate modifier code
    modifierCode = 0x00;
    if( altCommand )    modifierCode |= 0x08;
    if( altShift )      modifierCode |= 0x02;
    if( altOption )     modifierCode |= 0x04;
    if( altControl )    modifierCode |= 0x01;
    
    // キーボードにキー割り当てデータを送信
    // Send key assign data packet to the keyboard
    USBOUTBuffer[0] = 0x01;
    USBOUTBuffer[1] = keyNumber;
    USBOUTBuffer[2] = 0x01;
    USBOUTBuffer[3] = 0x00;
    USBOUTBuffer[4] = keyCodeValue;
    USBOUTBuffer[5] = modifierCode;
    USBOUTBuffer[6] = 0x00;
    USBOUTBuffer[7] = 0x00;
    IOHIDDeviceSetReport(myUSBDevice, kIOHIDReportTypeOutput, 0, (uint8_t*)&USBOUTBuffer, outBufferLen);
}

#pragma mark -
#pragma mark コールバック関数/Callback Functions

// デバイス取り外しコールバック関数
// Device removal callback function
static void DeviceRemovedCallback(void *context, IOReturn result, void *sender, IOHIDDeviceRef device) {
	[(__bridge FootKeyboard *)selfInstance DeviceRemoved];
}

// デバイス接続検知コールバック関数
// Device detectin callback function
static void DeviceDetectedCallback(void *context, IOReturn result, void *sender, IOHIDDeviceRef device) {
	[(__bridge FootKeyboard *)selfInstance NewDeviceDetection];
}

@end
