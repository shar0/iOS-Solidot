//
//  MasterController.swift
//  Solidot
//
//  Created by octopus on 05/01/2018.
//  Copyright © 2018 Joe Wang. All rights reserved.
//

import Kanna
import UIKit
import SnapKit
import SDWebImage
import Alamofire
import Reachability

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.barTintColor = #colorLiteral(red: 0.003921568627, green: 0.3254901961, blue: 0.3176470588, alpha: 1)
        navigationBar.tintColor = .white
    }
    
}

class MasterController: UITableViewController, UIViewControllerPreviewingDelegate {
    
    var reachability = Reachability()
    var lastSelected:IndexPath?
    var manager = SolidotStoryManager.shared
    var storyListObservation:NSKeyValueObservation?
    var loadingObservation:NSKeyValueObservation?
    var endedObservation:NSKeyValueObservation?
    var refreshObservation:NSKeyValueObservation?
    var detail:DetailController?
    let footerView = UIView()
    let indicator = UIActivityIndicatorView()
    var errorView = UIView()
    private var _title:String = ""
    var titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2015"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.layer.zPosition = -1
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.tintColor = .gray
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: (UIScreen.main.bounds.width - 44) / 2, y: 8, width: 44, height: 44)
        
        footerView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 60))
        footerView.addSubview(indicator)
        
        tableView.register(StoryCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsMultipleSelection = false
        tableView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = footerView
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        storyListObservation = manager.observe(\.storyList) { object, change in
            if Thread.isMainThread {
                self.update()
                self.tableView.reloadData()
            } else {
                DispatchQueue.main.async {
                    self.update()
                    self.tableView.reloadData()
                }
            }
        }
        
        refreshObservation = manager.observe(\.refresh) { object, change in
            if Thread.isMainThread {
                self.update()
            } else {
                DispatchQueue.main.async {
                    self.update()
                }
            }
        }
        
        loadingObservation = manager.observe(\.loading) { object, change in
            if object.refresh {
                return
            }
            
            if Thread.isMainThread {
                self.update()
            } else {
                DispatchQueue.main.async {
                    self.update()
                }
            }
        }
        
        setupTitleView()
        manager.restoreList()
        setupError()
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func update() {
        errorView.isHidden = (manager.storyList.count != 0)
        updateRefresh()
        updateLoader()
    }
    
    func setupError() {
        let icon = UIImageView(image: #imageLiteral(resourceName: "937-wifi-signal"))
        let label = UILabel()
        label.text = "no_data_drag_to_refresh".localized()
        label.textAlignment = .center
        icon.contentMode = .scaleAspectFit
        errorView.addSubview(icon)
        errorView.addSubview(label)
        icon.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-44)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(10)
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
        view.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.center.width.height.equalToSuperview()
        }
        errorView.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
        errorView.isHidden = true
        errorView.layer.zPosition = 999
        errorView.isUserInteractionEnabled = true
    }
    
    func updateLoader() {
        if manager.loading {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
    
    func updateRefresh() {
        if manager.refresh {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    @objc func refresh() {
        manager.fetchStories()
    }
    
    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == manager.storyList.count - 1 {
            if !manager.loading {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.manager.yesterdayIssue()
                }
            }
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if #available(iOS 9.0, *) {
            if let cell = previewingContext.sourceView as? StoryCell {
                if let indexPath = tableView.indexPath(for: cell) {
                    detail = DetailController()
                    detail?.story = manager.storyList[indexPath.row]
                    detail?.storyIndex = indexPath.row
                }
            }
        }
        return detail
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
        
        self.update()
        
        if detail != nil {
            let offsetIndexPath = IndexPath(row: detail!.storyIndex, section: 0)
            if lastSelected != nil {
                tableView.deselectRow(at: lastSelected!, animated: false)
            }
            if offsetIndexPath.row != lastSelected?.row {
                tableView.scrollToRow(at: offsetIndexPath, at: .middle, animated: false)
                lastSelected = offsetIndexPath
            }
            tableView.selectRow(at: lastSelected, animated: false, scrollPosition: .middle)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if lastSelected != nil {
            tableView.deselectRow(at: lastSelected!, animated: animated)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? StoryCell ?? StoryCell()
        let story = manager.storyList[indexPath.row]
        
        cell.storyTitleLabel.text = story.title
        
        var attrString:NSMutableAttributedString!
        if #available(iOS 8.2, *) {
            attrString = NSMutableAttributedString(string: story.detail, attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .light),
                NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1930259168, green: 0.1930313706, blue: 0.19302845, alpha: 1)
                ])
        } else {
            attrString = NSMutableAttributedString(string: story.detail, attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
                NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.1930259168, green: 0.1930313706, blue: 0.19302845, alpha: 1)
                ])
        }
        
        if #available(iOS 9.0, *) {
            if( traitCollection.forceTouchCapability == .available){
                registerForPreviewing(with: self, sourceView: cell)
            }
        }
        
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byCharWrapping
        style.lineSpacing = 4.5
        style.paragraphSpacing = 1.2
        style.lineBreakMode = .byTruncatingTail
        attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSRange(location: 0, length: story.detail.count))
        
        cell.topicImageView.sd_setImage(with: story.topicImage)
        
        if story.topicImage != nil {
            cell.imageConstraint.constant = 12
        } else {
            cell.imageConstraint.constant = -48
        }
        cell.storyDescLabel.text = String(format:"%@_dept".localized(), story.dept)
        cell.storyDetailLabel.attributedText = attrString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelected = indexPath
        
        detail = DetailController()
        detail?.story = manager.storyList[indexPath.row]
        detail?.storyIndex = indexPath.row
        navigationController?.pushViewController(detail!, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.storyList.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupTitleView() {
        titleView.frame = CGRect(x: 0, y: 0, width: 164, height: 30)
        titleView.contentMode = .scaleAspectFit
        navigationItem.titleView = UIView()
        navigationItem.titleView?.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.width.equalTo(164)
            make.height.equalTo(30)
            make.center.equalToSuperview()
        }
    }
}

class DetailController: UITableViewController, UIGestureRecognizerDelegate {
    
    var story:StoryModel!
    var storyIndex:Int = 0
    var manager = SolidotStoryManager.shared
    
    private var _title:String = ""
    public var titleView:UILabel?
    public var navigationTitle:String? {
        get {
            return _title
        }
        set {
            _title = newValue ?? ""
            titleView?.text = _title
            titleView?.sizeToFit()
        }
    }
    var storyListObservation:NSKeyValueObservation?
    var loadingObservation:NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(DetailHeaderCell.self, forCellReuseIdentifier: "headerCell")
        tableView.register(DetailCell.self, forCellReuseIdentifier: "detailCell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsMultipleSelection = false
        tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        if #available(iOS 9.0, *) {
            tableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        let backBarItem:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Icon-Back"), style: .plain, target: self, action: #selector(self.backToPrevious))
        
        navigationItem.leftBarButtonItems = [backBarItem]
        
        let frame = CGRect(x: 0, y: 0, width: 18, height: 24)
        let shareBtn = UIBarButtonItem(customView: imageBtn(image: #imageLiteral(resourceName: "702-share"), rect: frame, target: self, action: #selector(share)))
        navigationItem.rightBarButtonItem = shareBtn
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if let navigationController = navigationController {
            if navigationController.viewControllers.count > 2 {
                let closeBarItem:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Icon-Close"), style: .plain, target: self, action: #selector(self.popToRoot))
                navigationItem.leftBarButtonItems = [backBarItem, closeBarItem]
            }
        }
        
        storyListObservation = manager.observe(\.storyList) { object, change in
            if self.tableView.numberOfRows(inSection: 0) < 2 {
                return
            }
            
            if Thread.isMainThread {
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                }
            }
        }
        
        setupTitleView()
        navigationTitle = String(format:"published_in_%@".localized(), timeAgoStringFromDate(date: story.published) ?? "")
    }
    
    @objc func share() {
        if story.url != nil {
            let safari = SafariActivity()
            let activity = UIActivityViewController(activityItems: [story.url!], applicationActivities: [safari])
            activity.excludedActivityTypes = [.print]
            self.present(activity, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        storyListObservation?.invalidate()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.navigationTitle = String(format:"published_in_%@".localized(), self.timeAgoStringFromDate(date: self.story.published) ?? "")
            self.tableView.reloadSections([0], with: .automatic)
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        tableView.reloadSections([0], with: .automatic)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            return navigationController!.viewControllers.count > 1
        }
        return true
    }
    
    @objc func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func backToPrevious(){
        navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row < 2 {
            
        } else if indexPath.row == 2  {
            if let previous = manager.previous(index: storyIndex) {
                self.story = previous
                self.storyIndex += 1
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                reloadData()
            }
        } else {
            if let next = manager.next(index: storyIndex) {
                self.story = next
                self.storyIndex -= 1
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                reloadData()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            return retireCell(story, "", UIFont.systemFont(ofSize: 22))
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") as? DetailCell ?? DetailCell()
            
            if let _ = navigationController {
                cell.detailTextHTML = story.detailHTML
            } else {
                cell.detailText = story.detail
            }
            
            return cell
        } else if indexPath.row == 2  {
            if let previous = manager.previous(index: storyIndex) {
                return retireCell(previous, "prev_story_".localized(), UIFont.boldSystemFont(ofSize: 16))
            } else {
                let model = StoryModel()
                model.title = "loading".localized()
                model.dept = "from_the_robot_dept".localized()
                
                if !manager.loading {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.manager.yesterdayIssue()
                    }
                }
                
                return retireCell(model, "", UIFont.systemFont(ofSize: 18))
            }
        } else {
            if let next = manager.next(index: storyIndex) {
                return retireCell(next, "next_story_".localized(), UIFont.boldSystemFont(ofSize: 16))
            }
        }
        
        return UITableViewCell()
    }
    
    func retireCell(_ story:StoryModel, _ titlePrefix:String = "", _ font:UIFont? = nil) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as? DetailHeaderCell ?? DetailHeaderCell()
        
        if story.topicImage != nil {
            cell.imageConstraint.constant = 12
        } else {
            cell.imageConstraint.constant = -48
        }
        cell.storyTitleLabel.text = "\(titlePrefix)\(story.title)"
        cell.storyTitleLabel.font = font
        cell.topicImageView.sd_setImage(with: story.topicImage)
        cell.storyDescLabel.text = String(format:"%@_dept".localized(), story.dept)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 3
        if let _ = SolidotStoryManager.shared.next(index: storyIndex) {
            rows += 1
        }
        return rows
    }
    
    func setupTitleView() {
        titleView = UILabel()
        titleView?.text = _title
        titleView?.textAlignment = NSTextAlignment.center
        titleView?.font = UIFont.boldSystemFont(ofSize: 17.0)
        titleView?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        titleView?.sizeToFit()
        navigationItem.titleView = titleView
    }
    
    func timeAgoStringFromDate(date: Date) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        
        let now = Date()
        
        let calendar = NSCalendar.current
        let components1: Set<Calendar.Component> = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        let components = calendar.dateComponents(components1, from: date, to: now)
        
        if components.year ?? 0 > 0 {
            formatter.allowedUnits = .year
        } else if components.month ?? 0 > 0 {
            formatter.allowedUnits = .month
        } else if components.weekOfMonth ?? 0 > 0 {
            formatter.allowedUnits = .weekOfMonth
        } else if components.day ?? 0 > 0 {
            formatter.allowedUnits = .day
        } else if components.hour ?? 0 > 0 {
            formatter.allowedUnits = [.hour]
        } else if components.minute ?? 0 > 0 {
            formatter.allowedUnits = .minute
        } else {
            formatter.allowedUnits = .second
        }
        
        let formatString = NSLocalizedString("%@_ago", comment: "Used to say how much time has passed. e.g. '2 hours ago'")
        
        guard let timeString = formatter.string(for: components) else {
            return nil
        }
        return String(format: formatString, timeString)
    }
    
    func imageBtn(image:UIImage, rect:CGRect, target: Any?, action: Selector?) -> UIImageView {
        let 🖼 = UIImageView(image: image.withRenderingMode(UIImageRenderingMode.alwaysTemplate))
        let 👆 = UITapGestureRecognizer(target: target, action: action)
        👆.numberOfTapsRequired = 1
        🖼.isUserInteractionEnabled = true
        🖼.frame = rect
        🖼.addGestureRecognizer(👆)
        return 🖼
    }
}

