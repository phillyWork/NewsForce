//
//  NewMemoViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

import RealmSwift

final class JournalViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let realmSearchBar: CustomSearchBar = {
        let bar = CustomSearchBar()
        bar.placeholder = ViewControllerType.journalWithPinnedNews.searchBarPlaceholder
        return bar
    }()

    private lazy var pdfBarButtonItem: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .selectForPDF)
        button.target = self
        button.action = #selector(pdfButtonTapped)
        return button
    }()
    
    private lazy var createPDFDocumentBarButtonItem: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .createPDFDocument)
        button.target = self
        button.action = #selector(createPDFDocumentButtonTapped)
        return button
    }()
    
    private lazy var deleteBarButtonItem: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .selectForDeletion)
        button.target = self
        button.action = #selector(deleteButtonTapped)
        return button
    }()
    
    private lazy var deleteConfirmBarButtonItem: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .deletionConfirmation)
        button.target = self
        button.action = #selector(confirmDeletionButtonTapped)
        return button
    }()
    
    private lazy var cancelBarButtonItem: CustomBarButtonItem = {
        let button = CustomBarButtonItem(type: .cancel)
        button.target = self
        button.action = #selector(cancelButtonTapped)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = Constant.Color.whiteBackground
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private let wholeButton = CustomTagButton(frame: .zero, type: .whole)
    private let politicsButton = CustomTagButton(frame: .zero, type: .politics)
    private let economyButton = CustomTagButton(frame: .zero, type: .economy)
    private let artButton = CustomTagButton(frame: .zero, type: .art)
    private let scienceButton = CustomTagButton(frame: .zero, type: .science)
    private let techButton = CustomTagButton(frame: .zero, type: .technology)
    private let healthButton = CustomTagButton(frame: .zero, type: .health)
    private let lifeButton = CustomTagButton(frame: .zero, type: .lifestyle)
    private let enterButton = CustomTagButton(frame: .zero, type: .entertainment)
    private let sportsButton = CustomTagButton(frame: .zero, type: .sports)
    private let worldButton = CustomTagButton(frame: .zero, type: .world)
    
    private let stackView = UIStackView()
    
    private lazy var journalCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewCompositionalLayout())
        view.backgroundColor = Constant.Color.whiteBackground
        return view
    }()
        
    private let wobbleAnimation = CustomWobbleAnimation()
    
    private let journalVM = JournalViewModel()
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, BookMarkedNews>!
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configDiffableDataSource()
        
        journalVM.currentTagType.bind { newTag in
            self.setupSelectedButton(newTag)
            self.journalVM.retrieveBookMarkedNewsWithTag()
        }
        
        journalVM.retrievedBookMarkedNews.bind { journals in
            var journalsInArray: Array<BookMarkedNews>
            if let journals = journals {
                journalsInArray = Array(journals)
            } else {
                journalsInArray = [BookMarkedNews]()
            }
            
            //config collectionView section with dynamic height layout
//            self.setupCollectionViewCompositionalDynamicHeightLayout(journalsInArray)
            
            //update snapshot
            self.updateSnapshot(journalsInArray)
        }
        
        journalVM.realmErrorMessage.bind { message in
            self.showErrorToastMessage(message: message)
        }
        
        journalVM.realmSucceedMessage.bind { message in
            self.showConfirmToastMessage(message: message)
        }
        
        journalVM.isEmptyView.bind { result in
            if result {
                //true: 빈 empty view 보여주기
                self.journalCollectionView.setupBackgroundNoJournalSavedEmptyView()
            } else {
                //false: 빈 empty view 숨기기
                self.journalCollectionView.restoreBackgroundFromEmptyView()
            }
        }
        
        //Notification 설정
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInJournal), name: .realmSavedSourceFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInJournal), name: .realmSavedSourceFromMediaStack, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInJournal), name: .realmSavedInSearchVCSourceFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInJournal), name: .realmSavedInSearchVCSourceFromNewsAPI, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInJournal), name: .journalSavedInMemoVCFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInJournal), name: .journalSavedInMemoVCFromMediaStack, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInJournal), name: .journalSavedInMemoVCFromNewsAPI, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInJournal), name: .realmDeletedSourceFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInJournal), name: .realmDeletedSourceFromMediaStack, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInJournal), name: .realmDeletedInSearchVCSourceFromNaver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmDeletedObserverInJournal), name: .realmDeletedInSearchVCSourceFromNewsAPI, object: nil)
        
        //처음 시작: 전체 가져오기
        journalVM.retrieveJournals()
    }
    
    override func configureViews() {
        super.configureViews()
            
        setupInitialNavBar()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        view.addSubview(realmSearchBar)
        realmSearchBar.showsCancelButton = true
        realmSearchBar.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        //전체가 가장 먼저 선택되어 있도록 하기
        wholeButton.changeToSelected()
        
        setupStackView()
        
        view.addSubview(journalCollectionView)
        journalCollectionView.delegate = self
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        realmSearchBar.snp.makeConstraints { make in
            make.top.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(realmSearchBar.snp.bottom)
            make.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(scrollView.snp.width).multipliedBy(0.05)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.height.equalTo(scrollView.snp.height)
        }
        
        journalCollectionView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.bottom.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupStackView() {
        for button in [wholeButton, politicsButton, economyButton, artButton, scienceButton, techButton, healthButton, lifeButton, enterButton, sportsButton, worldButton] {
            stackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(tagButtonTapped), for: .touchUpInside)
        }
        stackView.spacing = Constant.Frame.stackViewItemSpace
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
    }
    
    //MARK: - Setup with CollectionView Compositional Layout & Diffable DataSource
    
    private func configDiffableDataSource() {
        
        //Dynamic height cell
//        let cellRegistration = UICollectionView.CellRegistration<JournalRealmCell, BookMarkedNews> { cell, indexPath, itemIdentifier in
//            guard let journal = itemIdentifier.journal else { return }
//            cell.titleLabel.text = journal.title
//            cell.editedDateLabel.text = JournalSubDataType.editedAt.text + journal.editedAt.toString()
//            cell.tagLabel.text = journal.tags?.returnTagsInString()
//            cell.memoLabel.text = journal.content
//        }
        
        //reuse cell
        let cellRegistration = UICollectionView.CellRegistration<BookMarkedNewsCell, BookMarkedNews> { cell, indexPath, itemIdentifier in
            cell.bookmarkedNewsCellVM.bookmarkedNews.value = itemIdentifier
            cell.bookMarkButton.indexPath = indexPath
            //cell bookmark button 설정
            cell.bookMarkButton.addTarget(self, action: #selector(self.bookmarkButtonTapped), for: .touchUpInside)
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: journalCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func updateSnapshot(_ journals: [BookMarkedNews]) {
        print(#function)
        var snapshot = NSDiffableDataSourceSnapshot<Int, BookMarkedNews>()
        snapshot.appendSections([0])
        snapshot.appendItems(journals)
        diffableDataSource.apply(snapshot)
    }
    
    private func setupCollectionViewCompositionalDynamicHeightLayout(_ realmInArray: [BookMarkedNews]) {
        let ratios = journalVM.calculateRatios(contentWidth: self.view.frame.width, journals: realmInArray)

        let layout = DynamicHeightCompositionalLayout(columnsCount: Constant.Frame.journalCollectionViewRepeatingItemCount, itemRatios: ratios, spacing: Constant.Frame.journalCollectionViewSpacingForDoublePadding, contentWidth: self.view.frame.width)
        
        self.journalCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)
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
    
    //for dynamic height setup
//    private func setupCollectionViewCompositionalLayout() -> UICollectionViewLayout {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constant.Frame.journalCollectionViewItemFractionalWidth), heightDimension: .estimated(Constant.Frame.journalCollectionViewEstimatedHeight))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constant.Frame.journalCollectionViewGroupFractionalWidth), heightDimension: .estimated(Constant.Frame.journalCollectionViewEstimatedHeight))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: Constant.Frame.journalCollectionViewRepeatingItemCount)
//        group.interItemSpacing = .fixed(Constant.Frame.journalCollectionViewGroupInterItemSpace)
//
//        let section = NSCollectionLayoutSection(group: group)
//        let edgeInsets = Constant.Frame.journalCollectionViewSpacingForDoublePadding/2
//        section.contentInsets = NSDirectionalEdgeInsets(top: edgeInsets, leading: edgeInsets, bottom: edgeInsets, trailing: edgeInsets)
//        section.interGroupSpacing = Constant.Frame.journalCollectionViewInterGroupSpace
//
//        let configuration = UICollectionViewCompositionalLayoutConfiguration()
//        configuration.scrollDirection = .vertical
//
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        layout.configuration = configuration
//
//        return layout
//    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        realmSearchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let rightBarButtonItems = navigationItem.rightBarButtonItems, rightBarButtonItems.contains(cancelBarButtonItem) {
            startsWobbleAnimation()
        } else {
            stopsWobbleAnimation()
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if let rightBarButtonItems = navigationItem.rightBarButtonItems, rightBarButtonItems.contains(cancelBarButtonItem) {
            startsWobbleAnimation()
        } else {
            stopsWobbleAnimation()
        }
    }
        
    //MARK: - Handlers for Notification
    
    @objc private func notificationRealmSavedObserverInJournal(notification: Notification) {
        print(#function)
        //tag여부까지 따져서 나타내기
        journalVM.resetAndRetrieveBookMarkedNewsWithTagByNotification()
    }
    
    @objc private func notificationRealmDeletedObserverInJournal(notification: Notification) {
        print(#function)
        
        if let deletedItemLinks = notification.userInfo?[NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted] as? [String] {
            //update snapshot with bookmarkedNews excluding these links
            journalVM.retrieveBookMarkedNewsExcudingLinksWithTag(links: deletedItemLinks)
        }
    }
    
    //MARK: - Handlers for BookMarkButton
    
    @objc private func bookmarkButtonTapped(sender: CustomBookMarkButton) {
        print(#function)
        
        guard let indexPath = sender.indexPath, let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            journalVM.realmErrorMessage.value = DefaultHomeViewSetupValues.notAbleToTapBookMarkButton
            return
        }
        
        //Journal 존재 여부 확인하기
        if item.journal != nil {
            print("item title: ", item.title)
            //alert로 작동
            self.alertForRealmDeletion(title: NewsSearchSetupValues.bookmarkedRealmDeletionTitle, message: NewsSearchSetupValues.bookmarkedRealmDeletionMessage, bookMarked: item)
        } else {
            print("item without journal title: ", item.title)
            //해당 BookMarkedNews 제외한 data로 snapshot update하기
            self.journalVM.updateSnapshotBeforeUnBookMark(bookMarked: item)
    
            //제거 전에 먼저 Notification 주기: collectionview update 먼저
            switch item.apiType {
            case .naver:
                NotificationCenter.default.post(name: .realmDeletedInJournalVCSourceFromNaver, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: [item.link]])
            case .mediaStack:
                NotificationCenter.default.post(name: .realmDeletedInJournalVCSourceFromMediaStack, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: [item.link]])
            case .newsAPI:
                NotificationCenter.default.post(name: .realmDeletedInJournalVCSourceFromNewsAPI, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: [item.link]])
            }
            
            journalVM.removeBookMarkedNewsFromRealm(bookMarkedNews: item)
        }
        
    }
    
    private func alertForRealmDeletion(title: String, message: String, bookMarked: BookMarkedNews) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmToDelete = UIAlertAction(title: AlertConfirmText.deleteFromRealm, style: .destructive) { action in
            
            //해당 BookMarkedNews 제외한 data로 snapshot update하기
            self.journalVM.updateSnapshotBeforeUnBookMark(bookMarked: bookMarked)
            
            //Notification 전달
            switch bookMarked.apiType {
            case .naver:
                NotificationCenter.default.post(name: .realmDeletedInJournalVCSourceFromNaver, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: [bookMarked.link]])
            case .mediaStack:
                NotificationCenter.default.post(name: .realmDeletedInJournalVCSourceFromMediaStack, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: [bookMarked.link]])
            case .newsAPI:
                NotificationCenter.default.post(name: .realmDeletedInJournalVCSourceFromNewsAPI, object: nil, userInfo: [NotificationUserInfoName.realmBookMarkedNewsLinkToBeDeleted: [bookMarked.link]])
            }
            
            //realm에서 제거
            self.journalVM.removeBookMarkedNewsFromRealm(bookMarkedNews: bookMarked)
        }
        let cancel = UIAlertAction(title: AlertConfirmText.basicCancel, style: .cancel)
        alert.addAction(confirmToDelete)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    
    //MARK: - Handlers for TagButton
    
    @objc private func tagButtonTapped(_ sender: CustomTagButton) {
        
        realmSearchBar.resignFirstResponder()
                
        //전체 버튼 눌러야 전체 띄우기
        //각 tag 누르면 해당 tag만 나타나게 띄우기
        
        //compare with previously Tapped Tag
        if !journalVM.checkSameTagType(sender.type) {
            setupUnselectedButton()
            //different: search in realm with that tag & update Button UI
            journalVM.updateTagType(newType: sender.type)
        }
    }
    
    private func setupUnselectedButton() {
        
        switch journalVM.currentTagType.value {
        case .whole:
            wholeButton.changeToUnselected()
        case .politics:
            politicsButton.changeToUnselected()
        case .economy:
            economyButton.changeToUnselected()
        case .art:
            artButton.changeToUnselected()
        case .entertainment:
            enterButton.changeToUnselected()
        case .science:
            scienceButton.changeToUnselected()
        case .technology:
            techButton.changeToUnselected()
        case .health:
            healthButton.changeToUnselected()
        case .lifestyle:
            lifeButton.changeToUnselected()
        case .sports:
            sportsButton.changeToUnselected()
        case .world:
            worldButton.changeToUnselected()
        case .none:
            break
        }
    }
    
    private func setupSelectedButton(_ newTagType: TagType) {
        switch newTagType {
        case .whole:
            wholeButton.changeToSelected()
        case .politics:
            politicsButton.changeToSelected()
        case .economy:
            economyButton.changeToSelected()
        case .art:
            artButton.changeToSelected()
        case .entertainment:
            enterButton.changeToSelected()
        case .science:
            scienceButton.changeToSelected()
        case .technology:
            techButton.changeToSelected()
        case .health:
            healthButton.changeToSelected()
        case .lifestyle:
            lifeButton.changeToSelected()
        case .sports:
            sportsButton.changeToSelected()
        case .world:
            worldButton.changeToSelected()
        case .none:
            break
        }
    }
    
    //MARK: - Handlers for BarButtonItem
    
    @objc private func pdfButtonTapped() {
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.rightBarButtonItems = [createPDFDocumentBarButtonItem]
        setupNavBarWithCollectionViewBeforeAction()
        setupTagButtonsInactive()
        
        navigationItem.title = JournalRealmSetupValues.navTitleForPDFSelection
        navigationController?.navigationBar.prefersLargeTitles = false
                
        journalVM.retrieveOnlyBookMarkedNewsWithJournal()

        startsWobbleAnimation()
    }
    
    @objc private func deleteButtonTapped() {
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.rightBarButtonItems = [deleteConfirmBarButtonItem]
        setupNavBarWithCollectionViewBeforeAction()
        setupTagButtonsInactive()
        
        navigationItem.title = JournalRealmSetupValues.navTitleForRemovalSelection
        navigationController?.navigationBar.prefersLargeTitles = false
        
        startsWobbleAnimation()
    }
    
    @objc private func confirmDeletionButtonTapped() {
        alertToDeleteSelectedNews(title: JournalRealmSetupValues.bookmarkedNewsDeletionAlertTitle, message: JournalRealmSetupValues.bookmarkedNewsDeletionAlertMessage)
    }
    
    private func alertToDeleteSelectedNews(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmToDelete = UIAlertAction(title: AlertConfirmText.basicConfirm, style: .destructive) { action in
            
            self.stopsWobbleAnimation()
            
            //hide checkmark and reset selected status
            self.hideCheckMark()
                    
            //update snapshot (check if selected tag type exists, retrieve with tag)
            self.journalVM.updateSnapshotBeforeDeletion()
            
            //Delete objects
            self.journalVM.removeSelectedJournals()
            
            //remove selected objects in viewModel
            self.journalVM.clearSelectedJournals()
            
            self.setupNavBarWithCollectionViewAfterAction()
            self.setupInitialNavBar()
            
            //remove left
            self.navigationItem.leftBarButtonItem = nil
            
            self.setupTagButtonsActive()
            
            self.journalVM.realmSucceedMessage.value = JournalRealmSetupValues.selectedJournalDeletionSucceed
        }
        let cancel = UIAlertAction(title: AlertConfirmText.basicCancel, style: .cancel)
        alert.addAction(confirmToDelete)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @objc private func createPDFDocumentButtonTapped() {
        //hide checkmark and reset selected status
        hideCheckMark()
        
        stopsWobbleAnimation()
        
        //present PDFViewController
        let pdfVC = PDFViewController()
        pdfVC.pdfVM.documentData = journalVM.createPDFData()
        navigationController?.pushViewController(pdfVC, animated: true)
        
        //remove selected objects in viewModel
        journalVM.clearSelectedJournals()
        
        setupNavBarWithCollectionViewAfterAction()
        setupInitialNavBar()
        
        //remove left
        navigationItem.leftBarButtonItem = nil
        
        setupTagButtonsActive()
        
        //back to normal bookmarkedNews lists
        journalVM.retrieveBookMarkedNewsWithTag()
    }
    
    @objc private func cancelButtonTapped() {
        //hide checkmark and reset selected status
        hideCheckMark()
        
        stopsWobbleAnimation()
        
        //remove selected objects in viewModel
        journalVM.clearSelectedJournals()
        
        if let rightBarButtonItems = navigationItem.rightBarButtonItems, rightBarButtonItems.contains(createPDFDocumentBarButtonItem) {
            //pdf 구성 완료 후 원래대로 돌아오기
            journalVM.retrieveBookMarkedNewsWithTag()
        }
        
        setupNavBarWithCollectionViewAfterAction()
        setupInitialNavBar()
        
        //remove left
        navigationItem.leftBarButtonItem = nil
        
        setupTagButtonsActive()
    }
    
    private func startsWobbleAnimation() {
        //wobble animation starts
        journalCollectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            let cell = journalCollectionView.cellForItem(at: indexPath) as? BookMarkedNewsCell
            cell?.layer.add(wobbleAnimation, forKey: JournalRealmSetupValues.bookmarkedCellWobbleAnimationKey)
        }
    }
    
    private func stopsWobbleAnimation() {
        //wobble animation done
        journalCollectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            let cell = journalCollectionView.cellForItem(at: indexPath) as? BookMarkedNewsCell
            cell?.layer.removeAllAnimations()
        }
    }
    
    private func hideCheckMark() {
        for indexPath in journalVM.retrieveSelectedBookMarkedNews().keys {
//            let cell = journalCollectionView.cellForItem(at: indexPath) as? JournalRealmCell
            let cell = journalCollectionView.cellForItem(at: indexPath) as? BookMarkedNewsCell
            cell?.toggleCheckImage()
//            cell?.checkImage.isHidden = true
        }
    }
    
    private func setupNavBarWithCollectionViewBeforeAction() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        journalCollectionView.allowsMultipleSelection = true
        self.tabBarController?.tabBar.isHidden = true
        self.realmSearchBar.isUserInteractionEnabled = false
    }
    
    private func setupNavBarWithCollectionViewAfterAction() {
        journalCollectionView.allowsMultipleSelection = false
        self.tabBarController?.tabBar.isHidden = false
        self.realmSearchBar.isUserInteractionEnabled = true
    }
    
    private func setupInitialNavBar() {
        navigationItem.title = ViewControllerType.journalWithPinnedNews.navBarTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [pdfBarButtonItem, deleteBarButtonItem]
    }
    
    private func setupTagButtonsInactive() {
        let tagButtons = [wholeButton, politicsButton, economyButton, artButton, enterButton, scienceButton, techButton, healthButton, lifeButton, sportsButton, worldButton]
        for button in tagButtons {
            button.isUserInteractionEnabled = false
        }
    }
    
    private func setupTagButtonsActive() {
        let tagButtons = [wholeButton, politicsButton, economyButton, artButton, enterButton, scienceButton, techButton, healthButton, lifeButton, sportsButton, worldButton]
        for button in tagButtons {
            button.isUserInteractionEnabled = true
        }
    }
    
    //MARK: - Deinit
    
    deinit {
        print("deinit in journalVC")
        NotificationCenter.default.removeObserver(self, name: .realmSavedSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmSavedSourceFromMediaStack, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmSavedInSearchVCSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmSavedInSearchVCSourceFromNewsAPI, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromMediaStack, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journalSavedInMemoVCFromNewsAPI, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedSourceFromMediaStack, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedInSearchVCSourceFromNaver, object: nil)
        NotificationCenter.default.removeObserver(self, name: .realmDeletedInSearchVCSourceFromNewsAPI, object: nil)
    }
    
}

//MARK: - Extension for SearchBar Delegate

extension JournalViewController: UISearchBarDelegate {

    //검색 기준: MemoTable.content
    //빈칸인 경우, 전체 가져오기
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else {
            journalVM.retrieveBookMarkedNewsWithTag()
            return
        }
        journalVM.retrieveBookMarkedNewsWithContents(text)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let text = searchBar.text, !text.isEmpty else {
            journalVM.retrieveBookMarkedNewsWithTag()
            return
        }
        journalVM.retrieveBookMarkedNewsWithContents(text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
        
        journalVM.retrieveBookMarkedNewsWithTag()
    }
    
}


//MARK: - Extension for CollectionView Delegate

extension JournalViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            //선택할 수 없음 알리기
            showAlert(title: JournalRealmSetupValues.journalSelectionFailure, message: JournalRealmSetupValues.noJournalToBeSelected)
            return
        }
        
//        let cell = journalCollectionView.cellForItem(at: indexPath) as! JournalRealmCell
        let cell = journalCollectionView.cellForItem(at: indexPath) as! BookMarkedNewsCell
        
        if collectionView.allowsMultipleSelection {
            if cell.isSelected {
                journalVM.insertSelectedJournal(indexPath: indexPath, selected: item)
                toggleJournalCheckMark(indexPath: indexPath)
            } else {
                if journalVM.removeSelectedJournal(indexPath: indexPath, selected: item) {
                    toggleJournalCheckMark(indexPath: indexPath)
                } else {
                    journalVM.realmErrorMessage.value = JournalRealmSetupValues.noJournalToBeDeselected
                }
            }
        } else {
            //present webVC
            let webVC = WebViewController()
            webVC.webVM.objectId = item._id
            
            switch item.apiType {
            case .naver:
                webVC.webVM.updateAPITypeToNaver()
            case .mediaStack:
                webVC.webVM.updateAPITypeToMediaStack()
            case .newsAPI:
                webVC.webVM.updateAPITypeToNewsAPI()
            }
            
            self.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webVC, animated: true)
            self.hidesBottomBarWhenPushed = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if collectionView.allowsMultipleSelection {
            guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
                //선택 해제할 수 없음 알리기
                showAlert(title: "", message: JournalRealmSetupValues.noJournalToBeDeselected)
                return
            }
            
//            let cell = journalCollectionView.cellForItem(at: indexPath) as! JournalRealmCell
            let cell = journalCollectionView.cellForItem(at: indexPath) as! BookMarkedNewsCell
            
            if !cell.isSelected {
                journalVM.insertSelectedJournal(indexPath: indexPath, selected: item)
                toggleJournalCheckMark(indexPath: indexPath)
            } else {
                if journalVM.removeSelectedJournal(indexPath: indexPath, selected: item) {
                    toggleJournalCheckMark(indexPath: indexPath)
                } else {
                    journalVM.realmErrorMessage.value = JournalRealmSetupValues.noJournalToBeDeselected
                }
            }
        }
    }
    
    private func toggleJournalCheckMark(indexPath: IndexPath) {
//        let cell = journalCollectionView.cellForItem(at: indexPath) as? JournalRealmCell
        let cell = journalCollectionView.cellForItem(at: indexPath) as? BookMarkedNewsCell
        cell?.toggleCheckImage()
        
        navigationItem.rightBarButtonItem?.isEnabled = journalVM.checkSelectedJournalsEmpty() ? false : true
    }
    
}
