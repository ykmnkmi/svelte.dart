// ignore_for_file: avoid_print
library;

import 'dart:js_interop';

import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

import 'examples/00_introduction/00_hello_world/app.dart' as e00;
import 'examples/00_introduction/01_dynamic_attributes/app.dart' as e01;
import 'examples/00_introduction/02_styling/app.dart' as e02;
import 'examples/00_introduction/03_nested_components/app.dart' as e03;
import 'examples/00_introduction/04_html_tags/app.dart' as e05;
import 'examples/01_reactivity/00_reactive_assignments/app.dart' as e10;
import 'examples/01_reactivity/01_reactive_declarations/app.dart' as e11;
import 'examples/01_reactivity/02_reactive_statements/app.dart' as e12;
import 'examples/02_properties/00_declaring_properties/app.dart' as e20;
import 'examples/02_properties/01_default_values/app.dart' as e21;
import 'examples/02_properties/02_spread_properties/app.dart' as e22;
import 'examples/03_logic/00_if_blocks/app.dart' as e30;
import 'examples/03_logic/01_else_blocks/app.dart' as e31;
import 'examples/03_logic/02_else_if_blocks/app.dart' as e32;
import 'examples/03_logic/03_each_blocks/app.dart' as e33;
// import 'examples/03_logic/04_keyed_each_blocks/app.dart' as keyed_each_blocks;
// import 'examples/03_logic/05_await_blocks/app.dart' as await_blocks;
// import 'examples/04_events/00_dom_events/app.dart' as dom_events;
// import 'examples/04_events/01_inline_handlers/app.dart' as inline_handlers;
// import 'examples/04_events/02_event_modifiers/app.dart' as event_modifiers;
// import 'examples/04_events/03_component_events/app.dart' as component_events;
// import 'examples/04_events/04_event_forwarding/app.dart' as event_forwarding;
// import 'examples/04_events/05_dom_event_forwarding/app.dart' as dom_event_forwarding;
// import 'examples/05_bindings/00_text_inputs/app.dart' as text_inputs;
// import 'examples/05_bindings/01_numeric_inputs/app.dart' as numeric_inputs;
// import 'examples/05_bindings/02_checkbox_inputs/app.dart' as checkbox_inputs;

Component? mountComponent(String name, Element target, Node anchor) {
  return switch (name) {
    'hello_world' => e00.App(target: target, anchor: anchor),
    'dynamic_attributes' => e01.App(target: target, anchor: anchor),
    'styling' => e02.App(target: target, anchor: anchor),
    'nested_components' => e03.App(target: target, anchor: anchor),
    'html_tags' => e05.App(target: target, anchor: anchor),
    'reactive_assignments' => e10.App(target: target, anchor: anchor),
    'reactive_declarations' => e11.App(target: target, anchor: anchor),
    'reactive_statements' => e12.App(target: target, anchor: anchor),
    'declaring_properties' => e20.App(target: target, anchor: anchor),
    'default_values' => e21.App(target: target, anchor: anchor),
    'spread_properties' => e22.App(target: target, anchor: anchor),
    'if_blocks' => e30.App(target: target, anchor: anchor),
    'else_blocks' => e31.App(target: target, anchor: anchor),
    'else_if_blocks' => e32.App(target: target, anchor: anchor),
    'each_blocks' => e33.App(target: target, anchor: anchor),
    // 'keyed_each_blocks' => keyed_each_blocks.App(target: target, anchor: anchor),
    // 'await_blocks' => await_blocks.App(target: target, anchor: anchor),
    // 'dom_events' => dom_events.App(target: target, anchor: anchor),
    // 'inline_handlers' => inline_handlers.App(target: target, anchor: anchor),
    // 'event_modifiers' => event_modifiers.App(target: target, anchor: anchor),
    // 'component_events' => component_events.App(target: target, anchor: anchor),
    // 'event_forwarding' => event_forwarding.App(target: target, anchor: anchor),
    // 'dom_event_forwarding' => dom_event_forwarding.App(target: target, anchor: anchor),
    // 'text_inputs' => text_inputs.App(target: target, anchor: anchor),
    // 'numeric_inputs' => numeric_inputs.App(target: target, anchor: anchor),
    // 'checkbox_inputs' => checkbox_inputs.App(target: target, anchor: anchor),
    _ => null,
  };
}

void main() {
  var select = document.querySelector('nav select') as HTMLSelectElement;
  var target = document.querySelector('main') as HTMLElement;
  var anchor = target.appendChild(Text());
  var link = document.querySelector('nav a') as HTMLAnchorElement;

  Component? current;

  void onChange(Event event) {
    try {
      if (current case var component?) {
        component.destroy();
      }

      window.location.hash = link.hash = select.value;
      current = mountComponent(select.value, target, anchor);
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
      rethrow;
    }
  }

  select.addEventListener('change', onChange.toJS);

  if (window.location.hash case var hash when hash.isNotEmpty) {
    select.value = link.hash = hash.substring(1);
    onChange(Event('change'));
  }
}
