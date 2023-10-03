//
//  ViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

final class NewsSearchViewController: BaseViewController {

    //MARK: - Properties
    
    let newsSearchVM = NewsSearchViewModel()
    
    let apiSearchBar: CustomSearchBar = {
        let bar = CustomSearchBar()
        bar.placeholder = ViewControllerType.newsSearchVC.searchBarPlaceholder
        return bar
    }()
    
    let indicator = UIActivityIndicatorView(style: .large)
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewCompositionalLayout())
        view.backgroundColor = Constant.Color.whiteBackground
        return view
    }()
    
    var diffableDataSource: UICollectionViewDiffableDataSource<Int, News>!
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configDiffableDataSource()
        
        newsSearchVM.newsList.bind { newNewsList in
            //hide indicator
            self.inactivateIndicator()
            //collectionView update with snapshot
            self.updateSnapshot(newNewsList)
        }
        
        newsSearchVM.query.bind { _ in
            //새로운 query
            //page 초기화 체크
            if self.newsSearchVM.checkPageResetNeeded() {
                self.newsSearchVM.page.value = 1
            } else {
                //그대로 network 통신하기
                self.newsSearchVM.callRequest()
            }
        }
        
        newsSearchVM.page.bind { _ in
            //새로운 query & 새로운 page로 네트워크 통신
            //or page 추가로 pagination
            self.newsSearchVM.callRequest()
        }
        
        newsSearchVM.networkErrorMessage.bind { message in
            self.showAlert(title: NewsSearchSetupValues.networkErrorTitle, message: message)
        }
        
        //시작 시의 empty view 구성?
        
        
    }
    
    override func configureViews() {
        super.configureViews()
        
        configNavBar()
            
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.isPrefetchingEnabled = true
        collectionView.isPagingEnabled = true
        
        view.addSubview(indicator)
        indicator.isHidden = true
    }
    
    override func setConstraints() {
        super.setConstraints()
                
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        indicator.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }

    }
    
    private func configNavBar() {
        let simButton = UIAction(title: SortType.sim.sortTitle) { action in
            self.newsSearchVM.sortType = .sim
        }
        
        let dateButton = UIAction(title: SortType.date.sortTitle) { action in
            self.newsSearchVM.sortType = .date
        }
        let menu = UIMenu(options: .singleSelection, children: [simButton, dateButton])
        let barButton = UIBarButtonItem(title: NewsSearchSetupValues.popupMenuTitle)
        barButton.menu = menu
        barButton.tintColor = Constant.Color.mainRed
        navigationItem.leftBarButtonItem = barButton
        
        navigationItem.titleView = apiSearchBar
        apiSearchBar.delegate = self
    }
    
    //MARK: - Setup CollectionView Compositional Layout & Diffable DataSource & Snapshot
    
    private func configDiffableDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<NewsLinkPresentationCell, News> { cell, indexPath, itemIdentifier in
            cell.newsLinkPresentationVM.news.value = itemIdentifier
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }

    private func updateSnapshot(_ newsList: [News]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, News>()
        snapshot.appendSections([0])
        snapshot.appendItems(newsList)
        diffableDataSource.apply(snapshot)
    }
    
    private func setupCollectionViewCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constant.Frame.newsSearchCollectionViewItemFractionalWidth), heightDimension: .fractionalHeight(Constant.Frame.newsSearchCollectionViewItemFractionalHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constant.Frame.newsSearchCollectionViewGroupFractionalWidth), heightDimension: .fractionalHeight(Constant.Frame.newsSearchCollectionViewGroupFractionalHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: Constant.Frame.newsSearchCollectionViewRepeatingItemCount)
        
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
    
    
    //MARK: - Handlers
    
    private func activateIndicator() {
        self.indicator.startAnimating()
        self.indicator.isHidden = false
    }
    
    private func inactivateIndicator() {
        self.indicator.isHidden = true
        self.indicator.stopAnimating()
    }
 
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        apiSearchBar.resignFirstResponder()
    }
     
}

//MARK: - Extension for SearchBar Delegate

extension NewsSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        //빈칸이면 검색되지 않음
        guard let text = searchBar.text, !text.isEmpty else {
            toastManager.present(text: NewsSearchSetupValues.noSearchWordsToastMessage) { presenter in
                presenter.dismiss(afterDelay: NewsSearchSetupValues.noSearchWordsToastMessageDismissDelay)
            }
            return
        }
        self.activateIndicator()
        newsSearchVM.query.value = text
    }
    
}

//MARK: - Extension for CollectionView Delegate, Prefetch DataSource

extension NewsSearchViewController: UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            showAlert(title: NewsSearchSetupValues.notAvailableToTapTitle, message: NewsSearchSetupValues.notAvailableToTapMessage)
            return
        }
        
        let webVC = WebViewController()
        webVC.webVM.news.value = item
        
        self.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if newsSearchVM.checkPrefetchingNeeded(indexPath.row) {
                self.newsSearchVM.page.value += 1
            }
        }
    }
    
}
