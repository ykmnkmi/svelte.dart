Testing Svelte 5 JS bindings and ~~compiler~~.

Run `npm run build` to rebuild Svelte 5 JS bundle.

Run `dartaotruntime /usr/lib/dart/bin/snapshots/dart2wasm_product.snapshot --dart-sdk /usr/lib/dart --platform /usr/lib/dart/lib/_internal/dart2wasm_platform.dill web/main.dart web/main.dart.wasm` to rebuild WASM module on Linux.

Run `dartaotruntime C:\SDK\Dart\bin\snapshots\dart2wasm_product.snapshot --dart-sdk C:\SDK\Dart --platform C:\SDK\Dart\lib\_internal\dart2wasm_platform.dill .\web\main.dart .\web\main.dart.wasm` to rebuild WASM module on Windows.