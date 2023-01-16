import 'dart:convert';

import 'package:svelte/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  var source = '<p>Hello <span>world</span>!</p>';
  var sourceUrl = 'index.svelte';

  try {
    var nodes = parse(source, sourceUrl: sourceUrl);
    print(const JsonEncoder.withIndent('  ').convert(nodes));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.from(stackTrace));
  }
}
