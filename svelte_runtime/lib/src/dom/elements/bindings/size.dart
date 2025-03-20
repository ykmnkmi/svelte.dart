import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:meta/dart2js.dart';
import 'package:svelte_runtime/src/reactivity.dart';
import 'package:svelte_runtime/src/runtime.dart';
import 'package:web/web.dart';

typedef ResizeObserverEntryListener = void Function(ResizeObserverEntry);

final class ResizeObserverSingleton {
  static final Expando<ResizeObserverEntry> entries =
      Expando<ResizeObserverEntry>();

  ResizeObserverSingleton(this.options)
    : listeners = Expando<Set<ResizeObserverEntryListener>>();

  final ResizeObserverOptions options;

  final Expando<Set<ResizeObserverEntryListener>> listeners;

  ResizeObserver? _observer;

  ResizeObserver get observer {
    return _observer ??= ResizeObserver(
      (JSArray<ResizeObserverEntry> jsEntries) {
        List<ResizeObserverEntry> entries = jsEntries.toDart;

        for (int i = 0; i < entries.length; i++) {
          ResizeObserverEntry entry = entries[i];
          ResizeObserverSingleton.entries[entry.target] = entry;

          Set<ResizeObserverEntryListener>? listeners =
              this.listeners[entry.target];

          if (listeners != null) {
            for (ResizeObserverEntryListener listener in listeners) {
              listener(entry);
            }
          }
        }
      }.toJS,
    );
  }

  set observer(ResizeObserver? value) {
    _observer = value;
  }

  void Function() observe(
    Element element,
    ResizeObserverEntryListener listener,
  ) {
    Set<ResizeObserverEntryListener> listeners =
        this.listeners[element] ??= <ResizeObserverEntryListener>{};
    listeners.add(listener);
    observer.observe(element, options);

    return () {
      Set<ResizeObserverEntryListener>? listeners = this.listeners[element];

      if (listeners != null) {
        listeners.remove(listener);

        if (listeners.isEmpty) {
          this.listeners[element] = null;
        }
      }
    };
  }
}

final ResizeObserverSingleton resizeObjserverBorderBox =
    ResizeObserverSingleton(ResizeObserverOptions(box: 'border-box'));

@noInline
void bindElementSize(
  HTMLElement element,
  String type,
  void Function(int size) set,
) {
  void Function() dispose = resizeObjserverBorderBox.observe(element, (_) {
    JSNumber jsSize = element.getProperty<JSNumber>(type.toJS);
    set(jsSize.toDartInt);
  });

  effect<void Function()>(() {
    untrack<void>(() {
      JSNumber jsSize = element.getProperty<JSNumber>(type.toJS);
      set(jsSize.toDartInt);
    });

    return dispose;
  });
}
