import 'package:collection/collection.dart';

sealed class Lce<T> {
  factory Lce.content(T content) => LceContent._(content);

  factory Lce.loading() => const LceLoading();

  factory Lce.error(Exception error) => LceError._(error);
}

extension Mappers<T> on Lce<T> {
  R? maybeMap<R>({
    R Function(T)? content,
    R Function()? loading,
    R Function(Exception)? error,
  }) {
    if (this is LceContent<T>) {
      return content?.call((this as LceContent<T>).data);
    } else if (this is LceLoading<T>) {
      return loading?.call();
    } else if (this is LceError<T>) {
      return error?.call((this as LceError<T>).error);
    }
    return null;
  }

  R? withData<R>(R Function(T) fn) {
    if (this is LceContent<T>) {
      return fn((this as LceContent<T>).data);
    }
    return null;
  }
}

class LceContent<T> implements Lce<T> {
  LceContent._(this.data);

  final T data;

  @override
  bool operator ==(dynamic other) {
    if (other is! LceContent<T>) {
      return false;
    }

    // Compare list
    if (other.data is List && data is List) {
      return const ListEquality().equals(other.data as List, data as List);
    }

    // Compare map
    if (other.data is Map && data is Map) {
      return const DeepCollectionEquality()
          .equals(other.data as Map, data as Map);
    }

    return other.data == data;
  }

  @override
  String toString() => 'LceContent(data: $data)';

  @override
  int get hashCode => T.hashCode;
}

class LceLoading<T> implements Lce<T> {
  const LceLoading();

  @override
  bool operator ==(dynamic other) => other is LceLoading<T>;

  @override
  int get hashCode => true.hashCode;
}

class LceError<T> implements Lce<T> {
  final Exception error;

  const LceError._(this.error);

  @override
  bool operator ==(dynamic other) {
    return other is LceError<T> && other.error.toString() == error.toString();
  }

  @override
  String toString() => 'ResultError(error: ${error.toString()})';

  @override
  int get hashCode => error.hashCode;
}
