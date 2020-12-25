@JS()
library jdom;

import 'package:js/js.dart';

export 'package:js/js.dart' show allowInterop, allowInteropCaptureThis;

@JS()
abstract class CharacterData implements Node {}

@JS()
abstract class Console {
  external void log(dynamic value);
}

external Console get console;

@JS()
abstract class Document implements Node {
  external Element get body;

  external Element createElement(String tagName);

  external Text createTextNode(String data);
}

external Document get document;

@JS()
abstract class Element implements Node {
  external void append(Node child);

  external void prepend(Node child);
}

@JS()
abstract class EventTarget {
  external void addEventListener(String type, Function callback);
}

@JS()
abstract class Node implements EventTarget {
  external Node appendChild(Node child);
}

@JS()
abstract class Text implements CharacterData {}

@JS()
abstract class Window {
  external Console get console;

  external Document get document;
}

external Window get window;

extension JSInterop on Function {
  Function get js {
    return allowInterop(this);
  }

  Function get jsThis {
    return allowInteropCaptureThis(this);
  }
}
