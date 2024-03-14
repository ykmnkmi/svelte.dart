export 'package:svelte_js/src/types.dart';
export 'package:svelte_js/src/wasm.dart'
    if (dart.library.html) 'package:svelte_js/src/js.dart' show mount, unmount;
