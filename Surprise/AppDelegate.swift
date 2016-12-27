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
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            let menu = NSMenu()
            sources.append(Source(name: "Buildings", ref: "https://source.unsplash.com/category/buildings/2880x1800", bind: "b"))
            sources.append(Source(name: "Nature", ref: "https://source.unsplash.com/category/nature/2880x1800", bind: "n"))
            sources.append(Source(name: "Technology", ref: "https://source.unsplash.com/category/technology/2880x1800", bind: "t"))
            for s in sources{
                menu.addItem(NSMenuItem(title: s.name, action: #selector(AppDelegate.setPicture(_:)), keyEquivalent: s.bind))
            }
            menu.addItem(NSMenuItem.separator())
            //menu.addItem(NSMenuItem(title: "Quit Surprise", action: #selector(NSInputServiceProvider.terminate(_:)), keyEquivalent: "q"))
            statusItem.menu = menu
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func setPicture(_ sender: AnyObject) {
        let myURLstring = sources[statusItem.menu!.index(of: sender as! NSMenuItem)].ref
        let url = URL(string: myURLstring)
        if let screen = NSScreen.main()  {
            downloadImage(url!, screen: screen)
        }
    }
    
    func reset(){
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c",
                          "killall Dock"]
        task.launch()
    }
    
    func getDataFromUrl(_ url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            completion(data, response, error as NSError?)
            return()
            }) .resume()
    }
    
    func downloadImage(_ url: URL, screen: NSScreen){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            DispatchQueue.main.async { () -> Void in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                
                do{
                    let homeDirectory = NSHomeDirectory()
                    let dataPath = URL(fileURLWithPath: homeDirectory).appendingPathComponent("Surprise")
                    
                    do {
                        try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                    } catch let error as NSError {
                        print(error.localizedDescription);
                    }
                    
                    let workspace = NSWorkspace.shared()
                    let path = dataPath.path + "/" + UUID().uuidString + ".jpeg"
                    print(path);
                    let fileManager = FileManager.default
                    fileManager.createFile(atPath: path, contents: data, attributes: nil)
                    try workspace.setDesktopImageURL(URL(fileURLWithPath: path), for: screen, options: [:])
                    self.reset()
                }
                catch{
                    print(error)
                }
            }
        }
    }
    
}

