//
//  AppDelegate.swift
//  MuteSpotifyAds
//
//  Created by Simon Meusel on 25.05.18.
//  Copyright © 2019 Simon Meusel. All rights reserved.
//

import Cocoa
import Foundation
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    let endlessPrivateSessionKey = "EndlessPrivateSession"
    let restartToSkipAdsKey = "RestartToSkipAds"
    let startSpotifyKey = "StartSpotify"
    let notificationsKey = "Notifications"
    let songLogPathKey = "SongLogPath"
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var titleMenuItem: NSMenuItem!
    @IBOutlet weak var endlessPrivateSessionCheckbox: NSMenuItem!
    @IBOutlet weak var restartToSkipAdsCheckbox: NSMenuItem!
    @IBOutlet weak var startSpotifyCheckbox: NSMenuItem!
    @IBOutlet weak var notificationsCheckbox: NSMenuItem!
    @IBOutlet weak var songLogCheckbox: NSMenuItem!
    
    var notificationsEnabled = false
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var spotifyManager: SpotifyManager?
    
    @IBAction func quit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

    @IBAction func quitWithSotify(_ sender: Any) {
        spotifyManager?.quitSpotify()
        quit(sender);
    }
    
    @IBAction func openProjectWebsite(_ sender: Any) {
        openWebsite(url: "https://github.com/MikeWLloyd/MuteSpotifyAds")
    }
    
    @IBAction func openReportBugWebsite(_ sender: Any) {
        openWebsite(url: "https://github.com/MikeWLloyd/MuteSpotifyAds/issues")
    }
    
    
    @IBAction func openLicenseWebsite(_ sender: Any) {
        openWebsite(url: "https://www.gnu.org/licenses/gpl-3.0.txt")
    }
    
    @IBAction func toggleEndlessPrivateSession(_ sender: NSMenuItem) {
        if spotifyManager!.endlessPrivateSessionEnabled {
            spotifyManager?.endlessPrivateSessionEnabled = false
            spotifyManager?.disablePrivateSession()
            sender.state = .off
        } else {
            spotifyManager?.endlessPrivateSessionEnabled = true
            spotifyManager?.enablePrivateSession()
            sender.state = .on
        }
        UserDefaults.standard.set(spotifyManager?.endlessPrivateSessionEnabled, forKey: endlessPrivateSessionKey)
    }
    
    @IBAction func toggleRestartToSkipAds(_ sender: NSMenuItem) {
        if spotifyManager!.restartToSkipAdsEnabled {
            spotifyManager?.restartToSkipAdsEnabled = false
            sender.state = .off
        } else {
            spotifyManager?.restartToSkipAdsEnabled = true
            sender.state = .on
        }
        UserDefaults.standard.set(spotifyManager?.restartToSkipAdsEnabled, forKey: restartToSkipAdsKey)
    }
    
    @IBAction func toggleNotifications(_ sender: NSMenuItem) {
        if notificationsEnabled {
            notificationsEnabled = false
            sender.state = .off
        } else {
            notificationsEnabled = true
            sender.state = .on
        }
        UserDefaults.standard.set(notificationsEnabled, forKey: notificationsKey)
    }
    
    @IBAction func toggleSpotifyStart(_ sender: NSMenuItem) {
        if spotifyManager!.startSpotify {
            spotifyManager?.startSpotify = false
            sender.state = .off
        } else {
            spotifyManager?.startSpotify = true
            sender.state = .on
        }
        UserDefaults.standard.set(spotifyManager?.startSpotify, forKey: startSpotifyKey)
    }
    
    @IBAction func toggleSongLog(_ sender: NSMenuItem) {
        if spotifyManager?.songLogPath != nil {
            spotifyManager?.songLogPath = nil
            sender.state = .off
        } else {
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["csv"]
            panel.allowsOtherFileTypes = true
            panel.canCreateDirectories = true
            panel.canSelectHiddenExtension = true
            panel.showsTagField = false
            panel.message = "The song log file will contain a entry for each song you listen.\nSelect where the .csv file should be saved on disk."
            panel.titleVisibility = .visible
            let result = panel.runModal()
            if result == .OK {
                spotifyManager?.songLogPath = panel.url?.path
                sender.state = .on
            } else {
                spotifyManager?.songLogPath = nil
            }
        }
        UserDefaults.standard.set(spotifyManager?.songLogPath, forKey: songLogPathKey)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        configureNotifications()
        
        // Defer all status bar UI setup to avoid layout recursion during
        // AppKit's initial menu bar layout pass.
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        DispatchQueue.main.async {
            self.statusItem.menu = self.statusMenu
            self.setStatusBarTitle(title: .noAd)
            self.titleMenuItem.title = self.titleMenuItem.title + " v\(version)"
        }
        
        print("MuteSpotifyAds v\(version)")
        print("macOS \(ProcessInfo.processInfo.operatingSystemVersionString))")
        
        spotifyManager = SpotifyManager(titleChangeHandler: {
            title in
            DispatchQueue.main.async {
                self.setStatusBarTitle(title: title)
            }
        })
        
        if UserDefaults.standard.bool(forKey: endlessPrivateSessionKey) {
            spotifyManager?.enablePrivateSession()
            spotifyManager?.endlessPrivateSessionEnabled = true
            endlessPrivateSessionCheckbox.state = .on
        }
        
        if UserDefaults.standard.bool(forKey: restartToSkipAdsKey) {
            spotifyManager?.restartToSkipAdsEnabled = true
            restartToSkipAdsCheckbox.state = .on
        }
        
        if UserDefaults.standard.object(forKey: startSpotifyKey) == nil {
            UserDefaults.standard.set(true, forKey: startSpotifyKey)
        }
        if UserDefaults.standard.bool(forKey: startSpotifyKey) {
            spotifyManager?.startSpotify = true
            startSpotifyCheckbox.state = .on
        }
        
        if UserDefaults.standard.object(forKey: notificationsKey) == nil {
            UserDefaults.standard.set(true, forKey: notificationsKey)
        }
        if UserDefaults.standard.bool(forKey: notificationsKey) {
            notificationsEnabled = true
            notificationsCheckbox.state = .on
        }
        
        spotifyManager?.songLogPath = UserDefaults.standard.string(forKey: songLogPathKey)
        if spotifyManager?.songLogPath != nil {
            songLogCheckbox.state = .on
        }
        
        spotifyManager?.startWatchingForFileChanges()
    }
    
    func setStatusBarTitle(title: StatusBarTitle) {
        statusItem.button?.title = title.rawValue
        
        if notificationsEnabled && title == StatusBarTitle.ad {
            sendNotificatoin(title: "Muting Spotify advertisement")
        }
    }
    
    func sendNotificatoin(title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "You can disable notifications in the status bar"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }

    func configureNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, _ in
        }
    }
    
    func openWebsite(url: String) {
        let url = URL(string: url)
        NSWorkspace.shared.open(url!)
    }
    
}

