//
//  DebugLogger.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public class DebugLogger {
    
    public static var shared = DebugLogger()
    
    private var logs: [String] = []
    private let queue = DispatchQueue(label: "DebugLogger queue", qos: .utility)
    private let dateFormatter = DateFormatter()
    
    init() {
        setupDateFormatter()
    }
    
    private func setupDateFormatter() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    }
    
    public func log(_ message: String = "",
             path: String = #file,
             function: String = #function) {
        let fileName = fileName(at: path)
        
        var messageComponents = ["\(fileName)", "\(function)"]
        
        if !message.isEmpty {
            messageComponents.append("|")
            messageComponents.append(message)
        }
        
        logTimestamped(messageComponents.joined(separator: " "))
    }
    
    private func logTimestamped(_ message: String) {
        let dateString = dateFormatter.string(from: Date())
        let formattedMessage = "\(dateString) \(message)"
        
        log(formattedMessage)
    }
    
    private func log(_ message: String) {
        print(message)
        
        queue.async {
            self.logs.append(message)
        }
    }
    
    private func fileName(at path: String ) -> String {
        ((path as NSString).lastPathComponent as NSString).deletingPathExtension
    }
    
    public func dump() -> String {
        logs.joined(separator: "\n")
    }
}
