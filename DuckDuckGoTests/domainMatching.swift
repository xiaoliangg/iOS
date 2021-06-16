//
//  domainMatching.swift
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

import XCTest
@testable import TrackerRadarKit
@testable import Core

class DomainMatching: XCTestCase {
    private var data = JsonTestDataLoader()

    func test() throws {
//        let url = AppUrls(statisticsStore: MockStatisticsStore()).trackerDataSet
//        let data = try Data(contentsOf: url)

//        do {
//            if let bundlePath = Bundle.main.path(forResource: ",
//                                                 ofType: "json"),
//                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
//                return jsonData
//            }
//        } catch {
//            print(error)
//        }

        let trackerJSON = data.fromJsonFile("MockFiles/TR_reference.json")
        let stringValue = String(decoding: trackerJSON, as: UTF8.self)
        print(stringValue)
                
        let trackerData = try JSONDecoder().decode(TrackerData.self, from: trackerJSON)
//
//        let rules = ContentBlockerRulesBuilder(trackerData: trackerData).buildRules(withExceptions: ["duckduckgo.com"],
//        andTemporaryUnprotectedDomains: [])
//
//        // Test tracker is set up to be blocked
//        if let rule = rules.findExactFilter(filter: "^(https?)?(wss?)?://([a-z0-9-]+\\.)*googleadservices\\.com(:?[0-9]+)?/.*") {
//            XCTAssert(rule.action == .block())
//        } else {
//            XCTFail("Missing google ad services rule")
//        }
//
//        // Test exceptiions are set to ignore previous rules
//        if let rule = rules.findInIfDomain(domain: "duckduckgo.com") {
//            XCTAssert(rule.action == .ignorePreviousRules())
//        } else {
//            XCTFail("Missing domain exception")
//        }
    }

}

extension Array where Element == ContentBlockerRule {
    func findExactFilter(filter: String) -> ContentBlockerRule? {
        for rule in self where rule.trigger.urlFilter == filter {
            return rule
        }
        
        return nil
    }
    
    func findInIfDomain(domain: String) -> ContentBlockerRule? {
        for rule in self {
            if let ifDomain = rule.trigger.ifDomain {
                for url in ifDomain where url == domain {
                    return rule
                }
            }
        }
        
        return nil
    }
}
