import RxComposableArchitecture

public struct Todo: Equatable {
  var title: String
  var done: Bool
}
extension Todo {
  static let mock = Todo(title: "Some todo item", done: false)
}

public struct TodoListState: Equatable {
  var todos: [Todo]

  public init(todos: [Todo]) {
    self.todos = todos
  }
}
extension TodoListState {
  public static let mock = TodoListState(todos: [
    Todo(title: "Todo item 1", done: false),
    Todo(title: "Todo item 2", done: false),
    Todo(title: "Todo item 3", done: true),
    Todo(title: "Todo item 4", done: false)
    ]
  )
}

public enum TodoListAction: Equatable {
  case toggle(Todo)
}

public struct TodoListEnvironment {
  public init() {}
}

public let todoListReducer: Reducer<TodoListState, TodoListAction, TodoListEnvironment> = { state, action, env in
  switch action {
  case let .toggle(todo):
    guard let index = state.todos.firstIndex(of: todo) else { return [] }
    state.todos[index].done.toggle()
    return []
  }
}
