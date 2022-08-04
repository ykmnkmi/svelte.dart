@JS()
library piko.dom;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';

export 'package:js/js_util.dart' show getProperty, setProperty;

typedef EventListener = void Function(Event event);

typedef VoidCallback = void Function();

@JS()
@staticInterop
abstract class Console {}

extension ConsoleImpl on Console {
  void log(Object? object) {
    callMethod<void>(this, 'log', <Object?>[object]);
  }
}

@JS()
external Console get console;

@JS()
@anonymous
@doNotStore
class EventOptions {
  external factory EventOptions({bool? bubbles, bool? cancelable, bool? composed});
}

@JS()
@staticInterop
class Event {
  external Event(String type, [EventOptions? options]);
}

extension EventImpl on Event {
  String get type {
    return getProperty<String>(this, 'type');
  }
}

@JS()
@anonymous
@doNotStore
class CustomEventOptions {
  external factory CustomEventOptions({bool? bubbles, bool? cancelable, bool? composed, Object? detail});
}

@JS()
@staticInterop
@optionalTypeArgs
class CustomEvent<T> implements Event {
  external CustomEvent(String type, [CustomEventOptions? options]);
}

extension CustomEventImpl<T> on CustomEvent<T> {
  T? get detail {
    return getProperty<T>(this, 'detail');
  }
}

@JS()
@staticInterop
abstract class EventTarget {}

@JS()
@staticInterop
abstract class Node implements EventTarget {}

@JS()
@staticInterop
abstract class Text implements Node {}

@JS()
@staticInterop
abstract class Element implements Node {}

@JS('document.querySelector')
external Element? _querySelector(String selector);

@noInline
Element? querySelector(String selector) {
  return _querySelector(selector);
}

@JS('document.createElement')
external Element _createElement(String tag);

@noInline
Element element(String tag) {
  return _createElement(tag);
}

@JS('document.createTextNode')
external Text _createTextNode(Object? text);

Text empty() {
  return text('');
}

Text space() {
  return text(' ');
}

@noInline
Text text(Object? text) {
  return _createTextNode(text);
}

@noInline
void setText(Text target, Object? text) {
  setProperty(target, 'data', text);
}

@noInline
void diffText(Text target, Object? oldText, Object? newText) {
  if (oldText != newText) {
    setProperty(target, 'data', newText);
  }
}

@noInline
void setTextContent(Text target, Object? text) {
  setProperty(target, 'textContent', text);
}

@noInline
void setInnerText(Element target, Object? text) {
  setProperty(target, 'innerText', text);
}

@noInline
void setInnerHtml(Element target, Object? html) {
  setProperty(target, 'innerHtml', html);
}

@noInline
String? getAttribute(Element node, String attribute) {
  return callMethod<String?>(node, 'getAttribute', <Object?>[attribute]);
}

@noInline
void setAttribute(Element element, String attribute, String value) {
  callMethod<void>(element, 'setAttribute', <Object?>[attribute, value]);
}

@noInline
void removeAttribute(Element element, String attribute) {
  callMethod<void>(element, 'removeAttribute', <Object?>[attribute]);
}

@noInline
void updateAttribute(Element element, String attribute, String? value) {
  if (value == null) {
    removeAttribute(element, attribute);
  } else if (value != getAttribute(element, attribute)) {
    setAttribute(element, attribute, value);
  }
}

@noInline
void insert(Node target, Node child, [Node? anchor]) {
  callMethod<void>(target, 'insertBefore', <Object?>[child, anchor]);
}

@noInline
void append(Element target, Object? child) {
  callMethod<void>(target, 'append', <Object?>[child]);
}

@noInline
void listen(EventTarget target, String type, EventListener listener) {
  listener = allowInterop(listener);
  callMethod<void>(target, 'addEventListener', <Object?>[type, listener]);
}

@noInline
void cancel(EventTarget target, String type, EventListener listener) {
  listener = allowInterop(listener);
  callMethod<void>(target, 'removeEventListener', <Object?>[type, listener]);
}

@noInline
Node? parentNode(Node node) {
  return getProperty<Node?>(node, 'parentNode');
}

@noInline
Element? parentElement(Node node) {
  return getProperty<Element?>(node, 'parentElement');
}

@noInline
void remove(Node node) {
  var parent = parentNode(node);

  if (parent == null) {
    return;
  }

  callMethod<void>(parent, 'removeChild', <Object?>[node]);
}

@tryInline
@pragma('dart2js:as:trust')
T unsafeCast<T>(Object? object) {
  return object as T;
}
