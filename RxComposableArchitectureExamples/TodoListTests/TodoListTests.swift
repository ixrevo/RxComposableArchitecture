import RxComposableArchitecture
import RxComposableArchitectureTestSupport
import SnapshotTesting
import XCTest
@testable import TodoList

class TodoListTests: XCTestCase {
  func testToggleTodo() {
    assert(
      initialValue: TodoListState.mock,
      reducer: todoListReducer,
      environment: TodoListEnvironment(),
      steps: Step(StepType.send, .toggle(TodoListState.mock.todos[2])) {
        $0.todos[2].done.toggle()
      }
    )
  }
  func testSnapshot() {
    let store = Store<TodoListState, TodoListAction>(
      initialValue: TodoListState.mock,
      reducer: todoListReducer,
      environment: TodoListEnvironment()
    )
    let vc = TodoListViewController(store: store)
    let nc = UINavigationController(rootViewController: vc)
    assertSnapshot(matching: nc, as: .image(on: .iPhoneX))
  }
}
