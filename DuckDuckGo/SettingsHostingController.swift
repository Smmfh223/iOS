//
//  SettingsHostingController.swift
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

import UIKit
import SwiftUI

class SettingsHostingController: UIHostingController<AnyView> {
    var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(rootView: AnyView(EmptyView()))

        viewModel.onRequestPushLegacyView = { [weak self] vc in
            self?.pushLegacyViewController(vc)
        }
        
        viewModel.onRequestPresentLegacyView = { [weak self] vc, modal in
            self?.presentLegacyViewCOntroller(vc, modal: modal)
        }

        let settingsView = SettingsView(viewModel: viewModel)
        self.rootView = AnyView(settingsView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pushLegacyViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentLegacyViewCOntroller(_ vc: UIViewController, modal: Bool = false) {
        if modal {
            vc.modalPresentationStyle = .fullScreen
        }
        navigationController?.present(vc, animated: true)
    }
}
