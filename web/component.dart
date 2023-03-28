import 'dart:html';

import 'package:svelte/dom.dart';

@Component(
  tag: 'app',
  template: 'hello {name}!',
)
class AppComponent {
  String name = 'world';
}

class AppView extends ComponentView<AppComponent> {
  AppView() {
    component = AppComponent();
  }

  late Text t1, t2, t3;

  @override
  void create() {
    t1 = text('hello ');
    t2 = text(component.name);
    t3 = text('!');
  }

  @override
  void mount(Element target, Node? anchor) {
    insert(target, t1, anchor);
    insert(target, t2, anchor);
    insert(target, t3, anchor);
  }

  @override
  void destroy(bool detaching) {
    if (detaching) {
      remove(t1);
      remove(t2);
      remove(t3);
    }
  }
}

AppView appComponentFactory() {
  return AppView();
}

void main() {
  runApp<AppComponent>(appComponentFactory, target: document.body!);

  var node = template('<button type="button">count: <!>!</button>');

  for (var child in node.childNodes) {
    print(child.nodeName);
  }
}

class Component {
  const Component({
    required this.tag,
    this.template,
  });

  final String tag;

  final String? template;
}

T runApp<T extends Object>(
  ComponentFactory<T> componentViewFactory, {
  required Element target,
  Node? anchor,
}) {
  var componentView = componentViewFactory()
    ..create()
    ..mount(target, anchor);

  return componentView.component;
}

typedef ComponentFactory<T extends Object> = ComponentView<T> Function();

abstract class View {
  void create() {}

  void mount(Element target, Node? anchor) {}

  void destroy(bool detaching) {}
}

abstract class ComponentView<T extends Object> extends View {
  late T component;
}

Node template(String html, [bool isSVG = false]) {
  var template = document.createElement('template') as TemplateElement;
  template.innerHtml = html;

  var content = template.content as DocumentFragment;
  var node = content.firstChild as Node;

  if (isSVG) {
    return node.firstChild as Node;
  }

  return node;
}
