//
//  FootKeyboardAppDelegate.m
//  FootKeyboardSetter
//
//  Created by Tool Labs on 2013/03/31.
//  Revised by Tool Labs on 2016/05/08
//  Copyright 2016 Tool Labs
//

#import <Cocoa/Cocoa.h>
#import "FootKeyboardAppDelegate.h"

@implementation FootKeyboardAppDelegate

// アプリケーション初期化
// Initialize the applicaton
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    // FootKeyboardインスタンス生成
    // Generate FootKeyboard instance
    footKeyboardDevice = [[FootKeyboard alloc] init];

    // メインウインドウ更新用にタイマー0.1秒でRun Loop生成
    // Create run loop with timer 0.1 second
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1
													  target:self
													selector:@selector(UpdateAppWindow)
													userInfo:NULL
													 repeats:YES];
    
    // タイマーをRun Loopに設定
    // Set timer to run loop
    [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
	[runLoop addTimer:timer forMode:NSEventTrackingRunLoopMode];
    
    // キー番号の最初の要素を選択状態にする
    // Select first item of key number combo box
    [keyNumber selectItemAtIndex:0];

    // Key Codeポップアップボタン用のNSMenu生成
    // 最後の4文字はキーコードの16進表記を丸括弧で囲む
    // Create NSMenu for Key Code Popup Button
    // Last four characters represents key code in hexa-decimal with bracket
    
    // メニューのアイテム配列
    // ---はセパレーターを意味する
    // Menu items array
    // "---" designates separator in menu
    NSArray* items = [NSArray arrayWithObjects:
                      // Alphabets
                      @"a (04)", @"b (05)", @"c (06)", @"d (07)", @"e (08)", @"f (09)", @"g (0a)", @"h (0b)",
                      @"i (0c)", @"j (0d)", @"k (0e)", @"l (0f)", @"m (10)", @"n (11)", @"o (12)", @"p (13)",
                      @"q (14)", @"r (15)", @"s (16)", @"t (17)", @"u (18)", @"v (19)", @"w (1a)", @"x (1b)",
                      @"y (1c)", @"z (1d)",
                      @"---",
                      // Numbers
                      @"1 (1e)", @"2 (1f)", @"3 (20)", @"4 (21)", @"5 (22)", @"6 (23)", @"7 (24)", @"8 (25)",
                      @"9 (26)", @"0 (27)",
                      @"---",
                      // Special Keys
                      @"return (28)", @"delete (2a)", @"tab (2b)", @"space (2c)",
                      @"delete(forward) (4c)", @"End (4d)", @"Page Up (4b)", @"Page Down (4e)",
                      @"Right Arrow (4f)", @"Left Arrow (50)", @"Down Arrow (51)", @"Up Arrow (52)",
                      @"Kana (90)", @"Eisuu (91)",
                      @"---",
                      // Special Characters
                      @"- (2d)", @"^ (2e)",@"\@ (2f)", @"\[ (30)", @"\] (31)", @"; (33)", @": (34)", @"\` (35)",
                      @", (36)", @". (37)", @"/ (38)", @"_ (87)", @"¥ (89)",
                      nil];
 
    // keyCode NSPopupButtonからメニューオブジェクト取得
    // Get menu object from keyCode NSPopupButton
    NSMenu *menu = [keyCode menu];
    
    // items配列からNSMenuItemを生成
    // Create NSMenuItem from items array
    int i = 0; // タグ番号 / Variable for tag number
    for( NSString* item in items) {
        // メニュー文字列が "---" の場合はセパレーターにする
        // Separator added when item == "---"
        if( [item isEqualToString:@"---"] ){
            [menu addItem:[NSMenuItem separatorItem]];
        } else {
        // "---"以外の場合はそのままメニュー文字列にする
        // or set item to menu as menu item
            NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:item action:nil keyEquivalent:@""];
            [mi setTag:i++];
            [menu addItem:mi];
        }
    }

    // メニューを設定する
    // Set keyCode menu
    [keyCode setMenu:menu];

    // 最初の要素を選択状態にする
    // Select first item in the menu
    [keyCode selectItemAtIndex:0];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}


#pragma mark -
#pragma mark Button Action

// キーデータ登録ボタンが押されたときのアクション
// Action when key data registration button is pressed
- (IBAction)SendKeyDataButtonPressed:(id)sender {
    [footKeyboardDevice SendKeyDataToFootKeyboard:[keyCode titleOfSelectedItem]
                                    withKeyNumber:[keyNumber indexOfSelectedItem] + 1
                                        withShift:([shiftMode state] == NSOnState) ? true : false
                                   withAltCommand:([altCommand state] == NSOnState) ? true : false
                                     withAltShift:([altShift state] == NSOnState) ? true : false
                                    withAltOption:([altOption state] == NSOnState) ? true : false
                                   withAltControl:([altControl state] == NSOnState) ? true : false];
}


#pragma mark -
#pragma mark Window Handling

// メインウインドウの更新
// Update main window
- (void)UpdateAppWindow {
    // フットキーボードが接続されている場合の処理
    // If foot keyboard connected,
	if([footKeyboardDevice isConnected] == TRUE) {
        // キーデータ登録ボタンを有効化
        // Enable set key data button
        [sendKeyDataButton setEnabled:TRUE];

		// デバイス接続ステータス表示
		// Show device connection status
        [pnpStatus setStringValue:NSLocalizedString(@"DEVICE_FOUND", @"Device Detected")];
        [pnpStatus setTextColor:[NSColor colorWithCalibratedRed:0.0f green:0.41f blue:0.27f alpha:1.0f]];
    }
    
    // フットキーボードが接続されていない場合の処理
	// If foot keyboard is not connected,
	else {
        // キーデータ登録ボタンを無効化
        // Disable set key data button
        [sendKeyDataButton setEnabled:FALSE];

        // デバイス接続ステータス表示
		// Show device connection status
		[pnpStatus setStringValue:NSLocalizedString(@"DEVICE_REMOVED", @"Device Removed")];
        [pnpStatus setTextColor:[NSColor colorWithCalibratedRed:0.83f green:0.0f blue:0.19f alpha:1.0f]];
	}
}

@end
