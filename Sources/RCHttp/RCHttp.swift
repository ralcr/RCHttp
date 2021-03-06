//
//  RCHttp.swift
//
//  Created by Baluta Cristian on 08/08/2014.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import Foundation

public struct RCHttpError: LocalizedError {
    public var errorDescription: String?
    public init(errorDescription: String) {
        self.errorDescription = errorDescription
    }
}

public class RCHttp {
	
    public static var loggingEnabled = true
    
    public var baseURL: URL! = nil
	private var task: URLSessionTask?
    private var base64LoginData: String?
	
    /// If baseURL is empty  it crashes
	public convenience init (baseURL: String) {
		self.init()
		self.baseURL = URL(string: baseURL)
        guard self.baseURL != nil else {
            fatalError("RCHttp: URL is invalid")
        }
    }
    
    public init() {
    }
    
    /// Add an Authorization header to each request with the user:pass encoded in base64
    public func authenticate (user: String, password: String) {
        if let loginData = "\(user):\(password)".data(using: .utf8) {
            base64LoginData = loginData.base64EncodedString()
        }
    }
    
    public func setHeader () {
        
    }
    
    /// Do a GET request
    public func get (at path: String,
                     headers: [String: String]? = nil,
                     success: @escaping (HTTPURLResponse, Data) -> Void,
                     failure: @escaping (Error) -> Void) {
        
        let fullPath = baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!
        let url = URL(string: fullPath)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Authenticate
        request = authenticate(request)
        
        // Set extra headers
        for (key, value) in headers ?? [:] {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if RCHttp.loggingEnabled {
            print("RCHttp: GET from \(url) -> \(request)")
        }
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            if RCHttp.loggingEnabled {
                print("RCHttp: GET from \(url) response: \(String(describing: response))")
            }
            guard let response = response as? HTTPURLResponse, let data = data, error == nil else {
                if RCHttp.loggingEnabled {
                    print("RCHttp: GET from \(url) -> \(error!)")
                }
                failure(error!)
                return
            }
            if RCHttp.loggingEnabled {
                print("RCHttp: GET from \(url) data: \(String(data: data, encoding: .utf8) ?? "")")
            }
            success(response, data)
        }
        task!.resume()
    }
	
	/// Do  a post request
    public func post (at path: String,
                      parameters: [String: Any]? = nil,
                      headers: [String: String]? = nil,
                      success: @escaping (HTTPURLResponse, Data) -> Void,
                      failure: @escaping (Error) -> Void) {
        
        let fullPath = baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!
        let url = URL(string: fullPath)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request = authenticate(request)
        
        if let parameters = parameters {
            let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        // Set extra headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers ?? [:] {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if RCHttp.loggingEnabled {
            print("RCHttp: POST to \(url) -> \(request)")
        }
		
		let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
		task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
			
            if RCHttp.loggingEnabled {
                print("RCHttp: POST to \(url) response: \(String(describing: response))")
            }
            guard let response = response as? HTTPURLResponse, let data = data, error == nil else {
                if RCHttp.loggingEnabled {
                    print("RCHttp: POST to \(url) -> \(error!)")
                }
                failure(error!)
                return
            }
            if RCHttp.loggingEnabled {
                print("RCHttp: POST to \(url) response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            success(response, data)
		})
		task!.resume()
	}
	
    //mark: put data sync and async
    
    public func put (at path: String,
                     parameters: [String: Any]? = nil,
                     headers: [String: String]? = nil,
                     success: @escaping (HTTPURLResponse, Data) -> Void,
                     failure: @escaping (Error) -> Void) {
        
        let fullPath = baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!
        let url = URL(string: fullPath)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request = authenticate(request)
        
        if let parameters = parameters {
            let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        // Set extra headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers ?? [:] {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if RCHttp.loggingEnabled {
            print("RCHttp: PUT to \(url) -> \(request)")
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if RCHttp.loggingEnabled {
                print("RCHttp: PUT to \(url) response: \(String(describing: response))")
            }
            guard let response = response as? HTTPURLResponse, let data = data, error == nil else {
                if RCHttp.loggingEnabled {
                    print("RCHttp: PUT to \(url) -> \(error!)")
                }
                failure(error!)
                return
            }
            if RCHttp.loggingEnabled {
                print("RCHttp: PUT to \(url) response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            success(response, data)
        })
        task!.resume()
    }
    
    public func delete (at path: String,
                        parameters: [String: Any]? = nil,
                        headers: [String: String]? = nil,
                        success: @escaping (HTTPURLResponse, Data) -> Void,
                        failure: @escaping (Error) -> Void) {
        
        let fullPath = baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!
        let url = URL(string: fullPath)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request = authenticate(request)
        
        if let parameters = parameters {
            let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        // Set extra headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers ?? [:] {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if RCHttp.loggingEnabled {
            print("RCHttp: DELETE to \(url) -> \(request)")
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if RCHttp.loggingEnabled {
                print("RCHttp: DELETE to \(url) response: \(String(describing: response))")
            }
            guard let response = response as? HTTPURLResponse, let data = data, error == nil else {
                if RCHttp.loggingEnabled {
                    print("RCHttp: DELETE to \(url) -> \(error!)")
                }
                failure(error!)
                return
            }
            if RCHttp.loggingEnabled {
                print("RCHttp: DELETE to \(url) response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            success(response, data)
        })
        task!.resume()
    }
    
	public func upload (data: Data, filename: String, completion: @escaping (NSDictionary) -> Void, error: @escaping (NSDictionary) -> Void) {
		
		let request = NSMutableURLRequest()
		request.url = baseURL
		request.httpMethod = "POST"
//		request.setValue(postLength, forHTTPHeaderField:"Content-Length")
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
//		request.HTTPBody = postData
		
		let session = URLSession( configuration: URLSessionConfiguration.ephemeral)
		task = session.uploadTask(with: request as URLRequest, from: data, completionHandler: { (data, response, error) in
			
		})
		task?.resume()
	}
	
	public func cancel() {
		task?.cancel()
	}
	
    private func authenticate (_ request: URLRequest) -> URLRequest {
        var req = request
        if let base64LoginData = self.base64LoginData {
            req.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        }
        return req
    }
}
