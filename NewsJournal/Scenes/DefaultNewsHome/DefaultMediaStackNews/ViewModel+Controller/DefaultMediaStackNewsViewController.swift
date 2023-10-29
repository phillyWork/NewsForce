//
//  DefaultBingNewsViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/14.
//

import UIKit

import RealmSwift

final class DefaultMediaStackNewsViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let indicator = UIActivityIndicatorView(style: .large)
    
    lazy private var linkPresentMediaStackCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewCompositionalLayout())
        view.backgroundColor = Constant.Color.whiteBackground
        return view
    }()
    
    private let defaultMediaStackVM = DefaultMediaStackNewsViewModel()
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, DTONews>!
    
    //MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
            
        defaultMediaStackVM.mediaNewsList.bind { newNewsList in
            //hide indicator
            self.inactivateIndicator()
            //collectionView update with snapshot
            self.updateSnapshot(newNewsList)
        }
        
        defaultMediaStackVM.offset.bind { _ in
            //새로운 offset에서 검색하기
            self.defaultMediaStackVM.callRequestForMediaStack()
        }
        
        defaultMediaStackVM.apiKeyIndex.bind { _ in
            //기존 key limit 다 사용, 그 다음 key로 다시 네트워킹
            self.defaultMediaStackVM.callRequestForMediaStack()
        }
        
        defaultMediaStackVM.errorMessage.bind { message in
            //toast
            self.showErrorToastMessage(message: message)
        }
        
        defaultMediaStackVM.isEmptyView.bind { value in
            if value {
                //show empty view
                self.linkPresentMediaStackCollectionView.setupBackgroundNoAPIResultEmptyView()
            } else {
                //not showing empty view
                self.linkPresentMediaStackCollectionView.restoreBackgroundFromEmptyView()
            }
        }
        
        configDiffableDataSource()
        
        //Notification 설정
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInDefaultMediaStack), name: .journalSavedInMemoVCFromMediaStack, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInDefaultMediaStack), name: .journalSavedSourceFromMediaStack, object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInDefaultMediaStack), name: .realmDeletedInJournalVCSourceFromMediaStack, object: nil)
        
        //시작 시의 empty view 구성
        linkPresentMediaStackCollectionView.setupInitialBackgroundForDefaultNews()
        
        defaultMediaStackVM.callRequestForMediaStack()
    }
    
    override func configureViews() {
        super.configureViews()
    
        configCollectionView()
    
        view.addSubview(indicator)
        indicator.isHidden = true
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        linkPresentMediaStackCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configCollectionView() {
        view.addSubview(linkPresentMediaStackCollectionView)
        linkPresentMediaStackCollectionView.delegate = self
        linkPresentMediaStackCollectionView.prefetchDataSource = self
        linkPresentMediaStackCollectionView.isPrefetchingEnabled = true
        linkPresentMediaStackCollectionView.isPagingEnabled = true
        
        linkPresentMediaStackCollectionView.refreshControl = UIRefreshControl()
        linkPresentMediaStackCollectionView.refreshControl?.addTarget(self, action: #selector(pulledDownCollectionView), for: .valueChanged)
        
    }
    
    private func configDiffableDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<DefaultMediaStackNewsCell, DTONews> { cell, indexPath, itemIdentifier in
            cell.defaultMediaNewsCellVM.news.value = itemIdentifier
            //indexPath for update button & realm
            cell.bookMarkButton.indexPath = indexPath
            //addTarget
            cell.bookMarkButton.addTarget(self, action: #selector(self.bookmarkButtonTapped), for: .touchUpInside)
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: linkPresentMediaStackCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
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
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: Constant.Frame.newsSearchCollectionViewRepeatingItemCount)
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

    @objc private func notificationRealmSavedObserverInDefaultMediaStack(notification: Notification) {
        print(#function)
        //realm 검색해서 여부 체크하기
        if let savedItem = notification.userInfo?[NotificationUserInfoName.dtoNewsToBeSavedInRealm] as? DTONews {
            let indexPaths = defaultMediaStackVM.checkIndexForDTONewsSavedInRealm(passedNews: savedItem)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentMediaStackCollectionView.cellForItem(at: indexPath) as? DefaultMediaStackNewsCell
                    cell?.bookMarkButton.setSelected()
                }
            }
        }
    }
    
    @objc private func notificationJournalSavedObserverInDefaultMediaStack(notification: Notification) {
        print(#function)
        //realm 검색해서 여부 체크하기
        if let savedItem = notification.userInfo?[NotificationUserInfoName.realmBookMarkedNewsLinkToBeSaved] as? String {
            let indexPaths = defaultMediaStackVM.checkIndexForBookMarkedNewsSavedInRealm(passedNewsLink: savedItem)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentMediaStackCollectionView.cellForItem(at: indexPath) as? DefaultNaverNewsCell
                    cell?.bookMarkButton.setSelected()
                    cell?.showJournalWrittenImage()
                }
            }
        }
    }
    
    @objc private func notificationRealmDeletedObserverInDefaultMediaStack(notification: Notification) {
        print(#function)
        if let deletedItem = notification.userInfo?[NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted] as? [String] {
            let indexPaths = defaultMediaStackVM.checkDeletedBookmarkNewsInMediaStackNewsList(deleted: deletedItem)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentMediaStackCollectionView.cellForItem(at: indexPath) as? DefaultMediaStackNewsCell
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
        defaultMediaStackVM.removeCurrentDTONewsArray()
        
        if !defaultMediaStackVM.isOffsetAboutToReset() {
            //offset 0에서 새로 시작하기
            defaultMediaStackVM.offset.value = 0
        } else {
            //offset이 그대로 0에서 0인 경우, 따로 재검색하기
            defaultMediaStackVM.callRequestForMediaStack()
        }
        
        //refresh control 종료
        DispatchQueue.main.async {
            self.linkPresentMediaStackCollectionView.refreshControl?.endRefreshing()
        }
        
    }
    
    @objc private func bookmarkButtonTapped(sender: CustomBookMarkButton) {
        
        guard let indexPath = sender.indexPath, let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            defaultMediaStackVM.errorMessage.value = DefaultHomeViewSetupValues.notAbleToTapBookMarkButton
            return
        }
        
        guard let cell = linkPresentMediaStackCollectionView.cellForItem(at: indexPath) as? DefaultMediaStackNewsCell else {
            defaultMediaStackVM.errorMessage.value = DefaultHomeViewSetupValues.notAbleToTapBookMarkButton
            return
        }
        
        //realm 존재여부 확인
        if let bookmarkedNews = defaultMediaStackVM.checkMediaStackNewsExistsInRealmWithLink(news: item) {
            //Journal 존재 여부 확인하기
            if defaultMediaStackVM.checkMemoExistsWithLink(bookMarked: bookmarkedNews) {
                //alert로 작동
                self.alertForRealmDeletion(title: DefaultHomeViewSetupValues.bookmarkedRealmDeletionTitle, message: DefaultHomeViewSetupValues.bookmarkedRealmDeletionMessage, bookMarked: bookmarkedNews, indexPath: indexPath)
            } else {
                //unselected로 변경: realm에서 제거
                cell.bookMarkButton.setUnselected()
                
                let links = Array(bookmarkedNews).map { $0.link }
                print("count of links: ", links.count)
                
                //Notification 먼저 주기: realm 제거되면 snapshot update 못함
                NotificationCenter.default.post(name: .realmDeletedSourceFromMediaStack, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: links])
                
                defaultMediaStackVM.removeBookMarkedNewsFromRealm(bookMarkedNews: bookmarkedNews)
            }
        } else {
            //selected로 변경: realm에 추가
            cell.bookMarkButton.setSelected()
            defaultMediaStackVM.saveNewsToRealm(news: item)
            
            NotificationCenter.default.post(name: .realmSavedSourceFromMediaStack, object: nil, userInfo: [NotificationUserInfoName.dtoNewsToBeSavedInRealm: item])
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
            let cell = self.linkPresentMediaStackCollectionView.cellForItem(at: indexPath) as? DefaultMediaStackNewsCell
            cell?.bookMarkButton.setUnselected()
            cell?.hideJournalWrittenImage()
            
            let links = Array(bookMarked).map { $0.link }
            print("count of links: ", links.count)
            
            //Notification 먼저 주기: snapshot update 목적
            NotificationCenter.default.post(name: .realmDeletedSourceFromMediaStack, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: links])
            
            //realm에서 제거
            self.defaultMediaStackVM.removeBookMarkedNewsFromRealm(bookMarkedNews: bookMarked)
        }
        let cancel = UIAlertAction(title: AlertConfirmText.basicCancel, style: .destructive)
        alert.addAction(cancel)
        alert.addAction(confirmToDelete)
        present(alert, animated: true)
    }
    
    //MARK: - Deinit
    
    deinit {
        print("Deinit in DefaultMediaStack")
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromMediaStack, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedSourceFromMediaStack, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedInJournalVCSourceFromMediaStack, object: nil)
    }
    
}

//MARK: - Extension for CollectionView Delegate, Prefetch DataSource

extension DefaultMediaStackNewsViewController: UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            showAlert(title: NewsSearchSetupValues.notAvailableToTapTitle, message: NewsSearchSetupValues.notAvailableToTapMessage)
            return
        }
        
        let webVC = WebViewController()
        webVC.webVM.updateAPITypeToMediaStack()
        
        if let bookMarked = defaultMediaStackVM.checkMediaStackNewsExistsInRealmWithLink(news: item) {
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
            if defaultMediaStackVM.checkPrefetchingNeeded(indexPath.row) {
                self.defaultMediaStackVM.offset.value += Constant.APISetup.mediaStackLimit
            }
        }
    }
            
}

