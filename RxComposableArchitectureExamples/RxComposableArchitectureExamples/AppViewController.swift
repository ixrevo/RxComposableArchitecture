import UIKit
import RxSwift
import RxDataSources

import TodoList
import RxComposableArchitecture

class AppViewController: UIViewController {
  private let _store: Store<AppState, AppAction>
  private let _tableView = UITableView()
  typealias Section = SectionModel<Void, Example>
  private var _dataSource: RxTableViewSectionedReloadDataSource<Section>!
  private let _bag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    _setupTableViewLayout()
    // https://github.com/ReactiveX/RxSwift/pull/2076
    // Remove async after the issue is resolved.
    DispatchQueue.main.async { self._setupTableView() }
  }

  init(store: Store<AppState, AppAction>) {
    _store = store
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func _setupTableViewLayout() {
    view.addSubview(_tableView)
    _tableView.translatesAutoresizingMaskIntoConstraints = false
    view.topAnchor.constraint(equalTo: _tableView.topAnchor).isActive = true
    view.bottomAnchor.constraint(equalTo: _tableView.bottomAnchor).isActive = true
    view.leadingAnchor.constraint(equalTo: _tableView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: _tableView.trailingAnchor).isActive = true
  }
  private func _setupTableView() {
    _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

    _dataSource = RxTableViewSectionedReloadDataSource(configureCell: { ds, tv, _, item in
      let cell = tv.dequeueReusableCell(withIdentifier: "UITableViewCell")
        ?? UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
      switch item {
      case .todoList:
        cell.textLabel?.text = "Todo List"
      case .primeTime:
        cell.textLabel?.text = "Prime Time"
      }
      return cell
    })

    _store.observableValue
      .map { [Section.init(model: (), items: $0.examples)] }
      .bind(to: _tableView.rx.items(dataSource: _dataSource))
      .disposed(by: _bag)

    _tableView.rx.setDelegate(self)
      .disposed(by: _bag)

    _tableView.rx
      .modelSelected(Example.self)
      .bind { [weak self] in
        guard let self = self else { return }
        switch $0 {
        case .todoList:
          let vc = TodoListViewController(
            store: self._store.view(value: { $0.todoList } ,action: AppAction.todoList)
          )
          self.navigationController?.pushViewController(vc, animated: true)
        case .primeTime:
          fatalError("Unimplemented")
        }
    }
    .disposed(by: _bag)
  }
}
extension AppViewController: UITableViewDelegate {}
