import UIKit
import RxSwift
import RxDataSources

import RxComposableArchitecture

public class TodoListViewController: UIViewController {
  private let _store: Store<TodoListState, TodoListAction>
  private var _todos: [Todo] = []
  private let _tableView = UITableView()
  private var _dataSource: RxTableViewSectionedAnimatedDataSource<Section>!
  private let _bag = DisposeBag()

  override public func viewDidLoad() {
    super.viewDidLoad()

    title = "Todo List"

    _setupTableViewLayout()

    _tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

    _dataSource = RxTableViewSectionedAnimatedDataSource(configureCell: { ds, tv, _, item in
      let cell = tv.dequeueReusableCell(withIdentifier: "UITableViewCell")
        ?? UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")

      let text: String
      if item.done {
        text = "✓ \(item.title)"
      } else {
        text = item.title
      }

      cell.textLabel?.text = text

      return cell
    }, titleForHeaderInSection: { ds, index in
      return ds.sectionModels[index].header
    }
    )

    _store.observableValue
      .map { [Section(header: "", items: $0.todos)] }
      .bind(to: _tableView.rx.items(dataSource: _dataSource))
      .disposed(by: _bag)

    _tableView.rx.setDelegate(self)
      .disposed(by: _bag)

    _tableView.rx
      .modelSelected(Todo.self)
      .map(TodoListAction.toggle)
      .bind { [weak _store] in _store?.send($0) }
      .disposed(by: _bag)
  }

  public init(store: Store<TodoListState, TodoListAction>) {
    _store = store
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func _setupTableViewLayout() {
    _tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(_tableView)
    view.topAnchor.constraint(equalTo: _tableView.topAnchor).isActive = true
    view.bottomAnchor.constraint(equalTo: _tableView.bottomAnchor).isActive = true
    view.leadingAnchor.constraint(equalTo: _tableView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: _tableView.trailingAnchor).isActive = true
  }
}

extension TodoListViewController {
  struct Section {
    var header: String
    var items: [Todo]
  }
}

extension TodoListViewController.Section: AnimatableSectionModelType {
  var identity: String { header }
  init(original:TodoListViewController.Section, items: [Todo]) {
    self = original
    self.items = items
  }
}

extension Todo: IdentifiableType {
  public var identity: String { title }
}

extension TodoListViewController: UITableViewDelegate {}
