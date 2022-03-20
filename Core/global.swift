//
//  global.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

#if DEBUG
public let isDebugBuild = true
#else
public let isDebugBuild = false
#endif

public struct Global {
    // yl?? 1.这个返回String等方法应该是一个闭包，它的完整写法是什么样的？ 答:初始化对象时写成闭包形式，以便在代码块中写更多的代码
    // 如下写法可以成功
//    var test:String = {() ->String in
//        return "ss"
//    }()

    // yl 2.DuckDuckGoGroupIdentifierPrefix 关联 info.plist的 GROUP_ID_PREFIX 关联 Configuration/ExternalDeveloper.xcconfig 的属性。最终返回 com.yl2
    public static let groupIdPrefix: String = {
        let groupIdPrefixKey = "DuckDuckGoGroupIdentifierPrefix"
        guard let groupIdPrefix = Bundle.main.object(forInfoDictionaryKey: groupIdPrefixKey) as? String else {
            fatalError("Info.plist must contain a \"\(groupIdPrefixKey)\" entry with a string value")
        }
        return groupIdPrefix
    }()
}

/// Allows Bundle.for() calls to be made without comprising encapsulation
public class CoreModule { }

extension Bundle {
    
    public static var core: Bundle {
        return Bundle(for: CoreModule.self)
    }
    
}
