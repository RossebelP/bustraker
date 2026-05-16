class CircularDoubleNode<T> {
  CircularDoubleNode(this.value);

  T value;
  CircularDoubleNode<T>? previous;
  CircularDoubleNode<T>? next;
}

class CircularDoubleList<T> {
  CircularDoubleNode<T>? _head;
  int _length = 0;

  int get length => _length;
  bool get isEmpty => _length == 0;
  CircularDoubleNode<T>? get head => _head;
  CircularDoubleNode<T>? get tail => _head?.previous;

  CircularDoubleNode<T> insertar(T value) {
    final node = CircularDoubleNode<T>(value);
    if (_head == null) {
      node
        ..next = node
        ..previous = node;
      _head = node;
    } else {
      final tail = _head!.previous!;
      node
        ..previous = tail
        ..next = _head;
      tail.next = node;
      _head!.previous = node;
    }
    _length++;
    return node;
  }

  bool eliminar(bool Function(T value) test) {
    if (_head == null) {
      return false;
    }

    var current = _head;
    for (var i = 0; i < _length; i++) {
      if (test(current!.value)) {
        if (_length == 1) {
          _head = null;
        } else {
          current.previous!.next = current.next;
          current.next!.previous = current.previous;
          if (identical(_head, current)) {
            _head = current.next;
          }
        }
        current
          ..previous = null
          ..next = null;
        _length--;
        return true;
      }
      current = current.next;
    }

    return false;
  }

  T? buscar(bool Function(T value) test) => buscarNodo(test)?.value;

  CircularDoubleNode<T>? buscarNodo(bool Function(T value) test) {
    if (_head == null) {
      return null;
    }

    var current = _head;
    for (var i = 0; i < _length; i++) {
      if (test(current!.value)) {
        return current;
      }
      current = current.next;
    }
    return null;
  }

  void recorrer(void Function(T value) visit) {
    if (_head == null) {
      return;
    }

    var current = _head;
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
    return buscarNodo(
      (value) => _matches(value, currentValue, equals),
    )?.previous?.value;
  }

  CircularDoubleNode<T>? siguienteNodo(CircularDoubleNode<T>? node) {
    return node?.next;
  }

  CircularDoubleNode<T>? anteriorNodo(CircularDoubleNode<T>? node) {
    return node?.previous;
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
