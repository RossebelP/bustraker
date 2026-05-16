class DoubleListNode<T> {
  DoubleListNode(this.value);

  T value;
  DoubleListNode<T>? previous;
  DoubleListNode<T>? next;
}

class DoubleLinkedList<T> {
  DoubleListNode<T>? _head;
  DoubleListNode<T>? _tail;
  int _length = 0;

  int get length => _length;
  bool get isEmpty => _length == 0;
  DoubleListNode<T>? get head => _head;
  DoubleListNode<T>? get tail => _tail;

  DoubleListNode<T> insertar(T value) {
    final node = DoubleListNode<T>(value);
    if (_head == null) {
      _head = node;
      _tail = node;
    } else {
      node.previous = _tail;
      _tail!.next = node;
      _tail = node;
    }
    _length++;
    return node;
  }

  bool eliminar(bool Function(T value) test) {
    var current = _head;

    while (current != null) {
      if (test(current.value)) {
        final previous = current.previous;
        final next = current.next;

        if (previous == null) {
          _head = next;
        } else {
          previous.next = next;
        }

        if (next == null) {
          _tail = previous;
        } else {
          next.previous = previous;
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

  DoubleListNode<T>? buscarNodo(bool Function(T value) test) {
    var current = _head;
    while (current != null) {
      if (test(current.value)) {
        return current;
      }
      current = current.next;
    }
    return null;
  }

  void recorrer(void Function(T value) visit) {
    var current = _head;
    while (current != null) {
      visit(current.value);
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

  DoubleListNode<T>? siguienteNodo(DoubleListNode<T>? node) => node?.next;

  DoubleListNode<T>? anteriorNodo(DoubleListNode<T>? node) => node?.previous;

  List<T> toDartList() {
    final values = <T>[];
    recorrer(values.add);
    return values;
  }

  bool _matches(T a, T b, bool Function(T a, T b)? equals) {
    return equals == null ? a == b : equals(a, b);
  }
}
