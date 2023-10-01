//
//  TabbarController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

final class TabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTabbar()
        setupTabbarItem()
    }
    
    private func configureTabbar() {
        view.backgroundColor = Constant.Color.background
        tabBar.isTranslucent = false
        tabBar.tintColor = Constant.Color.mainRed
    }
    
    private func setupTabbarItem() {
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
