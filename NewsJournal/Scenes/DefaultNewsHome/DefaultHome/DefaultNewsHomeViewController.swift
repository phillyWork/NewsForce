//
//  DefaultNewsHomeViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/13.
//

import UIKit

import Tabman
import Pageboy

final class DefaultNewsHomeViewController: TabmanViewController {
    
    //MARK: - Properties
    
    private var sourceViewControllers = [DefaultNaverNewsViewController(), DefaultMediaStackNewsViewController()]
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.dataSource = self
        
        configNav()
        configBar()
    }
    
    private func configNav() {
        navigationItem.title = ViewControllerType.defaultNewsAsHome.navBarTitle
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configBar() {
        let bar = TMBar.ButtonBar()
        
        bar.backgroundView.style = .blur(style: .regular)
        bar.scrollMode = .swipe
        bar.fadesContentEdges = true
        
        bar.layout.transitionStyle = .progressive
        bar.layout.contentMode = .intrinsic
        bar.layout.alignment = .centerDistributed
        bar.layout.interButtonSpacing = 100
        
        bar.buttons.customize { button in
            button.selectedTintColor = Constant.Color.mainRed
            button.tintColor = Constant.Color.grayForNotSelectedBookMarkedCell
        }
    
        bar.indicator.transitionStyle = .progressive
        bar.indicator.overscrollBehavior = .bounce
        bar.indicator.tintColor = Constant.Color.mainRed
        bar.indicator.weight = .light
                
        addBar(bar, dataSource: self, at: .top)
    }
    
}

//MARK: - Extension for  TMBarDataSource

extension DefaultNewsHomeViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    func numberOfViewControllers(in pageboyViewController: Pageboy.PageboyViewController) -> Int {
        return sourceViewControllers.count
    }
    
    func viewController(for pageboyViewController: Pageboy.PageboyViewController, at index: Pageboy.PageboyViewController.PageIndex) -> UIViewController? {
        return sourceViewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: Pageboy.PageboyViewController) -> Pageboy.PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
        
        switch index {
        case 0:
            let title = "국내 기사"
            return TMBarItem(title: title)
        case 1:
            let title = "해외 기사"
            return TMBarItem(title: title)
        default:
            let title = "Page \(index)"
            return TMBarItem(title: title)
        }
        
    }
    
}
