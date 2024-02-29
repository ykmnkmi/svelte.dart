import 'dart:js_interop';

import 'package:svelte_js/svelte_js.dart';
import 'package:web/web.dart';

import 'examples/00_introduction/00_hello_world/app.dart' as hello_world;
import 'examples/00_introduction/01_dynamic_attributes/app.dart'
    as dynamic_attributes;
import 'examples/00_introduction/02_styling/app.dart' as styling;
import 'examples/00_introduction/03_nested_components/app.dart'
    as nested_components;
import 'examples/00_introduction/04_html_tags/app.dart' as html_tags;
import 'examples/01_reactivity/00_reactive_assignments/app.dart'
    as reactive_assignments;
import 'examples/01_reactivity/01_reactive_declarations/app.dart'
    as reactive_declarations;
import 'examples/01_reactivity/02_reactive_statements/app.dart'
    as reactive_statements;
import 'examples/03_properties/00_declaring_properties/app.dart'
    as declaring_properties;

Component getFactory(void Function(Node) component) {
  return (Node node, JSObject properties) {
    component(node);
  };
}

Component? selectFactory(String name) {
  return switch (name) {
    '' => null,
    'hello_world' => getFactory(hello_world.app.call),
    'dynamic_attributes' => getFactory(dynamic_attributes.app.call),
    'styling' => getFactory(styling.app.call),
    'nested_components' => getFactory(nested_components.app.call),
    'html_tags' => getFactory(html_tags.app.call),
    'reactive_assignments' => getFactory(reactive_assignments.app.call),
    'reactive_declarations' => getFactory(reactive_declarations.app.call),
    'reactive_statements' => getFactory(reactive_statements.app.call),
    'declaring_properties' => getFactory(declaring_properties.app.call),
    _ => throw ArgumentError('Unknown example: $name'),
  };
}

void main() {
  var select = document.querySelector('select') as HTMLSelectElement;
  var target = document.querySelector('main') as HTMLElement;

  ComponentReference? component;

  void onChange(Event event) {
    var app = selectFactory(select.value);

    if (component case var component?) {
      unmount(component);
    }

    if (app != null) {
      component = mount(app, target: target);
    }
  }

  select.addEventListener('change', onChange.toJS);
}
