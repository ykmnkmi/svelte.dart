import 'dart:html';

// TODO(runtime): replace with records
class Options {
  const Options([
    this.target,
    this.anchor,
    this.hydrate = false,
    this.intro = false,
  ]);

  final Element? target;

  final Node? anchor;

  final bool hydrate;

  final bool intro;
}
