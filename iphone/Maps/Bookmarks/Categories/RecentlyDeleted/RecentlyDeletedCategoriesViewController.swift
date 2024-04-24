

final class RecentlyDeletedCategoriesViewController: MWMTableViewController {

  private lazy var editButton = UIBarButtonItem(title: L("edit"), style: .done, target: self, action: #selector(editButtonDidTap))
  private lazy var recoverButton = UIBarButtonItem(title: L("recover"), style: .done, target: self, action: #selector(recoverButtonDidTap))
  private lazy var deleteButton = UIBarButtonItem(title: L("delete"), style: .done, target: self, action: #selector(deleteButtonDidTap))
  private let searchController = UISearchController(searchResultsController: nil)
  private let viewModel: RecentlyDeletedCategoriesViewModel

  init(viewModel: RecentlyDeletedCategoriesViewModel = RecentlyDeletedCategoriesViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)

    viewModel.stateDidChange = { [weak self] state in
      self?.updateState(state)
    }
    viewModel.filteredDataSourceDidChange = { [weak self] dataSource in
      self?.tableView.reloadData()
    }
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  private func setupView() {
    setupNavigationBar()
    setupToolBar()
    setupSearchBar()
    setupTableView()
  }

  private func setupNavigationBar() {
    title = L("bookmarks_recently_deleted")
    navigationItem.rightBarButtonItem = editButton
  }

  private func setupToolBar() {
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolbarItems = [flexibleSpace, recoverButton, flexibleSpace, deleteButton, flexibleSpace]
    navigationController?.isToolbarHidden = true
  }

  private func setupSearchBar() {
    searchController.searchBar.placeholder = L("search_in_the_list")
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = alternativeSizeClass(iPhone: true, iPad: false)
    searchController.searchBar.delegate = self
    searchController.searchBar.applyTheme()
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }

  private func setupTableView() {
    tableView.allowsMultipleSelectionDuringEditing = true
    tableView.register(cell: RecentlyDeletedTableViewCell.self)
  }

  private func updateState(_ state: RecentlyDeletedCategoriesViewModel.State) {
    switch state {
    case .normal:
      tableView.setEditing(false, animated: true)
      navigationController?.setToolbarHidden(true, animated: true)
      editButton.title = L("edit")
      searchController.searchBar.isUserInteractionEnabled = true
    case .searching:
      tableView.setEditing(false, animated: true)
      navigationController?.setToolbarHidden(true, animated: true)
      editButton.title = L("edit")
      searchController.searchBar.isUserInteractionEnabled = true
    case .editingAndNothingSelected:
      tableView.setEditing(true, animated: true)
      navigationController?.setToolbarHidden(false, animated: true)
      editButton.title = L("done")
      recoverButton.title = L("recover_all")
      deleteButton.title = L("delete_all")
      searchController.searchBar.isUserInteractionEnabled = false
    case .editingAndSomeSelected:
      recoverButton.title = L("recover")
      deleteButton.title = L("delete")
      searchController.searchBar.isUserInteractionEnabled = false
    }
  }


  // MARK: - Actions
  @objc private func editButtonDidTap() {
    tableView.setEditing(!tableView.isEditing, animated: true)
    viewModel.state = tableView.isEditing ? .editingAndNothingSelected : .normal
  }

  @objc private func recoverButtonDidTap() {
    print(#function)
//    guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return }
//    selectedIndexPaths.forEach { indexPath in
//      let category = dataSource[indexPath.section].categories[indexPath.row]
//      bookmarksManager.recoverRecentlyDeletedCategory(at: category.fileURL)
//    }
//    fetchRecentlyDeletedCategories()
//    tableView.reloadData()
  }

  @objc private func deleteButtonDidTap() {
    print(#function)
//    guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return }
//    selectedIndexPaths.forEach { indexPath in
//      let category = dataSource[indexPath.section].categories[indexPath.row]
//      bookmarksManager.deleteRecentlyDeletedCategory(at: category.fileURL)
//    }
//    fetchRecentlyDeletedCategories()
//    tableView.reloadData()
  }

  // MARK: - UITableViewDataSource & UITableViewDelegate
  override func numberOfSections(in tableView: UITableView) -> Int {
    viewModel.filteredDataSource.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    viewModel.filteredDataSource[section].title
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.filteredDataSource[section].categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(cell: RecentlyDeletedTableViewCell.self, indexPath: indexPath)
    let category = viewModel.filteredDataSource[indexPath.section].categories[indexPath.row]
    cell.configureWith(category)
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard tableView.isEditing else {
      tableView.deselectRow(at: indexPath, animated: true)
      return
    }
    viewModel.state = .editingAndSomeSelected
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard tableView.isEditing else { return }
    guard let selectedIndexPaths = tableView.indexPathsForSelectedRows, selectedIndexPaths.isEmpty else {
      viewModel.state = .editingAndNothingSelected
      return
    }
    viewModel.state = .editingAndSomeSelected
  }

  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: L("delete")) { [weak self] (_, _, completion) in
      self?.viewModel.deleteCategory(at: indexPath)
      completion(true)
    }
    // TODO: localize recover
    let recoverAction = UIContextualAction(style: .normal, title: L("recover")) { [weak self] (_, _, completion) in
      self?.viewModel.recoverCategory(at: indexPath)
      completion(true)
    }
    return UISwipeActionsConfiguration(actions: [deleteAction, recoverAction])
  }
}

// MARK: - UISearchBarDelegate
extension RecentlyDeletedCategoriesViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
    viewModel.state = .searching
  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(false, animated: true)
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.resignFirstResponder()
    viewModel.cancelSearch()
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    guard !searchText.isEmpty else {
      viewModel.cancelSearch()
      return
    }
    viewModel.search(searchText)
  }
}
