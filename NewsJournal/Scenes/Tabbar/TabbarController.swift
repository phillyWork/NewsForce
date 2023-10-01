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
        let newsSearchVC = NewsSearchViewController()
        newsSearchVC.tabBarItem.title = ViewControllerType.newsSearchVC.tabbarTitle
        newsSearchVC.tabBarItem.image = UIImage(systemName: ViewControllerType.newsSearchVC.tabbarItemString)
        let searchNav = UINavigationController(rootViewController: newsSearchVC)
        
        let journalVC = JournalViewController()
        journalVC.tabBarItem.title = ViewControllerType.journalVC.tabbarTitle
        journalVC.tabBarItem.image = UIImage(systemName: ViewControllerType.journalVC.tabbarItemString)
        let journalNav = UINavigationController(rootViewController: journalVC)
        
        setViewControllers([searchNav, journalNav], animated: false)
    }
    
}
