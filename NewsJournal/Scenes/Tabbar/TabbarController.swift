//
//  TabbarController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabBar()
        setupTabBarItem()
    }
    
    private func configureTabBar() {
        view.backgroundColor = Constant.Color.whiteBackground
        tabBar.isTranslucent = false
        tabBar.tintColor = Constant.Color.mainRed
    }
    
    private func setupTabBarItem() {
        let defaultNewsHomeVC = DefaultNewsHomeViewController()
        defaultNewsHomeVC.tabBarItem.title = ViewControllerType.defaultNewsAsHome.tabbarTitle
        defaultNewsHomeVC.tabBarItem.image = UIImage(systemName: ViewControllerType.defaultNewsAsHome.tabbarItemString)
        let defaultNav = UINavigationController(rootViewController: defaultNewsHomeVC)
        
        let newsSearchVC = NewsSearchViewController()
        newsSearchVC.tabBarItem.title = ViewControllerType.newsSearchWithRecentWords.tabbarTitle
        newsSearchVC.tabBarItem.image = UIImage(systemName: ViewControllerType.newsSearchWithRecentWords.tabbarItemString)
        let searchNav = UINavigationController(rootViewController: newsSearchVC)
        
        let journalVC = JournalViewController()
        journalVC.tabBarItem.title = ViewControllerType.journalWithPinnedNews.tabbarTitle
        journalVC.tabBarItem.image = UIImage(systemName: ViewControllerType.journalWithPinnedNews.tabbarItemString)
        let journalNav = UINavigationController(rootViewController: journalVC)
        
        setViewControllers([defaultNav, searchNav, journalNav], animated: false)
    }
    
}
