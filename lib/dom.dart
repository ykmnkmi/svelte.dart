@JS()

import 'package:js/js.dart';
import 'package:js/js_util.dart' as utils;

typedef EventListener = void Function(Event event);

typedef VoidCallback = void Function();

@JS()
@staticInterop
abstract class Event {}

@JS()
@anonymous
class CustomEventOptions<T> {
  external factory CustomEventOptions({bool? bubbles, bool? cancelable, bool? composed, T? detail});
}

@JS()
@staticInterop
class CustomEvent<T> implements Event {
  external CustomEvent(String type, [CustomEventOptions<T>? options]);
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

@pragma('dart2js:noInline')
Element? querySelector(String selector) {
  return _querySelector(selector);
}

@JS('document.createElement')
external Element _createElement(String tag);

@pragma('dart2js:noInline')
Element element(String tag) {
  return _createElement(tag);
}

@JS('document.createTextNode')
external Text _createTextNode(Object? text);

@pragma('dart2js:noInline')
Text text(Object? text) {
  return _createTextNode(text);
}

@pragma('dart2js:noInline')
void setText(Text target, Object? text) {
  setProperty(target, 'data', text);
}

@pragma('dart2js:noInline')
void setTextContent(Text target, Object? text) {
  setProperty(target, 'textContent', text);
}

@pragma('dart2js:noInline')
void setInnerText(Element target, Object? text) {
  setProperty(target, 'innerText', text);
}

@pragma('dart2js:noInline')
void setInnerHtml(Element target, Object? html) {
  setProperty(target, 'innerHtml', html);
}

@pragma('dart2js:noInline')
String? getAttribute(Element node, String attribute) {
  return utils.callMethod<String?>(node, 'getAttribute', <Object?>[attribute]);
}

@pragma('dart2js:noInline')
void setAttribute(Element element, String attribute, String value) {
  utils.callMethod<void>(element, 'setAttribute', <Object?>[attribute, value]);
}

@pragma('dart2js:noInline')
void removeAttribute(Element element, String attribute) {
  utils.callMethod<void>(element, 'removeAttribute', <Object?>[attribute]);
}

@pragma('dart2js:noInline')
void updateAttribute(Element element, String attribute, String? value) {
  if (value == null) {
    removeAttribute(element, attribute);
  } else if (value != getAttribute(element, attribute)) {
    setAttribute(element, attribute, value);
  }
}

@pragma('dart2js:tryInline')
T getProperty<T>(Node node, String name) {
  return utils.getProperty<T>(node, name);
}

@pragma('dart2js:tryInline')
void setProperty(Node node, String name, Object? value) {
  utils.setProperty<Object?>(node, name, value);
}

@pragma('dart2js:noInline')
void insert(Node node, Node child, [Node? anchor]) {
  utils.callMethod<void>(node, 'insertBefore', <Object?>[child, anchor]);
}

@pragma('dart2js:noInline')
void append(Element element, Object? child) {
  utils.callMethod<void>(element, 'append', <Object?>[child]);
}

@pragma('dart2js:noInline')
void listen(EventTarget target, String event, EventListener litener) {
  litener = allowInterop(litener);
  utils.callMethod<void>(target, 'addEventListener', <Object?>[event, litener]);
}

@pragma('dart2js:noInline')
void cancel(EventTarget target, String event, EventListener litener) {
  litener = allowInterop(litener);
  utils.callMethod<void>(target, 'removeEventListener', <Object?>[event, litener]);
}

@pragma('dart2js:noInline')
void remove(Node node) {
  var parentNode = getProperty<Node>(node, 'parentNode');
  utils.callMethod<void>(parentNode, 'removeChild', <Object?>[node]);
}

@pragma('dart2js:tryInline')
@pragma('dart2js:as:trust')
T unsafeCast<T>(Object? object) {
  return object as T;
}
