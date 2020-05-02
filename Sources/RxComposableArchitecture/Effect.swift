import RxSwift

public struct Effect<A> {
  private let _source: Observable<A>
  fileprivate init(source: Observable<A>) {
    _source = source
  }

  // MARK: - Public API

  public enum Event { case next(A), completed }

  public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.Element == Element {
    return _source.subscribe(observer)
  }

  public func subscribe(_ on: @escaping (Event) -> Void) -> Disposable {
    _source.subscribe { (event) in
      switch event {
      case let .next(a):
        on(.next(a))
      case let .error(error):
        Self._onError(error)
      case .completed:
        on(.completed)
      }
    }
  }

  public func subscribe(
    onNext: ((Element) -> Void)? = nil,
    onCompleted: (() -> Void)? = nil,
    onDisposed: (() -> Void)? = nil
  ) -> Disposable {
    return _source.subscribe(
      onNext: onNext,
      onError: Self._onError,
      onCompleted: onCompleted,
      onDisposed: onDisposed
    )
  }

  public init(_ work: @escaping (@escaping (A) -> Void) -> Void) {
    self.init(source: Observable.create { observer -> Disposable in
      work { a in
        observer.onNext(a)
        observer.onCompleted()
      }
      return Disposables.create()
    })
  }

  public static func pure(_ a: A) -> Effect<A> {
    Effect<A> { callback in
      callback(a)
    }
  }

  public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
    Effect<B>(source: _source.map(f))
  }

  public func flatMap<B>(_ f: @escaping (A) -> Effect<B>) -> Effect<B> {
    Effect<B>(source: _source.flatMap(f))
  }

  public func observeOn(_ scheduler: ImmediateSchedulerType) -> Effect {
    Effect(source: _source.observeOn(scheduler))
  }

  public func `do`(
    onNext: ((Self.Element) throws -> Void)? = nil,
    onCompleted: (() throws -> Void)? = nil,
    onSubscribe: (() -> Void)? = nil,
    onSubscribed: (() -> Void)? = nil,
    onDispose: (() -> Void)? = nil
  ) -> Effect {
    Effect(source: _source.do(
      onNext: onNext,
      onError: Self._onError,
      onCompleted: onCompleted,
      onSubscribe: onSubscribe,
      onSubscribed: onSubscribed,
      onDispose: onDispose
    ))
  }
  public func delay(_ delay: RxTimeInterval, scheduler: SchedulerType) -> Effect {
    Effect(source: _source.delay(delay, scheduler: scheduler))
  }

  private static func _onError(_ error: Swift.Error) {
    fatalError("Somehow Effect received error from a source that shouldn't fail. Error: \(error)")
  }
}

extension Effect: ObservableConvertibleType {
  public func asObservable() -> Observable<A> {
    return _source
  }
}

extension Effect where A == Never {
  private init(_ work: @escaping () -> Void) {
    self.init(source: .create { observer -> Disposable in
      work()
      observer.onCompleted()
      return Disposables.create()
      })
  }
}

extension Effect {
  public static func neverReturn(_ work: @escaping () -> Void) -> Effect {
    func absurd<A>(_ x: Never) -> A {}
    return Effect<Never>(work).map(absurd)
  }
}
/*
import RxCocoa

extension SharedSequenceConvertibleType {
  public func asEffect() -> Effect<E> {
    return Effect(source: self.asObservable())
  }
}
*/
