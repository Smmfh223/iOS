//
//  SwipeTabsCoordinator.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

// TODO handle new tab

// TODO handle iPad

// TODO slide the logo when in homescreen view?

// TOD save preview when start dragging

class SwipeTabsCoordinator: NSObject {
    
    // Set by refresh function
    weak var tabsModel: TabsModel!
    
    weak var coordinator: MainViewCoordinator!
    weak var tabPreviewsSource: TabPreviewsSource!
    
    let selectTab: (Int) -> Void

    init(coordinator: MainViewCoordinator, tabPreviewsSource: TabPreviewsSource, selectTab: @escaping (Int) -> Void) {
        self.coordinator = coordinator
        self.tabPreviewsSource = tabPreviewsSource
        self.selectTab = selectTab
        
        coordinator.navigationBarContainer.register(OmniBarCell.self, forCellWithReuseIdentifier: "omnibar")
        coordinator.navigationBarContainer.isPagingEnabled = true
        
        let layout = coordinator.navigationBarContainer.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.scrollDirection = .horizontal
        layout?.itemSize = CGSize(width: coordinator.superview.frame.size.width, height: coordinator.omniBar.frame.height)
        layout?.minimumLineSpacing = 0
        layout?.minimumInteritemSpacing = 0
        layout?.scrollDirection = .horizontal
    }
    
}

// MARK: UICollectionViewDelegate
extension SwipeTabsCoordinator: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("***", #function, indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("***", #function)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("***", #function)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("***", #function, coordinator.navigationBarContainer.indexPathsForVisibleItems)
        
        let index = coordinator.navigationBarContainer.indexPathForItem(at: .init(x: coordinator.navigationBarContainer.bounds.midX,
                                                                                  y: coordinator.navigationBarContainer.bounds.midY))?.row
        assert(index != nil)
        selectTab(index ?? coordinator.navigationBarContainer.indexPathsForVisibleItems[0].row)
        
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("***", #function)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("***", #function)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        print("***", #function)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("***", #function)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("***", #function)
    }

}

// MARK: Public Interface
extension SwipeTabsCoordinator {
    
    func refresh(tabsModel: TabsModel, scrollToSelected: Bool = false) {
        let scrollToItem = self.tabsModel == nil
        
        self.tabsModel = tabsModel
        coordinator.navigationBarContainer.reloadData()
        
        if scrollToItem {
            DispatchQueue.main.async {
                self.coordinator.navigationBarContainer.scrollToItem(at: .init(row: tabsModel.currentIndex, section: 0),
                                                                     at: .centeredHorizontally, animated: false)
            }
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension SwipeTabsCoordinator: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tabsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "omnibar", for: indexPath) as? OmniBarCell else {
            fatalError("Not \(OmniBarCell.self)")
        }
        
        if tabsModel.currentIndex == indexPath.row {
            cell.omniBar = coordinator.omniBar
        } else {
            let tab = tabsModel.get(tabAt: indexPath.row)
            cell.omniBar = OmniBar.loadFromXib()
            cell.omniBar?.translatesAutoresizingMaskIntoConstraints = false
            cell.omniBar?.startBrowsing()
            cell.omniBar?.refreshText(forUrl: tab.link?.url)
            cell.omniBar?.decorate(with: ThemeManager.shared.currentTheme)
        }
        
        return cell
    }
    
}

class OmniBarCell: UICollectionViewCell {
    
    weak var omniBar: OmniBar? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            if let omniBar {
                addSubview(omniBar)
                NSLayoutConstraint.activate([
                    constrainView(omniBar, by: .leading),
                    constrainView(omniBar, by: .trailing),
                    constrainView(omniBar, by: .top),
                    constrainView(omniBar, by: .bottom),
                ])
            }
        }
    }
    
}