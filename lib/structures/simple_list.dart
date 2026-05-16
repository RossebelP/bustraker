class SimpleListNode<T> {
  SimpleListNode(this.value);

  T value;
  SimpleListNode<T>? next;
}

class SimpleLinkedList<T> {
  SimpleListNode<T>? _head;
  SimpleListNode<T>? _tail;
  int _length = 0;

  int get length => _length;
  bool get isEmpty => _length == 0;
  SimpleListNode<T>? get head => _head;

  SimpleListNode<T> insertar(T value) {
    final node = SimpleListNode<T>(value);
    if (_head == null) {
      _head = node;
      _tail = node;
    } else {
      _tail!.next = node;
      _tail = node;
    }
    _length++;
    return node;
  }

  SimpleListNode<T> insertarInicio(T value) {
    final node = SimpleListNode<T>(value)..next = _head;
    _head = node;
    _tail ??= node;
    _length++;
    return node;
  }

  bool eliminar(bool Function(T value) test) {
    SimpleListNode<T>? previous;
    var current = _head;

    while (current != null) {
      if (test(current.value)) {
        if (previous == null) {
          _head = current.next;
        } else {
          previous.next = current.next;
        }

        if (identical(_tail, current)) {
          _tail = previous;
        }

        _length--;
        return true;
      }

      previous = current;
      current = current.next;
    }

    return false;
  }

  T? eliminarPrimero() {
    final current = _head;
    if (current == null) {
      return null;
    }

    _head = current.next;
    if (_head == null) {
      _tail = null;
    }
    _length--;
    return current.value;
  }

  T? buscar(bool Function(T value) test) {
    var current = _head;
    while (current != null) {
      if (test(current.value)) {
        return current.value;
      }
      current = current.next;
    }
    return null;
  }

  SimpleListNode<T>? buscarNodo(bool Function(T value) test) {
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
    final node = buscarNodo((value) => _matches(value, currentValue, equals));
    return node?.next?.value;
  }

  T? anterior(T currentValue, {bool Function(T a, T b)? equals}) {
    SimpleListNode<T>? previous;
    var current = _head;

    while (current != null) {
      if (_matches(current.value, currentValue, equals)) {
        return previous?.value;
      }
      previous = current;
      current = current.next;
    }

    return null;
  }

  List<T> toDartList({int? limit}) {
    final values = <T>[];
    var current = _head;
    while (current != null && (limit == null || values.length < limit)) {
      values.add(current.value);
      current = current.next;
    }
    return values;
  }

  bool _matches(T a, T b, bool Function(T a, T b)? equals) {
    return equals == null ? a == b : equals(a, b);
  }
}
