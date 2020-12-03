//Copyright 2020 Tradedoubler
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import Foundation

class Logger {
    static var isDebug: Bool {
        get {
            internalDebug
        }
        set {
            internalDebug = newValue
            UserDefaults.standard.setValue(newValue, forKey: Constants.debugKey)
        }
    }
    
    private static var internalDebug = UserDefaults.standard.value(forKey: Constants.debugKey) as? Bool ?? true
    
    public static func setDebug(_ flag: Bool) {
        isDebug = flag
    }
    
    public static func TDLog(_ string: String) {
        if isDebug {
            print(string)
        }
    }
    
    public static func TDErrorLog(_ error: String) {
        print("📕 Error: \(error))")
    }
}
