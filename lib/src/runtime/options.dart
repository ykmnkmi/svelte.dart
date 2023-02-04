import 'dart:html';

import 'package:svelte/src/runtime/props.dart';

// TODO(runtime): replace with records
class Options {
  const Options({
    this.target,
    this.anchor,
    this.props,
    this.hydrate = false,
    this.intro = false,
  });

  final Element? target;

  final Node? anchor;

  final Props? props;

  final bool hydrate;

  final bool intro;
}
