//
//  AppDelegate.swift
//  Surprise
//
//  Created by Daniel Honies on 26.04.16.
//  Copyright © 2016 Daniel Honies. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    struct Source {
        var name: String
        var ref: String
        var bind: String
    }
    @IBOutlet weak var window: NSWindow!
    var sources: [Source] = []
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            let menu = NSMenu()
            sources.append(Source(name: "Buildings", ref: "https://source.unsplash.com/category/buildings/2880x1800", bind: "b"))
            sources.append(Source(name: "Nature", ref: "https://source.unsplash.com/category/nature/2880x1800", bind: "n"))
            sources.append(Source(name: "Technology", ref: "https://source.unsplash.com/category/technology/2880x1800", bind: "t"))
            for s in sources{
                menu.addItem(NSMenuItem(title: s.name, action: #selector(AppDelegate.setPicture(_:)), keyEquivalent: s.bind))
            }
            menu.addItem(NSMenuItem.separatorItem())
            menu.addItem(NSMenuItem(title: "Quit Surprise", action: Selector("terminate:"), keyEquivalent: "q"))
            statusItem.menu = menu
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    func setPicture(sender: AnyObject) {
        let myURLstring = sources[statusItem.menu!.indexOfItem(sender as! NSMenuItem)].ref
        let url = NSURL(string: myURLstring)
        if let screen = NSScreen.mainScreen()  {
            downloadImage(url!, screen: screen)
        }
    }
    
    func reset(){
        let task = NSTask()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c",
                          "killall Dock"]
        task.launch()
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, screen: NSScreen){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                
                do{
                    let homeDirectory = NSHomeDirectory()
                    let dataPath = NSURL(fileURLWithPath: homeDirectory).URLByAppendingPathComponent("Surprise")
                    
                    do {
                        try NSFileManager.defaultManager().createDirectoryAtPath(dataPath.path!, withIntermediateDirectories: true, attributes: nil)
                    } catch let error as NSError {
                        print(error.localizedDescription);
                    }
                    
                    let workspace = NSWorkspace.sharedWorkspace()
                    let path = dataPath.path! + "/" + NSUUID().UUIDString + ".jpeg"
                    print(path);
                    let fileManager = NSFileManager.defaultManager()
                    fileManager.createFileAtPath(path, contents: data, attributes: nil)
                    try workspace.setDesktopImageURL(NSURL(fileURLWithPath: path), forScreen: screen, options: [:])
                    self.reset()
                }
                catch{
                    print(error)
                }
            }
        }
    }
    
}

