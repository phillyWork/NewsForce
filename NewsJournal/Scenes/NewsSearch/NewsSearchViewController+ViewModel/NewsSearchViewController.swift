//
//  ViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

import RealmSwift

final class NewsSearchViewController: BaseViewController {

    //MARK: - Properties
    
    let newsSearchVM = NewsSearchViewModel()
    
    private let apiSearchBar: CustomSearchBar = {
        let bar = CustomSearchBar()
        bar.placeholder = ViewControllerType.newsSearchWithRecentWords.searchBarPlaceholder
        bar.showsCancelButton = true
        return bar
    }()
    
    lazy private var searchOptionButton: UIButton = {
        let button = UIButton()
        button.tintColor = Constant.Color.mainRed
        button.setImage(UIImage(systemName: Constant.ImageString.searchOptionSliderImageString), for: .normal)
        return button
    }()
    
    private let indicator = UIActivityIndicatorView(style: .large)
    
    lazy private var linkPresentCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewCompositionalLayout())
        view.backgroundColor = Constant.Color.whiteBackground
        return view
    }()
    
    private let searchKeywordContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constant.Color.whiteBackground
        view.isHidden = true
        return view
    }()
    
    lazy private var searchKeywordCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewCompositionalLayoutListConfiguration())
        view.backgroundColor = Constant.Color.whiteBackground
        return view
    }()
    
    lazy private var optionView: UIView = {
        let width = view.safeAreaLayoutGuide.layoutFrame.width * 0.8
        let height = view.safeAreaLayoutGuide.layoutFrame.height * 0.6
        
        let x = (view.frame.width - width) / 2
        let y = view.safeAreaLayoutGuide.layoutFrame.height
        
        let view = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        view.backgroundColor = Constant.Color.whiteBackground
        return view
    }()
    
    lazy private var blurBackView: UIVisualEffectView = {
        let view = UIVisualEffectView(frame: CGRect(x: 0, y: view.safeAreaLayoutGuide.layoutFrame.height, width: view.safeAreaLayoutGuide.layoutFrame.width, height: view.safeAreaLayoutGuide.layoutFrame.height))
        view.effect = UIBlurEffect(style: .dark)
        return view
    }()
    
    lazy private var closeButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: Constant.Frame.newsSearchOptionCloseButtonPointSize, weight: .light)
        button.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
        button.setImage(UIImage(systemName: Constant.ImageString.xmarkImageString), for: .normal)
        button.tintColor = Constant.Color.blackText
        return button
    }()
    
    lazy private var optionConfirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constant.Label.optionButtonConfirm, for: .normal)
        button.titleLabel?.font = Constant.Font.searchOptionConfirmButton
        button.backgroundColor = Constant.Color.mainRed
        button.layer.cornerRadius = Constant.Frame.searchOptionConfirmResetButtonCornerRadius
        button.clipsToBounds = true
        return button
    }()
    
    lazy private var optionResetButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constant.Label.optionButtonReset, for: .normal)
        button.titleLabel?.font = Constant.Font.searchOptionResetButton
        button.backgroundColor = Constant.Color.linkDateShadowText
        button.layer.cornerRadius = Constant.Frame.searchOptionConfirmResetButtonCornerRadius
        button.clipsToBounds = true
        return button
    }()
    
    private let optionMainTitleLabel: UILabel = {
        let label = UILabel()
        label.text = NewsSearchSetupValues.optionMainTitleLabel
        label.font = Constant.Font.optionMainTitleLabel
        return label
    }()
    
    private let optionAPITypeTitleLabel = CustomSearchOptionLabel(frame: .zero, type: .searchAPIType)
    
    lazy private var optionNaverSearchButton = CustomSearchOptionButton(frame: .zero, title: SearchAPIType.naver.typeTitle)
    lazy private var optionNewsAPISearchButton = CustomSearchOptionButton(frame: .zero, title: SearchAPIType.newsAPI.typeTitle)
    var searchAPITypeButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let optionSearchTypeTitleLabel = CustomSearchOptionLabel(frame: .zero, type: .searchSortType)
    
    //naver용 옵션 버튼 구성
    lazy private var optionNaverSortSimButton = CustomSearchOptionButton(frame: .zero, title: NaverNewsSearchSortType.sim.sortTitle)
    lazy private var optionNaverSortDateButton = CustomSearchOptionButton(frame: .zero, title: NaverNewsSearchSortType.date.sortTitle)
    private var naverOptionButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    //NewsAPI용 옵션 버튼 구성
    lazy private var optionNewsAPISortPublishedAtButton = CustomSearchOptionButton(frame: .zero, title: NewsAPISearchSortType.publishedAt.sortTitle)
    lazy private var optionNewsAPISortRelevancyButton = CustomSearchOptionButton(frame: .zero, title: NewsAPISearchSortType.relevancy.sortTitle)
    lazy private var optionNewsAPISortPopularityButton = CustomSearchOptionButton(frame: .zero, title: NewsAPISearchSortType.popularity.sortTitle)
    private var newsAPIOptionButtonSortTypeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.isHidden = true
        return stack
    }()
    
    private let optionNewsAPISearchTypeLabel = CustomSearchOptionLabel(frame: .zero, type: .searchQueryMechanism)
    
    lazy private var optionNewsAPISearchWordANDButton = CustomSearchOptionButton(frame: .zero, title: NewsAPISearchQueryBlankReplacementType.asAnd.title)
    lazy private var optionNewsAPISearchWordORButton = CustomSearchOptionButton(frame: .zero, title: NewsAPISearchQueryBlankReplacementType.asOr.title)
    private var newsAPIOptionButtonSearchTypeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.isHidden = true
        return stack
    }()
    
    private var diffableDataSourceForSearchKeywords: UICollectionViewDiffableDataSource<Int, UserSearchKeyword>!
    private var diffableDataSourceForSearchResults: UICollectionViewDiffableDataSource<Int, DTONews>!
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configDiffableDataSourceForSearchKeywords()
        configDiffableDataSourceForSearchResults()
        
        newsSearchVM.keywordList.bind { newWordList in
            var newWordsInArray: Array<UserSearchKeyword>
            if let newWordList = newWordList {
                newWordsInArray = Array(newWordList)
            } else {
                newWordsInArray = [UserSearchKeyword]()
            }
            self.updateSnapshotForSearchKeywords(newWordsInArray)
        }
        
        newsSearchVM.newsList.bind { newNewsList in
            //hide indicator
            self.inactivateIndicator()
            //collectionView update with snapshot
            self.updateSnapshotForSearchResults(newNewsList)
        }
        
        newsSearchVM.errorMessage.bind { message in
            //toast
            self.showErrorToastMessage(message: message)
        }
        
        newsSearchVM.isEmptyView.bind { value in
            if value {
                //show empty view
                self.linkPresentCollectionView.setupBackgroundNoAPIResultEmptyView()
            } else {
                //not showing empty view
                self.linkPresentCollectionView.restoreBackgroundFromEmptyView()
            }
        }
        
        newsSearchVM.naverQuery.bind { _ in
            //새로운 query
            //검색하고 내부에서 page/offset 체크?
            
            //page 초기화 체크
            if self.newsSearchVM.checkNaverPageResetNeeded() {
                self.newsSearchVM.naverPage.value = 1
            } else {
                //그대로 network 통신하기
                self.newsSearchVM.callRequest()
            }
        }
        
        newsSearchVM.naverPage.bind { _ in
            //새로운 query & 새로운 page로 네트워크 통신
            //or page 추가로 pagination
            self.newsSearchVM.callRequest()
        }
        
        newsSearchVM.newsAPIQuery.bind { _ in
            if self.newsSearchVM.checkNewsAPIPageResetNeeded() {
                self.newsSearchVM.newsAPIPage.value = 1
            } else {
                self.newsSearchVM.callRequest()
            }
        }
        
        newsSearchVM.newsAPIPage.bind { _ in
            self.newsSearchVM.callRequest()
        }
        
        newsSearchVM.newsAPIApiKeyIndex.bind { _ in
            self.newsSearchVM.callRequest()
        }
        
        //Notification 설정
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInSearch), name: .realmSavedSourceFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationJournalSavedObserverInSearch), name: .journalSavedInMemoVCFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationJournalSavedObserverInSearch), name: .journalSavedSourceFromNaver, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationJournalSavedObserverInSearch), name: .journalSavedSourceFromNewsAPI, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationJournalSavedObserverInSearch), name: .journalSavedInMemoVCFromNewsAPI, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInSearch), name: .realmDeletedSourceFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInSearch), name: .realmDeletedInJournalVCSourceFromNaver, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInSearch), name: .realmDeletedInJournalVCSourceFromNewsAPI, object: nil)
        
        //시작 시의 empty view 구성
        linkPresentCollectionView.setupInitialBackgroundForSearch()
    }
    
    override func configureViews() {
        super.configureViews()
        
        configNavBar()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        view.addSubview(searchOptionButton)
        searchOptionButton.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
        
        view.addSubview(apiSearchBar)
        apiSearchBar.delegate = self
        
        view.addSubview(linkPresentCollectionView)
        linkPresentCollectionView.delegate = self
        linkPresentCollectionView.prefetchDataSource = self
        linkPresentCollectionView.isPrefetchingEnabled = true
        linkPresentCollectionView.isPagingEnabled = true
        
        view.addSubview(searchKeywordContainerView)
        searchKeywordContainerView.addSubview(searchKeywordCollectionView)
        searchKeywordCollectionView.delegate = self
        
        view.addSubview(indicator)
        indicator.isHidden = true
        
        view.addSubview(optionView)
        newsSearchVM.yPosForHidingOptionView = optionView.frame.origin.y
        
        optionView.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        optionView.addSubview(optionMainTitleLabel)
        optionView.addSubview(optionAPITypeTitleLabel)
        optionView.addSubview(optionSearchTypeTitleLabel)
        
        optionView.addSubview(optionConfirmButton)
        optionView.addSubview(optionResetButton)
        optionConfirmButton.addTarget(self, action: #selector(optionViewConfirmButtonTapped), for: .touchUpInside)
        optionResetButton.addTarget(self, action: #selector(optionResetButtonTapped), for: .touchUpInside)
        
        searchAPITypeButtonStack.addArrangedSubview(optionNaverSearchButton)
        searchAPITypeButtonStack.addArrangedSubview(optionNewsAPISearchButton)
        optionNaverSearchButton.addTarget(self, action: #selector(optionSearchTypeNaverButtonTapped), for: .touchUpInside)
        optionNewsAPISearchButton.addTarget(self, action: #selector(optionSearchTypeNewsAPIButtonTapped), for: .touchUpInside)
        optionView.addSubview(searchAPITypeButtonStack)
        
        naverOptionButtonStack.addArrangedSubview(optionNaverSortSimButton)
        naverOptionButtonStack.addArrangedSubview(optionNaverSortDateButton)
        optionNaverSortSimButton.addTarget(self, action: #selector(optionNaverSimButtonTapped), for: .touchUpInside)
        optionNaverSortDateButton.addTarget(self, action: #selector(optionNaverDateButtonTapped), for: .touchUpInside)
        optionView.addSubview(naverOptionButtonStack)
        
        newsAPIOptionButtonSortTypeStack.addArrangedSubview(optionNewsAPISortPublishedAtButton)
        newsAPIOptionButtonSortTypeStack.addArrangedSubview(optionNewsAPISortRelevancyButton)
        newsAPIOptionButtonSortTypeStack.addArrangedSubview(optionNewsAPISortPopularityButton)
        optionNewsAPISortPublishedAtButton.addTarget(self, action: #selector(optionNewsAPIPublishedAtButtonTapped), for: .touchUpInside)
        optionNewsAPISortRelevancyButton.addTarget(self, action: #selector(optionNewsAPIRelevancyButtonTapped), for: .touchUpInside)
        optionNewsAPISortPopularityButton.addTarget(self, action: #selector(optionNewsAPIPopularityButtonTapped), for: .touchUpInside)
        newsAPIOptionButtonSortTypeStack.isHidden = true
        optionView.addSubview(newsAPIOptionButtonSortTypeStack)
        
        optionView.addSubview(optionNewsAPISearchTypeLabel)
        optionNewsAPISearchTypeLabel.isHidden = true
        
        newsAPIOptionButtonSearchTypeStack.addArrangedSubview(optionNewsAPISearchWordANDButton)
        newsAPIOptionButtonSearchTypeStack.addArrangedSubview(optionNewsAPISearchWordORButton)
        optionNewsAPISearchWordANDButton.addTarget(self, action: #selector(optionNewsAPISearchWordsANDButtonTapped), for: .touchUpInside)
        optionNewsAPISearchWordORButton.addTarget(self, action: #selector(optionNewsAPISearchWordsORButtonTapped), for: .touchUpInside)
        optionView.addSubview(newsAPIOptionButtonSearchTypeStack)
        
        view.insertSubview(blurBackView, belowSubview: optionView)
        
    }
    
    override func setConstraints() {
        super.setConstraints()
                
        searchOptionButton.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide).multipliedBy(0.15)
            make.height.equalTo(searchOptionButton.snp.width)
        }
        
        apiSearchBar.snp.makeConstraints { make in
            make.top.trailing.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(searchOptionButton.snp.trailing)
            make.height.equalTo(searchOptionButton.snp.height)
        }
        
        searchKeywordContainerView.snp.makeConstraints { make in
            make.top.equalTo(apiSearchBar.snp.bottom)
            make.bottom.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        searchKeywordCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        linkPresentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(apiSearchBar.snp.bottom)
            make.bottom.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        indicator.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.15)
            make.height.equalTo(closeButton.snp.width)
        }
        
        optionMainTitleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(15)
        }
        
        optionAPITypeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(optionMainTitleLabel.snp.bottom).offset(20)
            make.leading.equalTo(optionMainTitleLabel.snp.leading)
        }
        
        searchAPITypeButtonStack.snp.makeConstraints { make in
            make.top.equalTo(optionAPITypeTitleLabel.snp.bottom).offset(15)
            make.directionalHorizontalEdges.equalToSuperview().inset(10)
        }
        
        optionSearchTypeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(searchAPITypeButtonStack.snp.bottom).offset(20)
            make.leading.equalTo(optionAPITypeTitleLabel.snp.leading)
        }
        
        newsAPIOptionButtonSortTypeStack.snp.makeConstraints { make in
            make.top.equalTo(optionSearchTypeTitleLabel.snp.bottom).offset(10)
            make.directionalHorizontalEdges.equalTo(searchAPITypeButtonStack.snp.directionalHorizontalEdges)
        }
        
        naverOptionButtonStack.snp.makeConstraints { make in
            make.top.equalTo(optionSearchTypeTitleLabel.snp.bottom).offset(10)
            make.directionalHorizontalEdges.equalTo(searchAPITypeButtonStack.snp.directionalHorizontalEdges)
        }
        
        optionNewsAPISearchTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(newsAPIOptionButtonSortTypeStack.snp.bottom).offset(20)
            make.leading.equalTo(optionAPITypeTitleLabel.snp.leading)
        }
        
        newsAPIOptionButtonSearchTypeStack.snp.makeConstraints { make in
            make.top.equalTo(optionNewsAPISearchTypeLabel.snp.bottom).offset(10)
            make.directionalHorizontalEdges.equalTo(searchAPITypeButtonStack.snp.directionalHorizontalEdges)
        }
    
        optionResetButton.snp.makeConstraints { make in
            make.leading.equalTo(optionAPITypeTitleLabel.snp.leading)
            make.bottom.equalTo(optionView.snp.bottom).inset(20)
            make.width.equalTo(optionView.snp.width).multipliedBy(0.3)
            make.height.equalTo(optionResetButton.snp.width).multipliedBy(0.5)
        }
        
        optionConfirmButton.snp.makeConstraints { make in
            make.trailing.equalTo(optionView.snp.trailing).inset(15)
            make.top.equalTo(optionResetButton.snp.top)
            make.width.equalTo(optionView.snp.width).multipliedBy(0.55)
            make.height.equalTo(optionResetButton.snp.height)
        }
        
    }
    
    private func configNavBar() {
        navigationItem.title = ViewControllerType.newsSearchWithRecentWords.navBarTitle
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: - Setup CollectionView Compositional Layout & Diffable DataSource & Snapshot For Previously Searched Keywords
    
    private func configDiffableDataSourceForSearchKeywords() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, UserSearchKeyword> { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            content.text = itemIdentifier.searchWord
            content.textProperties.color = Constant.Color.blackText
            content.textProperties.font = Constant.Font.searchKeyword
            
            content.secondaryText = "마지막 검색: \(self.newsSearchVM.calculateDaysForKeywordLastSearch(from: itemIdentifier.lastlySearchedAt, to: Date()))"
            content.secondaryTextProperties.color = Constant.Color.linkDateShadowText
            content.secondaryTextProperties.font = Constant.Font.searchKeywordLastDate
            
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = Constant.Color.whiteBackground
            cell.selectedBackgroundView = selectedBackgroundView
            
            cell.contentConfiguration = content
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { supplementaryView, elementKind, indexPath in
            var configuration = UIListContentConfiguration.groupedHeader()
            configuration.text = NewsSearchSetupValues.headerTitle
            supplementaryView.contentConfiguration = configuration
        }
        
        diffableDataSourceForSearchKeywords = UICollectionViewDiffableDataSource(collectionView: searchKeywordCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        diffableDataSourceForSearchKeywords.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
    }
    
    private func updateSnapshotForSearchKeywords(_ keywords: [UserSearchKeyword]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UserSearchKeyword>()
        snapshot.appendSections([0])
        snapshot.appendItems(keywords)
        diffableDataSourceForSearchKeywords.apply(snapshot)
    }
    
    private func setupCollectionViewCompositionalLayoutListConfiguration() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self, let keyword = self.diffableDataSourceForSearchKeywords.itemIdentifier(for: indexPath) else {
                print("No keyword to be deleted")
                return nil
            }
            
            print("keyword about to delete: ", keyword)
            
            let actionHandler: UIContextualAction.Handler = { action, view, completionHandler in
                //update snapshot without that keyword
                self.newsSearchVM.fetchKeywordWithoutWord(keyword: keyword)
                //delete keyword data
                self.newsSearchVM.deleteSearchWord(keyword: keyword)
                completionHandler(true)
            }
            
            let action = UIContextualAction(style: .destructive, title: NewsSearchSetupValues.searchKeywordSwipeDeletionActionTitle, handler: actionHandler)
            return UISwipeActionsConfiguration(actions: [action])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    //MARK: - Setup CollectionView Compositional Layout & Diffable DataSource & Snapshot
    
    private func configDiffableDataSourceForSearchResults() {
        let cellRegistration = UICollectionView.CellRegistration<NewsLinkPresentationCell, DTONews> { cell, indexPath, itemIdentifier in
            cell.newsLinkPresentationVM.news.value = itemIdentifier
            //indexPath for update button & realm
            cell.bookMarkButton.indexPath = indexPath
            //addTarget
            cell.bookMarkButton.addTarget(self, action: #selector(self.bookmarkButtonTapped), for: .touchUpInside)
        }
        
        diffableDataSourceForSearchResults = UICollectionViewDiffableDataSource(collectionView: linkPresentCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }

    private func updateSnapshotForSearchResults(_ newsList: [DTONews]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, DTONews>()
        snapshot.appendSections([0])
        snapshot.appendItems(newsList)
        diffableDataSourceForSearchResults.apply(snapshot)
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
    
    //MARK: - Handler for Notification
    
    @objc private func notificationRealmSavedObserverInSearch(notification: Notification) {
        print(#function)
        if let savedItem = notification.userInfo?[NotificationUserInfoName.dtoNewsToBeSavedInRealm] as? DTONews {
            let indexPaths = newsSearchVM.checkIndexForDTONewsSavedInRealm(passedNews: savedItem)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentCollectionView.cellForItem(at: indexPath) as? NewsLinkPresentationCell
                    cell?.bookMarkButton.setSelected()
                }
            }
        }
    }
    
    @objc private func notificationJournalSavedObserverInSearch(notification: Notification) {
        print(#function)
        //realm 검색해서 여부 체크하기
        if let savedItem = notification.userInfo?[NotificationUserInfoName.realmBookMarkedNewsLinkToBeSaved] as? String {
            let indexPaths = newsSearchVM.checkIndexForBookMarkedNewsSavedInRealm(passedNewsLink: savedItem)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentCollectionView.cellForItem(at: indexPath) as? NewsLinkPresentationCell
                    cell?.bookMarkButton.setSelected()
                    cell?.showJournalWrittenImage()
                }
            }
        }
    }
    
    @objc private func notificationRealmDeletedObserverInSearch(notification: Notification) {
        print(#function)
        if let deletedItem = notification.userInfo?[NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted] as? [String] {
            let indexPaths = newsSearchVM.checkDeletedBookmarkNewsInSearchNewsList(deleted: deletedItem)
            if !indexPaths.isEmpty {
                for indexPath in indexPaths {
                    let cell = linkPresentCollectionView.cellForItem(at: indexPath) as? NewsLinkPresentationCell
                    cell?.bookMarkButton.setUnselected()
                    cell?.hideJournalWrittenImage()
                }
            }
        }
    }
    
    //MARK: - Handler for Bookmark Button
    
    @objc private func bookmarkButtonTapped(sender: CustomBookMarkButton) {
        
        guard let indexPath = sender.indexPath, let item = diffableDataSourceForSearchResults.itemIdentifier(for: indexPath) else {
            newsSearchVM.errorMessage.value = DefaultHomeViewSetupValues.notAbleToTapBookMarkButton
            return
        }
        
        guard let cell = linkPresentCollectionView.cellForItem(at: indexPath) as? NewsLinkPresentationCell else {
            newsSearchVM.errorMessage.value = DefaultHomeViewSetupValues.notAbleToTapBookMarkButton
            return
        }
        
        //realm 존재여부 확인
        if let bookmarkedNews = newsSearchVM.checkBookMarkedNewsExistWithLink(news: item) {
            //Journal 존재 여부 확인하기
            if newsSearchVM.checkMemoExistsInBookMarkedNewsWithLink(bookMarked: bookmarkedNews) {
                //alert로 작동
                self.alertForRealmDeletion(title: NewsSearchSetupValues.bookmarkedRealmDeletionTitle, message: NewsSearchSetupValues.bookmarkedRealmDeletionMessage, bookMarked: bookmarkedNews, indexPath: indexPath)
            } else {
                //unselected로 변경
                cell.bookMarkButton.setUnselected()
                
                //제거 전에 먼저 Notification 주기
                let links = Array(bookmarkedNews).map { $0.link }
                print("count of links in searchVC: ", links.count)
                
                //Notification 전달
                switch self.newsSearchVM.checkCurrentSearchAPI() {
                case .naver:
                    NotificationCenter.default.post(name: .realmDeletedInSearchVCSourceFromNaver, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: links])
                case .newsAPI:
                    NotificationCenter.default.post(name: .realmDeletedInSearchVCSourceFromNewsAPI, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: links])
                }
                //realm에서 제거
                newsSearchVM.removeBookMarkedNewsFromRealm(bookMarkedNews: bookmarkedNews)
            }
        } else {
            //selected로 변경: realm에 추가
            cell.bookMarkButton.setSelected()
            newsSearchVM.saveNewsToRealm(news: item)
            
            //Notification 필요
            switch self.newsSearchVM.checkCurrentSearchAPI() {
            case .naver:
                NotificationCenter.default.post(name: .realmSavedInSearchVCSourceFromNaver, object: nil, userInfo: [NotificationUserInfoName.dtoNewsToBeSavedInRealm: item])
            case .newsAPI:
                NotificationCenter.default.post(name: .realmSavedInSearchVCSourceFromNewsAPI, object: nil, userInfo: [NotificationUserInfoName.dtoNewsToBeSavedInRealm: item])
            }
        }
    }
    
    private func alertForRealmDeletion(title: String, message: String, bookMarked: Results<BookMarkedNews>, indexPath: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmToDelete = UIAlertAction(title: AlertConfirmText.deleteFromRealm, style: .default) { action in
            
            let cell = self.linkPresentCollectionView.cellForItem(at: indexPath) as? NewsLinkPresentationCell
            cell?.bookMarkButton.setUnselected()
            cell?.hideJournalWrittenImage()
            
            let links = Array(bookMarked).map { $0.link }
            print("count of links in searchVC: ", links.count)
            
            //Notification 전달
            switch self.newsSearchVM.checkCurrentSearchAPI() {
            case .naver:
                NotificationCenter.default.post(name: .realmDeletedInSearchVCSourceFromNaver, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: links])
            case .newsAPI:
                NotificationCenter.default.post(name: .realmDeletedInSearchVCSourceFromNewsAPI, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: links])
            }

            //realm에서 제거
            self.newsSearchVM.removeBookMarkedNewsFromRealm(bookMarkedNews: bookMarked)
        }
        let cancel = UIAlertAction(title: AlertConfirmText.basicCancel, style: .destructive)
        alert.addAction(cancel)
        alert.addAction(confirmToDelete)
        present(alert, animated: true)
    }
    
    //MARK: - Handlers for Option, reset and Confirm Button
    
    @objc private func optionButtonTapped() {
        revealOptionView()
        
        //기본 설정된 option 보여주기: 현재 검색 상태 및 세부 option 선택 상태
        switch newsSearchVM.checkCurrentSearchAPI() {
        case .naver:
            optionSearchTypeNaverButtonTapped()
        case .newsAPI:
            optionSearchTypeNewsAPIButtonTapped()
        }
    }
    
    @objc private func closeButtonTapped() {
        hideOptionView()
    }
        
    @objc private func optionViewConfirmButtonTapped() {
        newsSearchVM.setSearchTypeAPI()
        switch newsSearchVM.checkCurrentSearchAPI() {
        case .naver:
            newsSearchVM.setNaverSortType()
        case .newsAPI:
            newsSearchVM.setNewsAPISortBy()
            newsSearchVM.setNewsAPISearchWordTypeBy()
        }
        hideOptionView()
    }
        
    @objc private func optionResetButtonTapped() {
        //검색 초기화: 국내 검색, 정확도 순 선택되도록 되돌리기
        deSelectNaverSearch()
        optionNewsAPISortPublishedAtButton.isButtonSelected = false
        optionNewsAPISortRelevancyButton.isButtonSelected = false
        optionNewsAPISortPopularityButton.isButtonSelected = false
        optionNewsAPISearchWordANDButton.isButtonSelected = false
        optionNewsAPISearchWordORButton.isButtonSelected = false
        newsSearchVM.resetNewsAPISortType()
        newsSearchVM.resetNaverAPISortType()
        optionSearchTypeNaverButtonTapped()
    }
    
    private func revealOptionView() {
        let centerY = (view.frame.height - optionView.frame.height) / 1.5
        
        UIView.animate(withDuration: 0.3) {
            self.blurBackView.frame.origin.y = .zero
            self.optionView.frame.origin.y = centerY
        }
    }

    private func hideOptionView() {
        UIView.animate(withDuration: Constant.TimeDelay.optionViewAnimationDuration) {
            self.blurBackView.frame.origin.y = self.newsSearchVM.yPosForHidingOptionView
            self.optionView.frame.origin.y = self.newsSearchVM.yPosForHidingOptionView
        }
    }
    
    //MARK: - Handlers for Naver API
    
    @objc private func optionSearchTypeNaverButtonTapped() {
        newsSearchVM.saveSearchTypeAPI(type: .naver)
        optionNaverSearchButton.isButtonSelected = true
        naverOptionButtonStack.isHidden = false
        deSelectNewsAPISearch()
        
        //저장된 sort type이 선택되도록 하기
        switch newsSearchVM.checkCurrentNaverSortType() {
        case .sim:
            optionNaverSimButtonTapped()
        case .date:
            optionNaverDateButtonTapped()
        }
    }
    
    private func deSelectNewsAPISearch() {
        optionNewsAPISearchButton.isButtonSelected = false
        optionNewsAPISearchTypeLabel.isHidden = true
        newsAPIOptionButtonSortTypeStack.isHidden = true
        newsAPIOptionButtonSearchTypeStack.isHidden = true
    }
    
    @objc private func optionNaverSimButtonTapped() {
        newsSearchVM.saveNaverSortType(type: .sim)
        optionNaverSortSimButton.isButtonSelected = true
        optionNaverSortDateButton.isButtonSelected = false
    }
    
    @objc private func optionNaverDateButtonTapped() {
        newsSearchVM.saveNaverSortType(type: .date)
        optionNaverSortDateButton.isButtonSelected = true
        optionNaverSortSimButton.isButtonSelected = false
    }
    
    //MARK: - Handlers for NewsAPI Option
    
    @objc private func optionSearchTypeNewsAPIButtonTapped() {
        newsSearchVM.saveSearchTypeAPI(type: .newsAPI)
        deSelectNaverSearch()
        optionNewsAPISearchTypeLabel.isHidden = false
        newsAPIOptionButtonSortTypeStack.isHidden = false
        newsAPIOptionButtonSearchTypeStack.isHidden = false
        optionNewsAPISearchButton.isButtonSelected = true
        
        //저장된 sortBy 선택되도록
        switch newsSearchVM.checkCurrentNewsAPISortType() {
        case .publishedAt:
            toggleNewsAPISortButton(type: .publishedAt)
        case .relevancy:
            toggleNewsAPISortButton(type: .relevancy)
        case .popularity:
            toggleNewsAPISortButton(type: .popularity)
        }
        
        //저장된 search 방식 선택되도록
        switch newsSearchVM.checkCurrentNewsAPISearchType() {
        case .asAnd:
            toggleNewsAPISearchButton(type: .asAnd)
        case .asOr:
            toggleNewsAPISearchButton(type: .asOr)
        }
    }
    
    private func deSelectNaverSearch() {
        optionNaverSearchButton.isButtonSelected = false
        naverOptionButtonStack.isHidden = true
    }
    
    //search option button 설정
    @objc private func optionNewsAPIPublishedAtButtonTapped() {
        newsSearchVM.saveNewsAPISortBy(type: .publishedAt)
        toggleNewsAPISortButton(type: .publishedAt)
    }
    
    @objc private func optionNewsAPIRelevancyButtonTapped() {
        newsSearchVM.saveNewsAPISortBy(type: .relevancy)
        toggleNewsAPISortButton(type: .relevancy)
    }

    @objc private func optionNewsAPIPopularityButtonTapped() {
        newsSearchVM.saveNewsAPISortBy(type: .popularity)
        toggleNewsAPISortButton(type: .popularity)
    }
    
    private func toggleNewsAPISortButton(type: NewsAPISearchSortType) {
        switch type {
        case .relevancy:
            optionNewsAPISortPublishedAtButton.isButtonSelected = false
            optionNewsAPISortRelevancyButton.isButtonSelected = true
            optionNewsAPISortPopularityButton.isButtonSelected = false
        case .popularity:
            optionNewsAPISortPublishedAtButton.isButtonSelected = false
            optionNewsAPISortRelevancyButton.isButtonSelected = false
            optionNewsAPISortPopularityButton.isButtonSelected = true
        case .publishedAt:
            optionNewsAPISortPublishedAtButton.isButtonSelected = true
            optionNewsAPISortRelevancyButton.isButtonSelected = false
            optionNewsAPISortPopularityButton.isButtonSelected = false
        }
    }
    
    @objc private func optionNewsAPISearchWordsANDButtonTapped() {
        newsSearchVM.saveNewsAPISearchWordTypeBy(type: .asAnd)
        toggleNewsAPISearchButton(type: .asAnd)
    }
    
    @objc private func optionNewsAPISearchWordsORButtonTapped() {
        newsSearchVM.saveNewsAPISearchWordTypeBy(type: .asOr)
        toggleNewsAPISearchButton(type: .asOr)
    }
    
    private func toggleNewsAPISearchButton(type: NewsAPISearchQueryBlankReplacementType) {
        switch type {
        case .asAnd:
            optionNewsAPISearchWordANDButton.isButtonSelected = true
            optionNewsAPISearchWordORButton.isButtonSelected = false
        case .asOr:
            optionNewsAPISearchWordANDButton.isButtonSelected = false
            optionNewsAPISearchWordORButton.isButtonSelected = true
        }
    }

    //MARK: - Handlers

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    private func activateIndicator() {
        self.indicator.startAnimating()
        self.indicator.isHidden = false
    }
    
    private func inactivateIndicator() {
        self.indicator.isHidden = true
        self.indicator.stopAnimating()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print(#function)
        apiSearchBar.resignFirstResponder()
    }
     
    //MARK: - Deinit
    
    deinit {
        print("deinit in SearchVC")
        NotificationCenter.default.removeObserver(self, name: .realmSavedSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedSourceFromNewsAPI, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromNewsAPI, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedInJournalVCSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedInJournalVCSourceFromNewsAPI, object: nil)
    }
    
}

//MARK: - Extension for SearchBar Delegate

extension NewsSearchViewController: UISearchBarDelegate {
    
    //user tap: search history containerview appears
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchKeywordContainerView.isHidden = false
        newsSearchVM.fetchKeywords()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchKeywordContainerView.isHidden = true
        searchBar.resignFirstResponder()
        
        //빈칸이면 검색되지 않음
        guard let text = searchBar.text, !text.isEmpty else {
            newsSearchVM.errorMessage.value = NewsSearchSetupValues.noSearchWordsToastMessage
            return
        }
        
        self.activateIndicator()
        switch newsSearchVM.checkCurrentSearchAPI() {
        case .naver:
            newsSearchVM.naverQuery.value = text
        case .newsAPI:
            newsSearchVM.newsAPIQuery.value = text
        }
        
        //realm에 검색어 및 횟수 저장 or update 하기
        newsSearchVM.updateSearchWords()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchKeywordContainerView.isHidden = true
    }
    
}

//MARK: - Extension for CollectionView Delegate, Prefetch DataSource

extension NewsSearchViewController: UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == linkPresentCollectionView {
            guard let item = diffableDataSourceForSearchResults.itemIdentifier(for: indexPath) else {
                showAlert(title: NewsSearchSetupValues.notAvailableToTapTitle, message: NewsSearchSetupValues.notAvailableToTapMessage)
                return
            }
            
            let webVC = WebViewController()
            switch newsSearchVM.checkCurrentSearchAPI() {
            case .naver:
                webVC.webVM.updateAPITypeToNaver()
            case .newsAPI:
                webVC.webVM.updateAPITypeToNewsAPI()
            }
            
            if let bookMarked = newsSearchVM.checkBookMarkedNewsExistWithLink(news: item) {
                webVC.webVM.objectId = bookMarked.first?._id
            } else {
                webVC.webVM.news = item
            }
            
            self.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webVC, animated: true)
            self.hidesBottomBarWhenPushed = false
        } else {
            guard let item = diffableDataSourceForSearchKeywords.itemIdentifier(for: indexPath) else {
                showAlert(title: NewsSearchSetupValues.notAvailableToTapTitle, message: NewsSearchSetupValues.notAvailableToTapMessage)
                return
            }
            
            apiSearchBar.text = item.searchWord
            searchBarSearchButtonClicked(apiSearchBar)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if collectionView == linkPresentCollectionView {
            for indexPath in indexPaths {
                if newsSearchVM.checkPrefetchingNeeded(indexPath.row) {
                    switch newsSearchVM.checkCurrentSearchAPI() {
                    case .naver:
                        self.newsSearchVM.naverPage.value += 1
                    case .newsAPI:
                        self.newsSearchVM.newsAPIPage.value += 1
                    }
                }
            }
        }
    }
    
}
