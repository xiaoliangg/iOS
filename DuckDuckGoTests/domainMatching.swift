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
import Foundation

struct RefTests: Decodable {
    
    struct Test: Decodable {
        
        let name: String
        let siteURL: String
        let requestUrl: String
        let requestType: String
        let expectAction: String?
        let exceptPlatforms: [String]?
        
    }
    
    struct DomainTests: Decodable {
        
        let name: String
        let desc: String
        let tests: [Test]
        
    }
    
    let domainTests: DomainTests
}

class DomainMatching: XCTestCase {
    private var data = JsonTestDataLoader()

    func test() throws {
        let trackerJSON = data.fromJsonFile("MockFiles/TR_reference.json")
        let testJSON = data.fromJsonFile("MockFiles/domain_reference_tests.json")

        let s1 = String(decoding: trackerJSON, as: UTF8.self)
        print(s1)
        let trackerData = try JSONDecoder().decode(TrackerData.self, from: trackerJSON)
        
        let s2 = String(decoding: testJSON, as: UTF8.self)
        print(s2)
        let tests = try JSONDecoder().decode(RefTests.self, from: testJSON)

        let rules = ContentBlockerRulesBuilder(trackerData: trackerData).buildRules(withExceptions: ["duckduckgo.com"],
        andTemporaryUnprotectedDomains: [])

//        rules[0].matches(URL("https://bad.third-party.site/"), URL("https://bad.third-party.site/"), "script"))

        let testRule = "^(https?)?(wss?)?://([a-z0-9-]+\\.)*bad\\.third-party\\.site"
        let testDomain = "https://bad.third-party.site/test"
        let testURL = URL(string: "https://bad.third-party.site/test")
        let range = testDomain.range(of: testRule, options: .regularExpression)

        let rule = rules.matchURL(url: testDomain, topLevel: testURL!)
        print(rule)
        // Test tracker is set up to be blocked
//        if rule != nil {
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
    func matchURL(url: String, topLevel: URL) -> ContentBlockerRule? {
        for rule in self where url.range(of: rule.trigger.urlFilter, options: .regularExpression) != nil
            && rule.trigger.urlFilter != ".*" {
            if rule.trigger.ifDomain == nil || rule.trigger.ifDomain!.contains(topLevel.host!) {
//                if rule.trigger.unlessDomain == nil
                return rule
            }
            // ifDomain
            // unless domain
            //  resource type
        }
        
        return nil
    }

    func findExactFilter(url: String) -> ContentBlockerRule? {
        for rule in self where rule.trigger.urlFilter == url {
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
