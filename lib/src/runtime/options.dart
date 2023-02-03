import 'dart:html';

// TODO(runtime): replace with records
class Options {
  const Options({
    this.props,
    this.target,
    this.anchor,
    this.hydrate = false,
    this.intro = false,
  });

  final Map<String, Object?>? props;

  final Element? target;

  final Node? anchor;

  final bool hydrate;

  final bool intro;
}
