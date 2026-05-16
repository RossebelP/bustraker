class CircularSimpleNode<T> {
  CircularSimpleNode(this.value);

  T value;
  CircularSimpleNode<T>? next;
}

class CircularSimpleList<T> {
  CircularSimpleNode<T>? _tail;
  int _length = 0;

  int get length => _length;
  bool get isEmpty => _length == 0;
  CircularSimpleNode<T>? get head => _tail?.next;
  CircularSimpleNode<T>? get tail => _tail;

  CircularSimpleNode<T> insertar(T value) {
    final node = CircularSimpleNode<T>(value);
    if (_tail == null) {
      node.next = node;
      _tail = node;
    } else {
      node.next = _tail!.next;
      _tail!.next = node;
      _tail = node;
    }
    _length++;
    return node;
  }

  bool eliminar(bool Function(T value) test) {
    if (_tail == null) {
      return false;
    }

    CircularSimpleNode<T>? previous = _tail;
    var current = _tail!.next;

    for (var i = 0; i < _length; i++) {
      if (test(current!.value)) {
        if (_length == 1) {
          _tail = null;
        } else {
          previous!.next = current.next;
          if (identical(_tail, current)) {
            _tail = previous;
          }
        }
        current.next = null;
        _length--;
        return true;
      }
      previous = current;
      current = current.next;
    }

    return false;
  }

  T? buscar(bool Function(T value) test) => buscarNodo(test)?.value;

  CircularSimpleNode<T>? buscarNodo(bool Function(T value) test) {
    if (_tail == null) {
      return null;
    }

    var current = _tail!.next;
    for (var i = 0; i < _length; i++) {
      if (test(current!.value)) {
        return current;
      }
      current = current.next;
    }
    return null;
  }

  void recorrer(void Function(T value) visit) {
    if (_tail == null) {
      return;
    }

    var current = _tail!.next;
    for (var i = 0; i < _length; i++) {
      visit(current!.value);
      current = current.next;
    }
  }

  T? siguiente(T currentValue, {bool Function(T a, T b)? equals}) {
    return buscarNodo(
      (value) => _matches(value, currentValue, equals),
    )?.next?.value;
  }

  T? anterior(T currentValue, {bool Function(T a, T b)? equals}) {
    if (_tail == null) {
      return null;
    }

    var previous = _tail;
    var current = _tail!.next;
    for (var i = 0; i < _length; i++) {
      if (_matches(current!.value, currentValue, equals)) {
        return previous?.value;
      }
      previous = current;
      current = current.next;
    }
    return null;
  }

  CircularSimpleNode<T>? siguienteNodo(CircularSimpleNode<T>? node) {
    return node?.next;
  }

  CircularSimpleNode<T>? anteriorNodo(CircularSimpleNode<T>? node) {
    if (node == null || _tail == null) {
      return null;
    }

    var current = _tail;
    for (var i = 0; i < _length; i++) {
      if (identical(current!.next, node)) {
        return current;
      }
      current = current.next;
    }
    return null;
  }

  List<T> toDartList() {
    final values = <T>[];
    recorrer(values.add);
    return values;
  }

  bool _matches(T a, T b, bool Function(T a, T b)? equals) {
    return equals == null ? a == b : equals(a, b);
  }
}
