// ignore_for_file: avoid_print
library;

import 'dart:js_interop';

import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

// introduction
import 'examples/00_introduction/00_hello_world/app.dart' as i00;
import 'examples/00_introduction/01_dynamic_attributes/app.dart' as i01;
import 'examples/00_introduction/02_styling/app.dart' as i02;
import 'examples/00_introduction/03_nested_components/app.dart' as i03;
import 'examples/00_introduction/04_html_tags/app.dart' as i04;
// reactivity
import 'examples/01_reactivity/00_reactive_assignments/app.dart' as r00;
import 'examples/01_reactivity/01_reactive_declarations/app.dart' as r01;
import 'examples/01_reactivity/02_reactive_statements/app.dart' as r02;
// properties
import 'examples/02_properties/00_declaring_properties/app.dart' as p00;
import 'examples/02_properties/01_default_values/app.dart' as p01;
import 'examples/02_properties/02_spread_properties/app.dart' as p02;
// logic
import 'examples/03_logic/00_if_blocks/app.dart' as l00;
import 'examples/03_logic/01_else_blocks/app.dart' as l01;
import 'examples/03_logic/02_else_if_blocks/app.dart' as l02;
import 'examples/03_logic/03_each_blocks/app.dart' as l03;
import 'examples/03_logic/04_keyed_each_blocks/app.dart' as l04;
import 'examples/03_logic/05_await_blocks/app.dart' as l05;
// events
import 'examples/04_events/00_dom_events/app.dart' as e00;
import 'examples/04_events/01_inline_handlers/app.dart' as e01;
import 'examples/04_events/02_component_events/app.dart' as e02;
import 'examples/04_events/03_event_forwarding/app.dart' as e03;
import 'examples/04_events/04_dom_event_forwarding/app.dart' as e04;
// bindings
import 'examples/05_bindings/00_text_inputs/app.dart' as b00;
import 'examples/05_bindings/01_numeric_inputs/app.dart' as b01;
import 'examples/05_bindings/02_checkbox_inputs/app.dart' as b02;
import 'examples/05_bindings/03_group_inputs/app.dart' as b03;
import 'examples/05_bindings/04_textarea_inputs/app.dart' as b04;
import 'examples/05_bindings/05_file_inputs/app.dart' as b05;
import 'examples/05_bindings/06_select_bindings/app.dart' as b06;
import 'examples/05_bindings/07_multiple_select_bindings/app.dart' as b07;
import 'examples/05_bindings/08_each_block_bindings/app.dart' as b08;
import 'examples/05_bindings/09_media_elements/app.dart' as b09;
import 'examples/05_bindings/10_dimensions/app.dart' as b10;
import 'examples/05_bindings/11_bind_this/app.dart' as b11;

Component? selectComponent(String name) {
  return switch (name) {
    // introduction
    'hello_world' => i00.App(),
    'dynamic_attributes' => i01.App(),
    'styling' => i02.App(),
    'nested_components' => i03.App(),
    'html_tags' => i04.App(),
    // reactivity
    'reactive_assignments' => r00.App(),
    'reactive_declarations' => r01.App(),
    'reactive_statements' => r02.App(),
    // properties
    'declaring_properties' => p00.App(),
    'default_values' => p01.App(),
    'spread_properties' => p02.App(),
    // logic
    'if_blocks' => l00.App(),
    'else_blocks' => l01.App(),
    'else_if_blocks' => l02.App(),
    'each_blocks' => l03.App(),
    'keyed_each_blocks' => l04.App(),
    'await_blocks' => l05.App(),
    // events
    'dom_events' => e00.App(),
    'inline_handlers' => e01.App(),
    'component_events' => e02.App(),
    'event_forwarding' => e03.App(),
    'dom_event_forwarding' => e04.App(),
    // bindings
    'text_inputs' => b00.App(),
    'numeric_inputs' => b01.App(),
    'checkbox_inputs' => b02.App(),
    'group_inputs' => b03.App(),
    'textarea_inputs' => b04.App(),
    'file_inputs' => b05.App(),
    'select_bindings' => b06.App(),
    'multiple_select_bindings' => b07.App(),
    'each_block_bindings' => b08.App(),
    'media_elements' => b09.App(),
    'dimensions' => b10.App(),
    'bind_this' => b11.App(),
    // default
    _ => null,
  };
}

void main() {
  var select = document.querySelector('nav select') as HTMLSelectElement;
  var link = document.querySelector('nav a') as HTMLAnchorElement;
  var target = document.querySelector('main') as HTMLElement;

  Component? current;

  void onChange(Event event) {
    try {
      if (current case var component?) {
        unmount(component);
      }

      window.location.hash = link.hash = select.value;
      current = selectComponent(select.value);

      if (current case var component?) {
        mount(component, target: target);
      }
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
      rethrow;
    }
  }

  select.addEventListener('change', onChange.toJS);

  if (window.location.hash.isNotEmpty) {
    link.hash = select.value = window.location.hash.substring(1);
    onChange(Event('change'));
  }
}
