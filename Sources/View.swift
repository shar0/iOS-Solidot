//
//  View.swift
//  Solidot
//
//  Created by octopus on 06/01/2018.
//  Copyright © 2018 Joe Wang. All rights reserved.
//

import UIKit
import Foundation

class DetailCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet var detailView:UIView!
    @IBOutlet var textView:UITextView!
    
    private var _detailTextHTML = ""
    var detailTextHTML:String {
        get {
            return _detailTextHTML
        }
        set {
            _detailTextHTML = newValue
            textView.attributedText = htmlToAttributedString(_detailTextHTML)
        }
    }
    
    private var _detailText = ""
    var detailText:String {
        get {
            return _detailText
        }
        set {
            _detailText = newValue
            textView.text = _detailText
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("Detail View", owner: self, options: nil)
        addSubview(detailView)
        textView.delegate = self
        detailView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.openURL(URL)
        return true
    }
    
    func htmlToAttributedString(_ string: String) -> NSAttributedString {
        guard let data = string.data(using: .utf8) else { return NSAttributedString() }
        do {
            let attr = try NSMutableAttributedString(data: data, options: [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue,
                ], documentAttributes: nil)
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8
            style.paragraphSpacing = 1.4
            let fontSize:CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 22 : 18
            
            if #available(iOS 8.2, *), UIDevice.current.userInterfaceIdiom == .pad {
                attr.addAttributes([
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize, weight: .light),
                    NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1930259168, green: 0.1930313706, blue: 0.19302845, alpha: 1),
                    NSAttributedStringKey.paragraphStyle: style
                    ], range: NSRange(location: 0, length: attr.string.count))
            } else {
                attr.addAttributes([
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
                    NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1930259168, green: 0.1930313706, blue: 0.19302845, alpha: 1),
                    NSAttributedStringKey.paragraphStyle: style
                    ], range: NSRange(location: 0, length: attr.string.count))
            }
            
            return attr
        } catch let error as NSError {
            print(error.localizedDescription)
            return NSAttributedString()
        }
    }
    
}


class DetailHeaderCell: UITableViewCell {
    
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!
    @IBOutlet var topicImageView:UIImageView!
    @IBOutlet var storyDescLabel:UILabel!
    @IBOutlet var storyContent:UIView!
    @IBOutlet var storyTitleLabel:UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("Detail Header View", owner: self, options: nil)
        addSubview(storyContent)
        storyContent.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        relocate()
    }
    
    func relocate() {
        
    }
    
}

class StoryCell: UITableViewCell {
    
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!
    @IBOutlet var topicImageView:UIImageView!
    @IBOutlet var storyDescLabel:UILabel!
    @IBOutlet var storyContent:UIView!
    @IBOutlet var storyTitleLabel:UILabel!
    @IBOutlet var storyDetailLabel:UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        
        /**
         * @TODO Lag on too much cell views
         */
        
        Bundle.main.loadNibNamed("Story Cell View", owner: self, options: nil)
        addSubview(storyContent)
        storyContent.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        relocate()
    }
    
    func relocate() {
        
    }
    
}

public class SafariActivity: UIActivity {
    public var URL: URL?
    
    public override var activityType: UIActivityType? {
        return UIActivityType(rawValue: "SafariActivity")
    }
    
    public override var activityTitle: String? {
        // load value from main bundle to enable overwriting title
        let frameworkBundle = Bundle(for: type(of: self))
        let mainBundle = Bundle.main
        let defaultString = frameworkBundle.localizedString(forKey: "open_in_safari", value: "open_in_safari", table: nil)
        return mainBundle.localizedString(forKey: "open_in_safari", value: defaultString, table: nil)
    }
    
    public override var activityImage: UIImage? {
        return #imageLiteral(resourceName: "safari")
    }
    
    public override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        var canPerform = false
        
        for activityItem in activityItems {
            if let URL = activityItem as? URL {
                if UIApplication.shared.canOpenURL(URL) {
                    canPerform = true
                    break
                }
            }
        }
        
        return canPerform
    }
    
    public override func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            if let URL = activityItem as? URL {
                self.URL = URL
                break
            }
        }
    }
    
    public override func perform() {
        var completed = false
        
        if let URL = URL {
            completed = UIApplication.shared.openURL(URL)
        }
        
        activityDidFinish(completed)
    }
}

