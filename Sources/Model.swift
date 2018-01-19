//
//  Model.swift
//  Solidot
//
//  Created by octopus on 06/01/2018.
//  Copyright © 2018 Joe Wang. All rights reserved.
//

import Foundation

enum StorySourceType:String {
    case solidot
}

class StoryModel: NSObject, NSCoding {
    var sid:Int = 0
    var title:String = ""
    var detail:String = ""
    var detailHTML:String = ""
    var url:URL?
    var image:URL?
    var topicImage:URL?
    var desc:String = ""
    var dept:String = ""
    var author:String = ""
    var published:Date = Date()
    var source:StorySourceType = .solidot
    var readed:Bool = false
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        sid = aDecoder.decodeInteger(forKey: "sid")
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        detail = aDecoder.decodeObject(forKey: "detail") as? String ?? ""
        detailHTML = aDecoder.decodeObject(forKey: "detailHTML") as? String ?? ""
        url = aDecoder.decodeObject(forKey: "url") as? URL
        image = aDecoder.decodeObject(forKey: "image") as? URL
        topicImage = aDecoder.decodeObject(forKey: "topicImage") as? URL
        desc = aDecoder.decodeObject(forKey: "desc") as? String ?? ""
        dept = aDecoder.decodeObject(forKey: "dept") as? String ?? ""
        author = aDecoder.decodeObject(forKey: "author") as? String ?? ""
        published = aDecoder.decodeObject(forKey: "published") as? Date ?? Date()
        readed = aDecoder.decodeBool(forKey: "readed")
        let sourceStr = aDecoder.decodeObject(forKey: "dept") as? String
        if sourceStr != nil {
            source = StorySourceType.init(rawValue: sourceStr!) ?? .solidot
        } else {
            source = .solidot
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sid, forKey: "sid")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(detail, forKey: "detail")
        aCoder.encode(detailHTML, forKey: "detailHTML")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(topicImage, forKey: "topicImage")
        aCoder.encode(desc, forKey: "desc")
        aCoder.encode(dept, forKey: "dept")
        aCoder.encode(author, forKey: "author")
        aCoder.encode(published, forKey: "published")
        aCoder.encode(source.rawValue, forKey: "source")
        aCoder.encode(readed, forKey: "readed")
    }
    
    override var description: String {
        get {
            return "\(sid) - \(published):\(title)"
        }
    }
}


class StoryModels: NSObject, NSCoding {
    var sid:Int = 0
    var title:String = ""
    var detail:String = ""
    var detailHTML:String = ""
    var url:URL?
    var image:URL?
    var topicImage:URL?
    var desc:String = ""
    var dept:String = ""
    var author:String = ""
    var published:Date = Date()
    var source:StorySourceType = .solidot
    var readed:Bool = false
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        sid = aDecoder.decodeInteger(forKey: "sid")
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        detail = aDecoder.decodeObject(forKey: "detail") as? String ?? ""
        detailHTML = aDecoder.decodeObject(forKey: "detailHTML") as? String ?? ""
        url = aDecoder.decodeObject(forKey: "url") as? URL
        image = aDecoder.decodeObject(forKey: "image") as? URL
        topicImage = aDecoder.decodeObject(forKey: "topicImage") as? URL
        desc = aDecoder.decodeObject(forKey: "desc") as? String ?? ""
        dept = aDecoder.decodeObject(forKey: "dept") as? String ?? ""
        author = aDecoder.decodeObject(forKey: "author") as? String ?? ""
        published = aDecoder.decodeObject(forKey: "published") as? Date ?? Date()
        readed = aDecoder.decodeBool(forKey: "readed")
        let sourceStr = aDecoder.decodeObject(forKey: "dept") as? String
        if sourceStr != nil {
            source = StorySourceType.init(rawValue: sourceStr!) ?? .solidot
        } else {
            source = .solidot
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sid, forKey: "sid")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(detail, forKey: "detail")
        aCoder.encode(detailHTML, forKey: "detailHTML")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(topicImage, forKey: "topicImage")
        aCoder.encode(desc, forKey: "desc")
        aCoder.encode(dept, forKey: "dept")
        aCoder.encode(author, forKey: "author")
        aCoder.encode(published, forKey: "published")
        aCoder.encode(source.rawValue, forKey: "source")
        aCoder.encode(readed, forKey: "readed")
    }
    
    override var description: String {
        get {
            return "\(sid) - \(published):\(title)"
        }
    }
}

