//
//  GeneralSection.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import SwiftUI
import UIKit

struct SettingsGeneralView: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @State var isPresentingAddWidgetView: Bool = false
    
    var body: some View {
        Section {
            // The homeRow view controller has
            // The current implementation will not work on top of the SwiftUI stack, so we need to push it via the UIKit Container
            SettingsCellView(label: "Set as Default Browser",
                             action: { viewModel.setAsDefaultBrowser() },
                             asLink: true)
            
            SettingsCellView(label: "Add App to Your Dock",
                             action: { viewModel.shouldPresentAddToDockView() },
                             asLink: true)
            
            NavigationLink(destination: WidgetEducationView(), isActive: $isPresentingAddWidgetView) {
                SettingsCellView(label: "Add Widget to Home Screen",
                                 action: { viewModel.isPresentingAddWidgetView = true })
            }
        }
        
        .onChange(of: isPresentingAddWidgetView) { newValue in
            viewModel.isPresentingAddWidgetView = newValue
        }
        

    }
 
}
