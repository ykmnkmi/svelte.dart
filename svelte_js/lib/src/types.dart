@JS(r'$$')
library;

import 'package:js/js.dart';

@JS('FragmentFactory')
@staticInterop
abstract interface class FragmentFactory {}

extension FragmentFactoryExtension on FragmentFactory {}

@JS('Signal')
@staticInterop
abstract interface class Signal<V> {}

extension SignalExtension<V> on Signal<V> {}

@JS('SourceSignal')
@staticInterop
abstract interface class SourceSignal<V> implements Signal<V> {}

extension SourceSignalExtension<V> on SourceSignal<V> {}
