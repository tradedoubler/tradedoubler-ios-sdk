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

import XCTest
@testable import TradeDoublerSDK

class TradeDoublerSDKTests: XCTestCase {
    
    let tradeDoublerSdk = TDSDKInterface.shared
    let offlineHandler = TestOfflineDataHandler.mocker
    let queue = DispatchQueue(label: "testing")
    let sdk_sale = "403759"
    let sdk_app_install = "403761"
    let sdk_sale_2 = "403763"
    let sdk_lead = "403765"
    let sdk_plt_default = "51"
    let sdk_group_1 = "3408"
    let sdk_group_2 = "3168"
    let tduid = "9e84e6195e0a3ab2843e3b78425d12ac"
    let orgId = "945630"
    let secret = "123456789"
    let email = "test24588444@tradedoubler.com"
    let IDFA = "28DF02F4-63BE-401D-A60F-D7CA3999EFD4"
    
    override func setUpWithError() throws {
        tradeDoublerSdk.tduid = tduid
        tradeDoublerSdk.configure(orgId, secret)
        tradeDoublerSdk.email = email
        tradeDoublerSdk.IDFA = IDFA
        offlineHandler.lastError = nil
        UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: Constants.tduidTimestampKey)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTrackAppOpen() throws {
        let exp = expectation(description: "wait for error")
        let urlCreated = tradeDoublerSdk.trackOpenApp()
        if !urlCreated {// tracking disabled
            queue.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                if offlineHandler.requests.isEmpty && offlineHandler.lastError == nil {
                    exp.fulfill()}
            }
        } else {
            offlineHandler.exp = exp
        }
        
        wait(for: [exp], timeout: 16)
    }
    
    func testTrackAppInstall() {
        let exp = expectation(description: "wait for error")
        let urlCreated = tradeDoublerSdk.trackInstall(appInstallEventId: sdk_app_install)
        if !urlCreated {// tracking disabled or already called
            Logger.TDLog("already installed")
            queue.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                if offlineHandler.requests.isEmpty && offlineHandler.lastError == nil {
                    exp.fulfill()
                }
            }
        } else {
            Logger.TDLog("installing")
            offlineHandler.exp = exp
        }
        wait(for: [exp], timeout: 16)
    }
    
    func testTrackLead() {
        let exp = expectation(description: "wait for error")
        let urlCreated = tradeDoublerSdk.trackLead(eventId: sdk_lead, leadId: "422")
        if !urlCreated {// tracking disabled or already called
            queue.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                if offlineHandler.requests.isEmpty && offlineHandler.lastError == nil {
                    exp.fulfill()}
            }
        } else {
            offlineHandler.exp = exp
        }
        wait(for: [exp], timeout: 16)
    }
    
    func testTrackSale() {
        let exp = expectation(description: "wait for error")
        let reportInfo = ReportInfo(entries: [ReportEntry(id: "\(2432)", productName: "iOSCar", price: 7331.15, quantity: 2),
                                              ReportEntry(id: "\(7334)", productName: "tea", price: 3.14, quantity: 1)
        ])
        let urlCreated = tradeDoublerSdk.trackSale(eventId: sdk_sale, orderNumber: "2048", orderValue: reportInfo.orderValue, currency: "EUR", voucherCode: "test-voucher", reportInfo: reportInfo)
        if !urlCreated {
            queue.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                if offlineHandler.requests.isEmpty && offlineHandler.lastError == nil {
                    exp.fulfill()}
            }
        } else {
            offlineHandler.exp = exp
        }
        wait(for: [exp], timeout: 16)
    }
    
    func testTrackSalePlt() {
        let exp = expectation(description: "wait for error")
        let entry1 = BasketEntry(group: sdk_group_1, id: "0BlV", productName: "iOSCar", price: 7331.15, quantity: 2)
        let entry2 = BasketEntry(group: sdk_group_2, id: "CDA14", productName: "tea", price: 3.14, quantity: 1)
        let urlCreated = tradeDoublerSdk.trackSalePlt(orderNumber: "1024", currency: "USD", voucherCode: "test-voucher", basketInfo: BasketInfo.init(entries: [entry1, entry2]))
        if !urlCreated {
            queue.asyncAfter(deadline: DispatchTime.now() + 0.5) { [self] in
                if offlineHandler.requests.isEmpty && offlineHandler.lastError == nil {
                    exp.fulfill()}
            }
        } else {
            offlineHandler.exp = exp
        }
        wait(for: [exp], timeout: 16)
    }
    
    func testWhenTduidExpireTimeNotPassedTduidIsValid() {
        UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: Constants.tduidTimestampKey)
        XCTAssertNotNil(tradeDoublerSdk.tduid)
    }
    
    func testWhenTduidExpireTimePassedTduidIsNotValid() {
        UserDefaults.standard.setValue(0, forKey: Constants.tduidTimestampKey)
        XCTAssertNil(tradeDoublerSdk.tduid)
    }
    
}

class TestOfflineDataHandler: OfflineDataHandler {
    static var mocker: TestOfflineDataHandler {
        get {
            if let casted = shared as? TestOfflineDataHandler {
                return casted
            }
            object_setClass(shared, TestOfflineDataHandler.self)
            let casted = shared as! TestOfflineDataHandler
            casted.exp = nil
            return casted
        }
    }
    
    weak var exp: XCTestExpectation?
    
    override func readRequest() {
        super.readRequest()
        if requests.isEmpty && !processing && lastError == nil && exp != nil {
            exp?.fulfill()
            exp = nil
        }
    }
    
    override func requestFailed(_ error: Error, url: URL) {
        XCTAssert(false)
    }
    
    override func performRedirect(_ redirectUrl: URL) {
        super.performRedirect(redirectUrl)
    }
    
}
