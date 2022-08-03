@JS()
library piko.dom;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as utils;
import 'package:meta/dart2js.dart';
import 'package:meta/meta.dart';

@JS()
@staticInterop
abstract class Console {}

extension ConsoleImplementation on Console {
  external void log(Object? object);
}

@JS()
external Console get console;

typedef EventListener = void Function(Event event);

typedef VoidCallback = void Function();

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
  external String get type;
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
  external T? get detail;
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
  return utils.callMethod<String?>(node, 'getAttribute', <Object?>[attribute]);
}

@noInline
void setAttribute(Element element, String attribute, String value) {
  utils.callMethod<void>(element, 'setAttribute', <Object?>[attribute, value]);
}

@noInline
void removeAttribute(Element element, String attribute) {
  utils.callMethod<void>(element, 'removeAttribute', <Object?>[attribute]);
}

@noInline
void updateAttribute(Element element, String attribute, String? value) {
  if (value == null) {
    removeAttribute(element, attribute);
  } else if (value != getAttribute(element, attribute)) {
    setAttribute(element, attribute, value);
  }
}

@pragma('dart2js:tryInline')
T getProperty<T>(Object object, String name) {
  return utils.getProperty<T>(object, name);
}

@pragma('dart2js:tryInline')
void setProperty(Object object, String name, Object? value) {
  utils.setProperty<Object?>(object, name, value);
}

@noInline
void insert(Node node, Node child, [Node? anchor]) {
  utils.callMethod<void>(node, 'insertBefore', <Object?>[child, anchor]);
}

@noInline
void append(Element element, Object? child) {
  utils.callMethod<void>(element, 'append', <Object?>[child]);
}

@noInline
void listen(EventTarget target, String type, EventListener listener) {
  listener = allowInterop(listener);
  utils.callMethod<void>(target, 'addEventListener', <Object?>[type, listener]);
}

@noInline
void cancel(EventTarget target, String type, EventListener listener) {
  listener = allowInterop(listener);
  utils.callMethod<void>(target, 'removeEventListener', <Object?>[type, listener]);
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

  utils.callMethod<void>(parent, 'removeChild', <Object?>[node]);
}

@tryInline
@pragma('dart2js:as:trust')
T unsafeCast<T>(Object? object) {
  return object as T;
}
