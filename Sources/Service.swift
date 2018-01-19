//
//  Service.swift
//  Solidot
//
//  Created by octopus on 05/01/2018.
//  Copyright © 2018 Joe Wang. All rights reserved.
//

import Kanna
import SwiftyJSON
import Foundation
import Alamofire

class BaseService {
    
    internal init() {}
    
    func requestString(
        _ url: URLConvertible,
        method: HTTPMethod = .post,
        params: Parameters = [:],
        headers: HTTPHeaders = [:],
        completion: @escaping (String) -> Void,
        errorHandler: @escaping (Error) -> Void)
        -> DataRequest
    {
        if Thread.isMainThread {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
        
        let request = Alamofire.request(
            url, method: method,
            parameters: params,
            encoding: URLEncoding.default,
            headers: headers)
        
        request.validate().responseString { response in
            if Thread.isMainThread {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            switch response.result {
            case .success:
                completion(response.result.value ?? "")
            case .failure(let error):
                errorHandler(error)
            }
        }
        
        return request
    }
}

class SolidotService: BaseService {
    
    let urlBase = "https://www.solidot.org"
    var request:Request?
    
    static let shared = SolidotService()
    
    override private init() {}
    
    func list(_ date:String?,
              _ completionHandler: @escaping (_ data:[StoryModel]) -> Void,
              _ errorHandler: @escaping (_ error:Error) -> Void) {
        
        var params:Parameters = [:]
        
        if let date = date {
            params = ["issue": date]
        }
        
        if request != nil {
            request?.cancel()
            request = nil
        }
        
        request = requestString("\(urlBase)", method: .get, params: params, headers: [:], completion: { result in
            
            self.request = nil
            
            do {
                let doc = try Kanna.HTML(html: result, encoding: String.Encoding.utf8)
                var list:[StoryModel] = []
                
                for newsBlock in doc.css(".block_m") {
                    let model = StoryModel()
                    
                    let titles = newsBlock.css(".ct_tittle h2 a")
                    var urlString = ""
                    if titles.count > 1 {
                        urlString = titles[1]["href"] ?? ""
                        model.title = (titles[1].text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    } else if titles.count > 0 {
                        urlString = titles[0]["href"] ?? ""
                        model.title = (titles[0].text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    
                    if urlString.range(of: "http") == nil {
                        urlString = "http://www.solidot.org\(urlString)"
                    }
                    let matches = urlString.matches(for: "/story\\?sid=[0-9]+")
                    if matches.count > 0 {
                        let number = matches[0].replacingOccurrences(of: "/story?sid=", with: "")
                        model.sid = Int(number) ?? -1
                    }
                    model.url = URL(string: urlString)
                    
                    if let img = newsBlock.at_css(".p_content .limg") {
                        model.image = URL(string: img["src"] ?? "")
                    }
                    
                    if let desc = newsBlock.at_css(".talk_time") {
                        let cleanString = desc.text?.condenseWhitespace()
                        model.desc = cleanString ?? ""
                    }
                    
                    if let dept = newsBlock.at_css(".talk_time b") {
                        let cleanString = dept.text?.condenseWhitespace()
                        model.dept = cleanString ?? ""
                    }
                    
                    if let topicImage = newsBlock.at_css(".talk_time .icon_float img") {
                        model.topicImage = URL(string: "http:" + (topicImage["src"] ?? ""))
                    }
                    
                    if let time = newsBlock.at_css(".talk_time") {
                        let cleanString = time.text?.condenseWhitespace()
                        if let matches = cleanString?.matches(for: "[0-9]+年[0-9]+月[0-9]+日 [0-9]+时[0-9]+分") {
                            if matches.count > 0 {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy年MM月dd日 HH时mm分"
                                model.published = dateFormatter.date(from: matches[0]) ?? Date()
                            }
                        }
                    }
                    
                    if let detail = newsBlock.at_css(".p_content .p_mainnew") {
                        model.detail = (detail.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                        model.detailHTML = (detail.innerHTML ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    model.source = .solidot
                    
                    list.append(model)
                }
                
                completionHandler(list)
            } catch {
                errorHandler(error)
            }
        }) { error in
            self.request = nil
            errorHandler(error)
        }
    }
    
}
