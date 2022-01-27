//
//  CompilePerfTest.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
@testable import Core
import WebKit
import TrackerRadarKit

class RuleListCompilationPerfTests: XCTestCase {
    
    func prepareRules(data: Data) throws -> String {
        let tds = try JSONDecoder().decode(TrackerData.self, from: data)
        let builder = ContentBlockerRulesBuilder(trackerData: tds)
        
        let rules = builder.buildRules(withExceptions: [],
                                       andTemporaryUnprotectedDomains: [],
                                       andTrackerAllowlist: [])
        print("Number of rules: \(rules.count)")
        
        let data = try JSONEncoder().encode(rules)
        return String(data: data, encoding: .utf8)!
    }

    func compile(rules: String) throws {
        
        let identifier = UUID().uuidString
        
        let compiled = expectation(description: "Rules compiled")
        
        self.startMeasuring()
        
        DispatchQueue.global(qos: .userInitiated).async {
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: identifier,
                                                                    encodedContentRuleList: rules) { result, error in
                XCTAssertNotNil(result)
                XCTAssertNil(error)
                compiled.fulfill()
                
                self.stopMeasuring()
            }
        }

        wait(for: [compiled], timeout: 30.0)
    }
    
    func testFullCompilation() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "tds", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let rules = try prepareRules(data: data)

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            try? self.compile(rules: rules)
        }
    }
    
    func test50Compilation() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "tds-50", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let rules = try prepareRules(data: data)

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            try? self.compile(rules: rules)
        }
    }
    
    func test200Compilation() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "tds-200", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let rules = try prepareRules(data: data)

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            try? self.compile(rules: rules)
        }
    }
    
    func testProcessingFull() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "tds", withExtension: "json")!
        let data = try Data(contentsOf: url)
        var rules: String?

        measure {
            rules = try? prepareRules(data: data)
            XCTAssertNotNil(rules)
        }
    }
    
    func testProcessing50() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "tds-50", withExtension: "json")!
        let data = try Data(contentsOf: url)
        var rules: String?

        measure {
            rules = try? prepareRules(data: data)
            XCTAssertNotNil(rules)
        }
    }
    
    func testProcessing200() throws {
        let url = Bundle(for: type(of: self)).url(forResource: "tds-200", withExtension: "json")!
        let data = try Data(contentsOf: url)
        var rules: String?

        measure {
            rules = try? prepareRules(data: data)
            XCTAssertNotNil(rules)
        }
    }
}
