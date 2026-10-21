enum LoadStatus { initial, loading, data, error }

class AsyncState<T> {
  const AsyncState._(this.status, {this.value, this.error});

  const AsyncState.initial() : this._(LoadStatus.initial);
  const AsyncState.loading() : this._(LoadStatus.loading);
  const AsyncState.data(T value) : this._(LoadStatus.data, value: value);
  const AsyncState.error(Object error) : this._(LoadStatus.error, error: error);

  final LoadStatus status;
  final T? value;
  final Object? error;
}
