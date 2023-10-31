//
//  DefaultNaverNewsViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/14.
//

import UIKit

import RealmSwift

final class DefaultNaverNewsViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let indicator = UIActivityIndicatorView(style: .large)
    
    lazy private var linkPresentNaverCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewCompositionalLayout())
        view.backgroundColor = Constant.Color.whiteBackground
        return view
    }()
    
    private let defaultNaverVM = DefaultNaverNewsViewModel()
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, DTONews>!
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        defaultNaverVM.naverNewsList.bind { newNewsList in
            //hide indicator
            self.inactivateIndicator()
            //collectionView update with snapshot
            self.updateSnapshot(newNewsList)
        }
        
        defaultNaverVM.page.bind { _ in
            //새로운 query & 새로운 page로 네트워크 통신
            //or page 추가로 pagination
            self.defaultNaverVM.callRequestForNaver()
        }
        
        defaultNaverVM.errorMessage.bind { message in
            //toast
            self.showErrorToastMessage(message: message)
        }
        
        defaultNaverVM.isEmptyView.bind { value in
            if value {
                //show empty view
                self.linkPresentNaverCollectionView.setupBackgroundNoAPIResultEmptyView()
            } else {
                //not showing empty view
                self.linkPresentNaverCollectionView.restoreBackgroundFromEmptyView()
            }
        }
        
        configDiffableDataSource()
        
        //Notification 설정
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInDefaultNaver), name: .realmSavedInSearchVCSourceFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationJournalSavedObserverInDefaultNaver), name: .journalSavedInMemoVCFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationJournalSavedObserverInDefaultNaver), name: .journalSavedSourceFromNaver, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInDefaultNaver), name: .realmDeletedInSearchVCSourceFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInDefaultNaver), name: .realmDeletedInJournalVCSourceFromNaver, object: nil)
        
        //시작 시의 empty view 구성
        linkPresentNaverCollectionView.setupInitialBackgroundForDefaultNews()
        
        defaultNaverVM.callRequestForNaver()
    }
    
    override func configureViews() {
        super.configureViews()
    
        configCollectionView()
    
        view.addSubview(indicator)
        indicator.isHidden = true
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        linkPresentNaverCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configCollectionView() {
        view.addSubview(linkPresentNaverCollectionView)
        linkPresentNaverCollectionView.delegate = self
        linkPresentNaverCollectionView.prefetchDataSource = self
        linkPresentNaverCollectionView.isPrefetchingEnabled = true
        linkPresentNaverCollectionView.isPagingEnabled = true
        
        linkPresentNaverCollectionView.refreshControl = UIRefreshControl()
        linkPresentNaverCollectionView.refreshControl?.addTarget(self, action: #selector(pulledDownCollectionView), for: .valueChanged)
    }
    
    private func configDiffableDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<DefaultNaverNewsCell, DTONews> { cell, indexPath, itemIdentifier in
            cell.defaultNaverNewsCellVM.news.value = itemIdentifier
            //indexPath for update button & realm
            cell.bookMarkButton.indexPath = indexPath
            //addTarget
            cell.bookMarkButton.addTarget(self, action: #selector(self.bookmarkButtonTapped), for: .touchUpInside)
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: linkPresentNaverCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func updateSnapshot(_ newsList: [DTONews]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, DTONews>()
        snapshot.appendSections([0])
        snapshot.appendItems(newsList)
        diffableDataSource.apply(snapshot)        
    }
    
    private func setupCollectionViewCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constant.Frame.newsSearchCollectionViewItemFractionalWidth), heightDimension: .fractionalHeight(Constant.Frame.newsSearchCollectionViewItemFractionalHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constant.Frame.newsSearchCollectionViewGroupFractionalWidth), heightDimension: .fractionalHeight(Constant.Frame.newsSearchCollectionViewGroupFractionalHeight))
        var group: NSCollectionLayoutGroup
        if #available(iOS 16.0, *) {
            group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: Constant.Frame.newsSearchCollectionViewRepeatingItemCount)
        } else {
            group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: Constant.Frame.newsSearchCollectionViewRepeatingItemCount)
        }
        group.interItemSpacing = .fixed(Constant.Frame.newsSearchCollectionViewInterItemSpace)
        
        let section = NSCollectionLayoutSection(group: group)
        let edgeInsets = Constant.Frame.newsSearchCollectionViewEdgeInsets
        section.contentInsets = NSDirectionalEdgeInsets(top: edgeInsets, leading: edgeInsets, bottom: edgeInsets, trailing: edgeInsets)
        section.interGroupSpacing = Constant.Frame.newsSearchCollectionViewInterGroupSpace
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration = configuration
        
        return layout
    }
    
    //MARK: - Handlers for Notification
    
    @objc private func notificationRealmSavedObserverInDefaultNaver(notification: Notification) {
        print(#function)
        //realm 검색해서 여부 체크하기
        if let savedItem = notification.userInfo?[NotificationUserInfoName.dtoNewsToBeSavedInRealm] as? DTONews {
            let indexPaths = defaultNaverVM.checkIndexForDTONewsSavedInRealm(passedNews: savedItem)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentNaverCollectionView.cellForItem(at: indexPath) as? DefaultNaverNewsCell
                    cell?.bookMarkButton.setSelected()
                }
            }
        }
    }
    
    @objc private func notificationJournalSavedObserverInDefaultNaver(notification: Notification) {
        print(#function)
        //realm 검색해서 여부 체크하기
        if let savedItem = notification.userInfo?[NotificationUserInfoName.realmBookMarkedNewsLinkToBeSaved] as? String {
            let indexPaths = defaultNaverVM.checkIndexForBookMarkedNewsSavedInRealm(passedNewsLink: savedItem)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentNaverCollectionView.cellForItem(at: indexPath) as? DefaultNaverNewsCell
                    cell?.bookMarkButton.setSelected()
                    cell?.showJournalWrittenImage()
                }
            }
        }
    }
    
    @objc private func notificationRealmDeletedObserverInDefaultNaver(notification: Notification) {
        print(#function)
        if let deletedItemLinks = notification.userInfo?[NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted] as? [String] {
            let indexPaths = defaultNaverVM.checkDeletedBookmarkNewsInNaverNewsList(deleted: deletedItemLinks)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentNaverCollectionView.cellForItem(at: indexPath) as? DefaultNaverNewsCell
                    cell?.bookMarkButton.setUnselected()
                    cell?.hideJournalWrittenImage()
                }
            }
        }
    }
    
    //MARK: - Handlers
    
    @objc private func pulledDownCollectionView() {
        print(#function)
        
        //기존 기사 제거
        defaultNaverVM.removeCurrentDTONewsArray()
        
        //page 초기화
        defaultNaverVM.page.value = 1
        
        if !defaultNaverVM.isPageAboutToReset() {
            //page 1에서 새로 시작하기
            defaultNaverVM.page.value = 1
        } else {
            //page가 그대로 1에서 1인 경우, 따로 재검색하기
            defaultNaverVM.callRequestForNaver()
        }
                
        //refresh control 종료
        DispatchQueue.main.async {
            self.linkPresentNaverCollectionView.refreshControl?.endRefreshing()
        }
        
    }
    
    @objc private func bookmarkButtonTapped(sender: CustomBookMarkButton) {
        
        guard let indexPath = sender.indexPath, let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            defaultNaverVM.errorMessage.value = DefaultHomeViewSetupValues.notAbleToTapBookMarkButton
            return
        }
        
        guard let cell = linkPresentNaverCollectionView.cellForItem(at: indexPath) as? DefaultNaverNewsCell else {
            defaultNaverVM.errorMessage.value = DefaultHomeViewSetupValues.notAbleToTapBookMarkButton
            return
        }
        
        //realm 존재여부 확인
        if let bookmarkedNews = defaultNaverVM.checkNaverNewsExistsInRealmWithLink(news: item) {
            print("bookmarkedNews to be deleted: ", bookmarkedNews)
            //Journal 존재 여부 확인하기
            if defaultNaverVM.checkMemoExistsWithLink(bookMarked: bookmarkedNews) {
                //alert로 작동
                self.alertForRealmDeletion(title: DefaultHomeViewSetupValues.bookmarkedRealmDeletionTitle, message: DefaultHomeViewSetupValues.bookmarkedRealmDeletionMessage, bookMarked: bookmarkedNews, indexPath: indexPath)
            } else {
                //unselected로 변경: realm에서 제거
                cell.bookMarkButton.setUnselected()
                
                let links = Array(bookmarkedNews).map { $0.link }
                print("count of links: ", links.count)
                
                //Notification 먼저 주기: realm 제거되면 snapshot update 못함
                NotificationCenter.default.post(name: .realmDeletedSourceFromNaver, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: links])
            
                defaultNaverVM.removeBookMarkedNewsFromRealm(bookMarkedNews: bookmarkedNews)
            }
        } else {
            //selected로 변경: realm에 추가
            cell.bookMarkButton.setSelected()
            defaultNaverVM.saveNewsToRealm(news: item)
            
            NotificationCenter.default.post(name: .realmSavedSourceFromNaver, object: nil, userInfo: [NotificationUserInfoName.dtoNewsToBeSavedInRealm: item])
        }
        
    }
    
    private func activateIndicator() {
        self.indicator.startAnimating()
        self.indicator.isHidden = false
    }
    
    private func inactivateIndicator() {
        self.indicator.isHidden = true
        self.indicator.stopAnimating()
    }
 
    private func alertForRealmDeletion(title: String, message: String, bookMarked: Results<BookMarkedNews>, indexPath: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmToDelete = UIAlertAction(title: AlertConfirmText.deleteFromRealm, style: .default) { action in
            
            //cell UI 변경
            let cell = self.linkPresentNaverCollectionView.cellForItem(at: indexPath) as? DefaultNaverNewsCell
            cell?.bookMarkButton.setUnselected()
            cell?.hideJournalWrittenImage()
            
            let links = Array(bookMarked).map { $0.link }
            print("count of links: ", links.count)
            
            //Notification 먼저 주기: snapshot update 목적
            NotificationCenter.default.post(name: .realmDeletedSourceFromNaver, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: links])
            
            //realm에서 제거
            self.defaultNaverVM.removeBookMarkedNewsFromRealm(bookMarkedNews: bookMarked)
        }
        let cancel = UIAlertAction(title: AlertConfirmText.basicCancel, style: .destructive)
        alert.addAction(cancel)
        alert.addAction(confirmToDelete)
        present(alert, animated: true)
    }
    
    //MARK: - Deinit
    
    deinit {
        print("Deinit in DefaultNaver")
        NotificationCenter.default.removeObserver(self, name: .realmSavedInSearchVCSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedInSearchVCSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedInJournalVCSourceFromNaver, object: nil)
    }
    
}

//MARK: - Extension for CollectionView Delegate, Prefetch DataSource

extension DefaultNaverNewsViewController: UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            showAlert(title: NewsSearchSetupValues.notAvailableToTapTitle, message: NewsSearchSetupValues.notAvailableToTapMessage)
            return
        }
        
        let webVC = WebViewController()
        webVC.webVM.updateAPITypeToNaver()
        
        if let bookMarked = defaultNaverVM.checkNaverNewsExistsInRealmWithLink(news: item) {
            webVC.webVM.objectId = bookMarked.first?._id
        } else {
            webVC.webVM.news = item
        }
        
        self.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if defaultNaverVM.checkPrefetchingNeeded(indexPath.row) {
                self.defaultNaverVM.page.value += 1
            }
        }
    }
            
}
