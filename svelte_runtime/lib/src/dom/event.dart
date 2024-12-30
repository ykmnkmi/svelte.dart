part of '../dom.dart';

typedef EventListener = void Function(Event);

@noInline
EventListener listener(void Function() function) {
  void handler(Event event) {
    function();
  }

  return handler;
}

@noInline
void Function() listen(
  EventTarget target,
  String type,
  EventListener listener,
) {
  JSFunction fn = listener.toJS;
  target.addEventListener(type, fn);

  return () {
    target.removeEventListener(type, fn);
  };
}
