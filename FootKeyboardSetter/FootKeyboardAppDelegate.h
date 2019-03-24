//
//  FootKeyboardAppDelegate.h
//  FootKeyboardSetter
//
//  Created by Tool Labs on 2013/03/31.
//  Revised by Tool Labs on 2016/05/08
//  Copyright 2016 Tool Labs
//

#import <Cocoa/Cocoa.h>
#import "FootKeyboard.h"

@interface FootKeyboardAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSTextField    *pnpStatus;            // USBデバイス接続ステータス   : USB device plan and play connection status
    IBOutlet NSComboBox     *keyNumber;
    IBOutlet NSButton       *shiftMode;
    IBOutlet NSPopUpButton  *keyCode;
    IBOutlet NSTextField    *keyData;
    IBOutlet NSButton       *altCommand;
    IBOutlet NSButton       *altOption;
    IBOutlet NSButton       *altShift;
    IBOutlet NSButton       *altControl;
    IBOutlet NSButton       *sendKeyDataButton;    // キーデータ送信ボタン        : Send key data button
    FootKeyboard            *footKeyboardDevice;   // フットキーボードインスタンス : FootKayboard instance
}
@property (weak) IBOutlet NSWindow *window;

// キーデータ登録セレクタ : Selector for key data registration
- (IBAction)SendKeyDataButtonPressed:(id)sender;

// メインウインドウ更新セレクタ : Selector for updating main window
- (void) UpdateAppWindow;

@end

