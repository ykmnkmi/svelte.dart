import 'dart:collection' show Queue;

import '../token/tokens.dart';

class TokenReader<T> {
  TokenReader(this.iterator);

  final Iterator<BaseToken<Object>> iterator;

  BaseToken<Object>? peeked;

  BaseToken<Object>? next() {
    if (peeked != null) {
      var token = peeked;
      peeked = null;
      return token;
    }

    return iterator.moveNext() ? iterator.current : null;
  }

  BaseToken<Object>? peek() {
    return peeked = next();
  }

  T? peekType() {
    peeked = next();

    if (peeked != null) {
      return peeked!.type as T;
    }

    return null;
  }

  bool when(T type) {
    return iterator.current.type == type;
  }

  bool get isDone {
    if (peeked != null) {
      return false;
    }

    if (peek() == null) {
      return true;
    }

    return false;
  }
}

class TokenReversibleReader<T> extends TokenReader<T> {
  TokenReversibleReader(Iterator<BaseToken<Object>> iterator)
      : seen = Queue<BaseToken<Object>>(),
        super(iterator);

  final Queue<BaseToken<Object>> seen;

  T peekTypeIgnoringType(T ignoreType) {
    var buffer = Queue<BaseToken<Object>>();
    peek();

    while (peeked != null && peeked!.type == ignoreType) {
      buffer.add(peeked!);
      peeked = null;
      peek();
    }

    var returnType = (peeked == null) ? null : peeked!.type;

    if (peeked != null) {
      buffer.add(peeked!);
      peeked = null;
    }

    seen.addAll(buffer);
    return returnType as T;
  }

  @override
  BaseToken<Object>? next() {
    if (peeked != null) {
      var token = peeked;
      peeked = null;
      return token;
    }

    if (seen.isNotEmpty) {
      return seen.removeFirst();
    }

    return iterator.moveNext() ? iterator.current : null;
  }

  BaseToken<Object> putBack(BaseToken<Object> token) {
    if (peeked != null) {
      seen.addFirst(peeked!);
      peeked = token;
      return peeked!;
    }

    peeked = token;
    return peeked!;
  }
}
