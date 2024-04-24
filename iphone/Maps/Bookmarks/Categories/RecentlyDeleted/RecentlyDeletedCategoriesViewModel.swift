final class RecentlyDeletedCategoriesViewModel {

  enum Section: CaseIterable {
    struct Model {
      let title: String
      let categories: [Category]
    }

    case onDevice
    case iCloud
  }

  struct Category {
    let fileName: String
    let fileURL: URL
    let deletionDate: TimeInterval
  }

  enum State {
    case normal
    case searching
    case editingAndNothingSelected
    case editingAndSomeSelected
  }

  private var bookmarksManager: BookmarksManager
  private var dataSource: [Section.Model] = []
  var filteredDataSource: [Section.Model] = []
  var selectedIndexPaths: [IndexPath] = []
  var state: State = .normal {
    didSet {
      stateDidChange?(state)
    }
  }

  var stateDidChange: ((State) -> Void)?
  var filteredDataSourceDidChange: (([Section.Model]) -> Void)?

  init(bookmarksManager: BookmarksManager = BookmarksManager.shared()) {
    self.bookmarksManager = bookmarksManager
    fetchRecentlyDeletedCategories()
  }

  private func fetchRecentlyDeletedCategories() {
    Section.allCases.forEach {
      let content = getContentForSection($0)
      guard !content.categories.isEmpty else { return }
      dataSource.append(content)
    }
    filteredDataSource = dataSource
  }

  private func getContentForSection(_ section: Section) -> Section.Model {
    let categories: [Category]
    switch section {
    case .onDevice:
      let recentlyDeletedCategoryURLs = bookmarksManager.getRecentlyDeletedCategories()
      categories = recentlyDeletedCategoryURLs.map { fileUrl in
        let fileName = fileUrl.lastPathComponent
        // TODO: remove force unwraps
        let deletionDate = try! fileUrl.resourceValues(forKeys: [.creationDateKey]).creationDate!.timeIntervalSince1970
        return Category(fileName: fileName, fileURL: fileUrl, deletionDate: deletionDate)
      }
    case .iCloud:
      categories = []
    }
    return Section.Model(title: section.title, categories: categories)
  }

  func toggleEditing() {
    let newEditingState = (state == .normal) ? State.editingAndNothingSelected : .normal
    state = newEditingState
  }

  func updateSelectionAtIndexPath(_ indexPath: IndexPath, isSelected: Bool) {
    if isSelected {
      state = .editingAndSomeSelected
    } else {
      let allDeselected = dataSource.allSatisfy { $0.categories.isEmpty }
      state = allDeselected ? .editingAndNothingSelected : .editingAndSomeSelected
    }
  }
}

extension RecentlyDeletedCategoriesViewModel {
  func deleteCategory(at indexPath: IndexPath) {
    
  }

  func deleteAllCategories() {

  }

  func recoverCategory(at indexPath: IndexPath) {

  }

  func selectCategory(at indexPath: IndexPath) {
    selectedIndexPaths.append(indexPath)
  }

  func deselectCategory(at indexPath: IndexPath) {
    selectedIndexPaths.removeAll { $0 == indexPath }
  }

  func cancelSearch() {
    selectedIndexPaths.removeAll()
    filteredDataSource = dataSource
    filteredDataSourceDidChange?(filteredDataSource)
  }

  func search(_ searchText: String) {
    let filteredCategories = dataSource.map { section in
      let filteredCategories = section.categories.filter { $0.fileName.localizedCaseInsensitiveContains(searchText) }
      return Section.Model(title: section.title, categories: filteredCategories)
    }
    filteredDataSource = filteredCategories.filter { !$0.categories.isEmpty }
    filteredDataSourceDidChange?(filteredDataSource)
  }
}

// TODO: localize
private extension RecentlyDeletedCategoriesViewModel.Section {
  var title: String {
    switch self {
    case .onDevice:
      return L("on_device")
    case .iCloud:
      return L("iCloud")
    }
  }
}
