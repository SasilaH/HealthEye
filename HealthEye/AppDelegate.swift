//
//  AppDelegate.swift
//  HealthEye
//
//  Created by Sasila Hapuarachchi on 2019-09-26.
//  Copyright © 2019 Sasila Hapuarachchi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate{

    // Status Bar Setup
    var statusBar: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    // StatusBar Menu Setup
    let menu: NSMenu = NSMenu()
    let resetTimer = NSMenuItem(title: "Reset and Start", action: #selector(ResetTimer), keyEquivalent: "r")
    let statusMenuTimer = NSMenuItem(title: "MenuTimer", action: nil, keyEquivalent: "")
    
    // Timer Setup
    var timer: Timer? = nil
    var counter = 0
    var twentyTwenty = false
    
    // Icon Setup
    let emptyIcon = NSImage(named: "EmptyIcon")
    let filledIcon = NSImage(named: "FilledIcon")
    
    // Notification Setup
    func creatNotification() -> Void {
        let notification = NSUserNotification()
        notification.title = "HealthEye"
        notification.subtitle = "It's time to take a break!"
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = true
        notification.otherButtonTitle = "Not yet"
        notification.actionButtonTitle = "Okay"
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    func creatNotificationEnd() -> Void {
        let notification = NSUserNotification()
        notification.title = "HealthEye"
        notification.subtitle = "Great! Let's get back to work."
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = false
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) {
        case .actionButtonClicked:
           StartBreak()
        default:
            break;
        }
    }

    // Main Method
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // **Status Bar**
        guard let statusIcon = statusBar.button else {
            print("Not enough space for HealthEye. Try removing some Menu Bar items.")
            NSApp.terminate(nil)
            return }
     
        // **Icon Setup Cont.**
        emptyIcon?.isTemplate = true
        filledIcon?.isTemplate = true
        statusIcon.image = filledIcon
        
        // **Initial Timer Start**
        BeginTimer()
        
        
        // **StatusBar Menu**
        menu.addItem(withTitle: "Let's get some work done!", action: nil, keyEquivalent: "") // [0]
        
        menu.addItem(.separator()) // [1]
        
        menu.addItem(statusMenuTimer) // [2]
        
        menu.addItem(resetTimer) // [3]
        
        menu.addItem(.separator()) // [4]
        
        menu.addItem(withTitle: "Quit", action: #selector(QuitApp), keyEquivalent: "q") // [5]
        
        statusBar.menu = menu
        
    }
    
    // Timer Control Methods
    func BeginTimer(){
        timer = Timer.scheduledTimer(
                   timeInterval: 1,
                   target: self,
                   selector: #selector(TickUpdate),
                   userInfo: nil,
                   repeats: true
               )
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    func StopTimer() {
        counter = 0
        timer?.invalidate()
        timer = nil
    }

    
    // Selector Methods
    @objc
    func TickUpdate(_ sender: Timer) {
        guard let statusText = statusBar.button else { return }

        if (!twentyTwenty){ // Standard Timer (20 Min)

            counter += 1
            // Update based on counter
            switch counter {
            case 2:
                resetTimer.action = #selector(ResetTimer)
                NSUserNotificationCenter.default.removeAllDeliveredNotifications()
            case 10:
                NSUserNotificationCenter.default.removeAllDeliveredNotifications()
            case 1080:
                statusText.image = emptyIcon
                break
            case 1200:
                menu.item(at: 0)?.title = "Ready to take a break?"
                statusMenuTimer.title = "Start Break (Click Me)"
                statusMenuTimer.action = #selector(StartBreak)
                creatNotification()
                break
            default:
                break
            }
            // Calculate Minutes for statusMenuTimer
            if (counter < 1200){
                var minutes = 0
                if (counter < 60){
                    minutes = 20
                }else{
                    minutes = 20 - (counter/60)
                }
                statusMenuTimer.title = "\(minutes) minutes left"
            }

        }else{ // 20 Second Timer
            if (counter == 0){
                twentyTwenty = false
                creatNotificationEnd()
                StopTimer()
                ResetTimer()
            }else{
                counter -= 1
                statusMenuTimer.title = "\(counter) seconds left."
            }
        }
    }
    
    @objc
    func ResetTimer() -> Void {
        twentyTwenty = false
        statusBar.button!.image = filledIcon
        statusMenuTimer.action = nil
        menu.item(at: 0)?.title = "Let's get some work done!"
        StopTimer()
        BeginTimer()
    }
    @objc
    func StartBreak() -> Void{
        resetTimer.action = nil
        twentyTwenty = true
        statusMenuTimer.title = "\(counter) seconds left."
        statusMenuTimer.action = nil
        menu.item(at: 0)?.title = "Break Time"
        StopTimer()
        counter = 20
        BeginTimer()
    }
    @objc
    func QuitApp() -> Void{
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        NSApplication.shared.terminate(self)
    }

}

