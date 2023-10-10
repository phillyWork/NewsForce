//
//  NewMemoViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/09/30.
//

import UIKit

final class JournalViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let realmSearchBar: CustomSearchBar = {
        let bar = CustomSearchBar()
        bar.placeholder = ViewControllerType.journalVC.searchBarPlaceholder
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
    
    private let journalVM = JournalViewModel()
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, Journal>!
    
    //MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configDiffableDataSource()
        
        journalVM.currentTagType.bind { newTag in
            self.setupSelectedButton(newTag)
        }
        
        journalVM.retrievedJournals.bind { journals in
            var journalsInArray: Array<Journal>
            if let journals = journals {
                journalsInArray = Array(journals)
            } else {
                journalsInArray = [Journal]()
            }
            //config collectionView section with dynamic height layout
            self.setupCollectionViewCompositionalDynamicHeightLayout(journalsInArray)
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
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRealmSavedObserverInJournal), name: .realmSaved, object: nil)
        
        //처음 시작: 전체 가져오기
        journalVM.retrieveJournals()
    }
    
    override func configureViews() {
        super.configureViews()
        
        navigationItem.titleView = realmSearchBar
        realmSearchBar.delegate = self
        
        setupInitialNavBar()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        setupStackView()
        
        view.addSubview(journalCollectionView)
        journalCollectionView.delegate = self
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        scrollView.snp.makeConstraints { make in
            make.top.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide)
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
        for button in [politicsButton, economyButton, artButton, scienceButton, techButton, healthButton, lifeButton, enterButton, sportsButton, worldButton] {
            stackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(tagButtonTapped), for: .touchUpInside)
        }
        stackView.spacing = Constant.Frame.stackViewItemSpace
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
    }
    
    //MARK: - Setup with CollectionView Compositional Layout & Diffable DataSource
    
    private func configDiffableDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<JournalRealmCell, Journal> { cell, indexPath, itemIdentifier in
            guard let memo = itemIdentifier.memo else { return }
            cell.titleLabel.text = memo.title
            cell.editedDateLabel.text = JournalSubDataType.editedAt.text + memo.editedAt.toString()
            cell.tagLabel.text = memo.tags?.returnTagsInString()
            cell.memoLabel.text = memo.content
        }
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: journalCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
    }
    
    private func updateSnapshot(_ journals: [Journal]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Journal>()
        snapshot.appendSections([0])
        snapshot.appendItems(journals)
        diffableDataSource.apply(snapshot)
    }
    
    private func setupCollectionViewCompositionalDynamicHeightLayout(_ realmInArray: [Journal]) {
        let ratios = journalVM.calculateRatios(contentWidth: self.view.frame.width, journals: realmInArray)

        let layout = DynamicHeightCompositionalLayout(columnsCount: Constant.Frame.journalCollectionViewRepeatingItemCount, itemRatios: ratios, spacing: Constant.Frame.journalCollectionViewSpacingForDoublePadding, contentWidth: self.view.frame.width)
        
        self.journalCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)
    }
    
    private func setupCollectionViewCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constant.Frame.journalCollectionViewItemFractionalWidth), heightDimension: .estimated(Constant.Frame.journalCollectionViewEstimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Constant.Frame.journalCollectionViewGroupFractionalWidth), heightDimension: .estimated(Constant.Frame.journalCollectionViewEstimatedHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: Constant.Frame.journalCollectionViewRepeatingItemCount)
        group.interItemSpacing = .fixed(Constant.Frame.journalCollectionViewGroupInterItemSpace)
        
        let section = NSCollectionLayoutSection(group: group)
        let edgeInsets = Constant.Frame.journalCollectionViewSpacingForDoublePadding/2
        section.contentInsets = NSDirectionalEdgeInsets(top: edgeInsets, leading: edgeInsets, bottom: edgeInsets, trailing: edgeInsets)
        section.interGroupSpacing = Constant.Frame.journalCollectionViewInterGroupSpace
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration = configuration
        
        return layout
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        realmSearchBar.resignFirstResponder()
    }
        
    //MARK: - Handlers for Notification
    
    @objc private func notificationRealmSavedObserverInJournal(notification: Notification) {
        //tag여부까지 따져서 나타내기
        journalVM.retrieveJournalsWithTag()
    }
    
    //MARK: - Handlers for TagButton
    
    @objc private func tagButtonTapped(_ sender: CustomTagButton) {
        
        realmSearchBar.resignFirstResponder()
        
        setupUnselectedButton()
        
        //compare with previously Tapped Tag
        if journalVM.checkSameTagType(sender.type) {
            //same: 전체 보여주기 (해당 tag 설정 해제하기)
            journalVM.resetTagType()
        } else {
            //different: search in realm with that tag & update Button UI
            journalVM.updateTagType(newType: sender.type)
        }
        
        journalVM.retrieveJournalsWithTag()
    }
    
    private func setupUnselectedButton() {
        
        switch journalVM.currentTagType.value {
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
            //아직 tag 선택하지 않음
            break
        }
    }
    
    private func setupSelectedButton(_ newTagType: TagType) {
        switch newTagType {
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
        navigationItem.rightBarButtonItem = createPDFDocumentBarButtonItem
        navigationItem.leftBarButtonItem = cancelBarButtonItem

        setupNavBarWithCollectionViewBeforeAction()
        setupTagButtonsInactive()
    }
    
    @objc private func deleteButtonTapped() {
        navigationItem.rightBarButtonItem = deleteConfirmBarButtonItem
        navigationItem.leftBarButtonItem = cancelBarButtonItem

        setupNavBarWithCollectionViewBeforeAction()
        setupTagButtonsInactive()
    }
    
    @objc private func confirmDeletionButtonTapped() {
        //hide checkmark and reset selected status
        hideCheckMark()
                
        //update snapshot (check if selected tag type exists, retrieve with tag)
        journalVM.updateSnapshotBeforeDeletion()
        
        //Delete objects
        journalVM.removeSelectedJournals()
        
        //remove selected objects in viewModel
        journalVM.clearSelectedJournals()
        
        setupNavBarWithCollectionViewAfterAction()
        setupInitialNavBar()
        setupTagButtonsActive()
        
        journalVM.realmSucceedMessage.value = JournalRealmSetupValues.selectedJournalDeletionSucceed
    }
    
    @objc private func createPDFDocumentButtonTapped() {
        //hide checkmark and reset selected status
        hideCheckMark()
        
        //present PDFViewController
        let pdfVC = PDFViewController()
        pdfVC.pdfVM.documentData = journalVM.createPDFData()
        navigationController?.pushViewController(pdfVC, animated: true)
        
        //remove selected objects in viewModel
        journalVM.clearSelectedJournals()
        
        setupNavBarWithCollectionViewAfterAction()
        setupInitialNavBar()
        setupTagButtonsActive()
    }
    
    @objc private func cancelButtonTapped() {
        //hide checkmark and reset selected status
        hideCheckMark()
        
        //remove selected objects in viewModel
        journalVM.clearSelectedJournals()
        
        setupNavBarWithCollectionViewAfterAction()
        setupInitialNavBar()
        setupTagButtonsActive()
    }
    
    private func hideCheckMark() {
        for indexPath in journalVM.retrieveSelectedJournals().keys {
            let cell = journalCollectionView.cellForItem(at: indexPath) as? JournalRealmCell
            cell?.checkImage.isHidden = true
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
        navigationItem.rightBarButtonItem = pdfBarButtonItem
        navigationItem.leftBarButtonItem = deleteBarButtonItem
    }
    
    private func setupTagButtonsInactive() {
        let tagButtons = [politicsButton, economyButton, artButton, enterButton, scienceButton, techButton, healthButton, lifeButton, sportsButton, worldButton]
        for button in tagButtons {
            button.isUserInteractionEnabled = false
        }
    }
    
    private func setupTagButtonsActive() {
        let tagButtons = [politicsButton, economyButton, artButton, enterButton, scienceButton, techButton, healthButton, lifeButton, sportsButton, worldButton]
        for button in tagButtons {
            button.isUserInteractionEnabled = true
        }
    }
    
    //MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .realmSaved, object: nil)
    }
    
}

//MARK: - Extension for SearchBar Delegate

extension JournalViewController: UISearchBarDelegate {

    //검색 기준: MemoTable.content
    //빈칸인 경우, 전체 가져오기
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, !text.isEmpty else {
            journalVM.retrieveJournalsWithTag()
            return
        }
        journalVM.retrieveJournalsWithMemo(text)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let text = searchBar.text, !text.isEmpty else {
            journalVM.retrieveJournalsWithTag()
            return
        }
        journalVM.retrieveJournalsWithMemo(text)
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
        
        let cell = journalCollectionView.cellForItem(at: indexPath) as! JournalRealmCell
        
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
            webVC.webVM.updateCurrentVCType(newType: .journalVC)
            
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
            
            let cell = journalCollectionView.cellForItem(at: indexPath) as! JournalRealmCell
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
        let cell = journalCollectionView.cellForItem(at: indexPath) as? JournalRealmCell
        cell?.checkImage.isHidden.toggle()
        
        navigationItem.rightBarButtonItem?.isEnabled = journalVM.checkSelectedJournalsEmpty() ? false : true
    }
    
}
