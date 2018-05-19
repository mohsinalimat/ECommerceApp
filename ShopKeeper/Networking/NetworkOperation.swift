//
//  NetworkOperation.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 18/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import Foundation

class NetworkOperation: Operation{
    
    private var _executing = false
    private var _finished = false
    private var urlString = ""
    var className: ClassString
    var result: [String: Any]?
    var completion: ((_ responseType: Any? , _ result: Any?, _ error: Error?)->Void)?
    init(className: ClassString, url: String, completion: ((_ responseType: Any? , _ result: Any? , _ error: Error? )->Void)? = nil) {
        self.urlString = url
        self.className  = className
        self.completion = completion
        super.init()
    }
    
    override internal(set) var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    override internal(set) var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        self.main()
    }
    
    override func main() {
        performOperation()
    }
    
    private func performOperation() {
        //callRestAPI
        let Url = URL(string: self.urlString)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: Url!) {[weak self] (data, response, error) in
            guard let slf = self else {
                return
            }
            if let _data = data{
                let jsonObject = try? JSONSerialization.jsonObject(with: _data, options: []) as! [String: Any]
                if let dict = jsonObject{
                    slf.result = dict
                    slf.isExecuting = false
                    slf.isFinished = true
                }
            }
        }
        task.resume()
        
    }
}
