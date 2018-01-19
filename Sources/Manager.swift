//
//  Manager.swift
//  Solidot
//
//  Created by octopus on 06/01/2018.
//  Copyright © 2018 Joe Wang. All rights reserved.
//

import Foundation

class SolidotStoryManager:NSObject {
    
    static let shared = SolidotStoryManager()
    @objc dynamic var storyList:[StoryModel] = []
    @objc dynamic var loading = false
    @objc dynamic var ended = false
    @objc dynamic var refresh = false
    public var issueDate:Date?
    
    private var listFilePath:String {
        get {
            let manager = FileManager.default
            let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
            return url!.appendingPathComponent("Data/CachedStoryList.v1.data").path
        }
    }
    
    override private init() {
        super.init()
    }
    
    func fetchStories( _ date:Date? = nil ) {
        if refresh {
            return
        }
        
        if loading {
            return
        }
        
        var issueDate:String?
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            issueDate = formatter.string(from: date)
        } else {
            refresh = true
        }
        
        loading = true
        
        // Retire issues list
        SolidotService.shared.list(issueDate, { result in
            self.loading = false
            self.ended = (result.count == 0)
            if self.refresh {
                self.storyList = []
                self.refresh = false
            }
            self.updateList(list: result)
        }, errorHandler)
    }
    
    func yesterdayIssue() {
        if issueDate == nil {
            issueDate = Date()
        } else {
            issueDate = issueDate?.yesterday
        }
        fetchStories(issueDate)
    }
    
    func updateList(list:[StoryModel]) {
        for story in list {
            let confilicts = storyList.filter { model -> Bool in
                return model.sid == story.sid
            }
            if confilicts.count == 0 {
                storyList.append(story)
            }
        }
        
        storyList.sort { a, b -> Bool in
            return a.sid > b.sid
        }
    }
    
    func cacheList() {
        if self.storyList.count == 0 {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let max = (self.storyList.count >= 99) ? 99 : self.storyList.count - 1
            let cachedList = Array(self.storyList[..<max])
            NSKeyedArchiver.archiveRootObject(cachedList, toFile: self.listFilePath)
        }
    }
    
    func restoreList() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.storyList = NSKeyedUnarchiver.unarchiveObject(withFile: self.listFilePath) as? [StoryModel] ?? []
        }
    }
    
    func errorHandler(error: Error) {
        self.loading = false
        self.refresh = false
    }
    
    func emptyList() {
        storyList = []
    }
    
    func read(index:Int) {
        if storyList.count <= index {
            return
        }
        storyList[index].readed = true
    }
    
    func previous(index:Int) -> StoryModel? {
        if storyList.count <= index {
            return nil
        }
        return (index + 1) < storyList.count ? storyList[index + 1] : nil
    }
    
    func next(index:Int) -> StoryModel? {
        if storyList.count <= index {
            return nil
        }
        return (index > 0) ? storyList[index - 1] : nil
    }
    
}
