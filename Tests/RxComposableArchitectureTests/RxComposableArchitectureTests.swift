import CasePaths
import XCTest
@testable import RxComposableArchitecture

final class RxComposableArchitectureTests: XCTestCase {
  struct GlobalState: Equatable { var local: LocalState = "" }
  typealias LocalState = String

  enum GlobalAction {
    case globalAppend(Character), local(LocalAction)
    var local: LocalAction? {
      get {
        guard case let .local(value) = self else { return nil }
        return value
      }
      set {
        guard let newValue = newValue, case .local = self else { return }
        self = .local(newValue)
      }
    }
  }
  enum LocalAction { case apend(Character) }

  struct GlobalEnvironment { var local: LocalEnvironment = .init() }
  struct LocalEnvironment {}

  let globalReducer: Reducer<GlobalState, GlobalAction, GlobalEnvironment> = { state, action, _ in
    switch action {
    case let .globalAppend(char):
      state.local.append(char)
      return []
    case .local:
      state.local.append("-")
      return []
    }
  }
  let localReducer: Reducer<LocalState, LocalAction, LocalEnvironment> = { state, action, _ in
    switch action {
    case let .apend(char):
      state.append(char)
      return []
    }
  }

  func testLocalStoreIsNotifiedFromGlobalStoreWhenGlobalActionIsReceived() {
    let globalStore = Store<GlobalState, GlobalAction>(
      initialValue: GlobalState(),
      reducer: combine(globalReducer, pullback(
        localReducer,
        value: \.local,
        action: /GlobalAction.local,
        environment: { $0.local }
      )),
      environment: GlobalEnvironment())
    let localStore = globalStore.view(value: { $0.local }, action: { .local($0) })

    var states: [LocalState] = []
    _ = localStore.observableValue.subscribe(onNext: { states.append($0) })

    globalStore.send(.globalAppend("a"))
    XCTAssertEqual(states, ["", "a"])
  }

  func testLocalStoreDoesntLeak() {
    var localStoreDeinitialized = false
    let globalStore = Store<GlobalState, GlobalAction>(
      initialValue: GlobalState(),
      reducer: combine(globalReducer, pullback(
        localReducer,
        value: \.local,
        action: /GlobalAction.local,
        environment: { $0.local }
      )),
      environment: GlobalEnvironment())
    var localStore: Store<LocalState, LocalAction>? = globalStore.view(
      value: { $0.local },
      action: { .local($0) }
    )
    localStore?._onDeinit = { localStoreDeinitialized = true }
    globalStore.send(.globalAppend("a"))
    _ = localStore?.observableValue.subscribe()

    localStore = nil
    XCTAssertTrue(localStoreDeinitialized)
  }

  func testGlobalStoreIsUpdatedWhenLocalActionIsReceived() {
    let globalStore = Store<GlobalState, GlobalAction>(
      initialValue: GlobalState(),
      reducer: combine(globalReducer, pullback(
        localReducer,
        value: \.local,
        action: /GlobalAction.local,
        environment: { $0.local }
      )),
      environment: GlobalEnvironment())
    var states: [GlobalState] = []
    _ = globalStore.observableValue.subscribe(onNext: { states.append($0) })
    let localStore = globalStore.view(value: { $0.local }, action: { .local($0) })

    localStore.send(.apend("a"))
    XCTAssertEqual(states, [GlobalState(local: ""), GlobalState(local: "-a")])
  }
}
