//
//  StatisticsLoader.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Common
import Foundation
import BrowserServicesKit
import Networking
import AdServices

public class StatisticsLoader {
    
    public typealias Completion =  (() -> Void)
    
    public static let shared = StatisticsLoader()
    
    private let statisticsStore: StatisticsStore
    private let returnUserMeasurement: ReturnUserMeasurement
    private let parser = AtbParser()
    
    init(statisticsStore: StatisticsStore = StatisticsUserDefaults(),
         returnUserMeasurement: ReturnUserMeasurement = KeychainReturnUserMeasurement()) {
        self.statisticsStore = statisticsStore
        self.returnUserMeasurement = returnUserMeasurement
    }
    
    public func load(completion: @escaping Completion = {}) {
        // This isn't the right place for this call, this is just for the proof of concept.
        // The real implementation should be called only until it succeeds, and after that stop hitting the attribution endpoint.
        if #available(iOS 14.3, *) {
            fetchAttributionData()
        }

        if statisticsStore.hasInstallStatistics {
            completion()
            return
        }
        requestInstallStatistics(completion: completion)
    }
    
    private func requestInstallStatistics(completion: @escaping Completion = {}) {
        let configuration = APIRequest.Configuration(url: .atb)
        let request = APIRequest(configuration: configuration, urlSession: .session())
        
        request.fetch { response, error in
            if let error = error {
                os_log("Initial atb request failed with error %s", log: .generalLog, type: .debug, error.localizedDescription)
                completion()
                return
            }
            
            if let data = response?.data, let atb  = try? self.parser.convert(fromJsonData: data) {
                self.requestExti(atb: atb, completion: completion)
            } else {
                completion()
            }
        }
    }
    
    private func requestExti(atb: Atb, completion: @escaping Completion = {}) {
        let installAtb = atb.version + (statisticsStore.variant ?? "")
        let url = URL.makeExtiURL(atb: installAtb)
        
        let configuration = APIRequest.Configuration(url: url)
        let request = APIRequest(configuration: configuration, urlSession: .session())
        
        request.fetch { _, error in
            if let error = error {
                os_log("Exti request failed with error %s", log: .generalLog, type: .debug, error.localizedDescription)
                completion()
                return
            }
            self.statisticsStore.installDate = Date()
            self.statisticsStore.atb = atb.version
            self.returnUserMeasurement.installCompletedWithATB(atb)
            completion()
        }
    }
    
    public func refreshSearchRetentionAtb(completion: @escaping Completion = {}) {
        guard let url = StatisticsDependentURLFactory(statisticsStore: statisticsStore).makeSearchAtbURL() else {
            requestInstallStatistics(completion: completion)
            return
        }

        let configuration = APIRequest.Configuration(url: url)
        let request = APIRequest(configuration: configuration, urlSession: .session())
        
        request.fetch { response, error in
            if let error = error {
                os_log("Search atb request failed with error %s", log: .generalLog, type: .debug, error.localizedDescription)
                completion()
                return
            }
            if let data = response?.data, let atb = try? self.parser.convert(fromJsonData: data) {
                self.statisticsStore.searchRetentionAtb = atb.version
                self.storeUpdateVersionIfPresent(atb)
            }
            completion()
        }
    }
    
    public func refreshAppRetentionAtb(completion: @escaping Completion = {}) {
        guard let url = StatisticsDependentURLFactory(statisticsStore: statisticsStore).makeAppAtbURL() else {
            requestInstallStatistics(completion: completion)
            return
        }

        let configuration = APIRequest.Configuration(url: url)
        let request = APIRequest(configuration: configuration, urlSession: .session())
        
        request.fetch { response, error in
            if let error = error {
                os_log("App atb request failed with error %s", log: .generalLog, type: .debug, error.localizedDescription)
                completion()
                return
            }
            if let data = response?.data, let atb = try? self.parser.convert(fromJsonData: data) {
                self.statisticsStore.appRetentionAtb = atb.version
                self.storeUpdateVersionIfPresent(atb)
            }
            completion()
        }
    }

    public func storeUpdateVersionIfPresent(_ atb: Atb) {
        if let updateVersion = atb.updateVersion {
            statisticsStore.atb = updateVersion
            statisticsStore.variant = nil
            returnUserMeasurement.updateStoredATB(atb)
        }
    }

}

extension StatisticsLoader {

    @available(iOS 14.3, *)
    func fetchAttributionData() {
        do {
            let token = try AAAttribution.attributionToken()
            var request = URLRequest(url: URL(string: "https://api-adservices.apple.com/api/v1/")!)
            request.httpMethod = "POST"
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            request.httpBody = token.data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let response {
                    print("AdAttribution response: \(response)")
                }

                if let error {
                    print("AdAttribution error: \(error)")
                }

                if let data {
                    let decoder = JSONDecoder()

                    do {
                        let decoded = try decoder.decode(AdServicesAttributionResponse.self, from: data)
                        print("AdAttribution decoded response: \(decoded)")
                    } catch {
                        print("AdAttribution failed to decode attribution response with error: \(error)")
                    }
                }
            }

            task.resume()
        } catch {
            print("AdAttribution failed to get token with error: \(error)")
        }
    }

    struct AdServicesAttributionResponse: Decodable {
        let attribution: Bool
        let orgId: Int
        let campaignId: Int
        let conversionType: String
        let adGroupId: Int
        let countryOrRegion: String
        let keywordId: Int
        let adId: Int
     }

}
