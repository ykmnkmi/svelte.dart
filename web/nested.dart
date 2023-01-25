import 'dart:html';

import 'package:svelte/runtime.dart';

class NestedFragment extends Fragment {
  NestedFragment(this.values)
      : button1 = element('button'),
        text0 = text('Clicked '),
        text1 = empty(),
        text2 = space(),
        text3 = empty(),
        text4 = text('!');

  final List<Object?> values;

  final Element button1;

  final Text text0;

  final Text text1;

  final Text text2;

  final Text text3;

  final Text text4;

  String get text1Data {
    return '${values[0]}';
  }

  String get text3Data {
    return values[0] == 1 ? 'time' : 'times';
  }

  @override
  void create() {
    setData(text1, text1Data);
    setData(text3, text3Data);
  }

  @override
  void mount(Element target, Node? anchor) {
    append(target, text0);
    append(target, text1);
    append(target, text2);
    append(target, text3);
    append(target, text4);
  }

  @override
  void update(List<int> dirty) {
    if (dirty[0] & 1 == 0) {
      setData(text1, text1Data);
      setData(text3, text3Data);
    }
  }

  @override
  void detach(bool detaching) {
    if (detaching) {
      remove(text0);
      remove(text1);
      remove(text2);
      remove(text3);
      remove(text4);
    }
  }
}

class Nested extends Component {
  factory Nested({int count = 0}) {
    var values = <Object?>[count];
    var fragment = NestedFragment(values);
    return Nested._(fragment, values);
  }

  Nested._(this._fragment, this._values);

  final NestedFragment _fragment;

  final List<Object?> _values;

  int get count {
    return unsafeCast<int>(_values[0]);
  }

  set count(int count) {
    invalidateComponent(this, 0, count);
  }
}
