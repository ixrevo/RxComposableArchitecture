import CasePaths
import RxComposableArchitecture
import TodoList

enum Example { case todoList, primeTime }

struct AppState {
  var examples: [Example]
  var currentExample: Example?
  var todoList: TodoListState
}
extension AppState {
  init() {
    examples = [.primeTime, .todoList]
    currentExample = nil
    todoList = TodoListState.mock
  }
}
enum AppAction {
  case todoList(TodoListAction)
}
struct AppEnvironment {
  var todoList: TodoListEnvironment
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = pullback(
  todoListReducer,
  value: \AppState.todoList,
  action: /AppAction.todoList,
  environment: { $0.todoList }
)
