import RxSwift
import RxRelay
import CasePaths

public final class Store<Value, Action> {
  private let _reducer: Reducer<Value, Action, Any>
  private let _environment: Any
  private let _value: BehaviorRelay<Value>
  public private(set) var value: Value {
    get { _value.value }
    set { _value.accept(newValue) }
  }
  public var observableValue: Observable<Value> { _value.asObservable() }
  private let _bag = DisposeBag()

  public init<Environment>(
    initialValue: Value,
    reducer: @escaping Reducer<Value, Action, Environment>,
    environment: Environment
  ) {
    _reducer = { value, action, environment in
      reducer(&value, action, environment as! Environment)
    }
    _value = BehaviorRelay<Value>(value: initialValue)
    _environment = environment
  }

  public func send(_ action: Action) {
    let effects = self._reducer(&self.value, action, self._environment)
    effects.forEach { effect in
      effect
        .subscribe(onNext: { [weak self] in self?.send($0) })
        .disposed(by: _bag)
    }
  }

  public func view<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(self.value),
      reducer: { localValue, localAction, _ in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return []
    },
      environment: self._environment
    )
    self._value
      .map(toLocalValue)
      .subscribe(onNext: { [weak localStore] in localStore?.value = $0 })
      .disposed(by: _bag)
    return localStore
  }
  #if DEBUG
  var _onDeinit: (() -> Void)?
  deinit { _onDeinit?() }
  #endif
}
