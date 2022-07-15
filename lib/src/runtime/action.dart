import 'package:meta/meta.dart';
import 'package:piko/dom.dart';

@optionalTypeArgs
abstract class Action<T extends Element, P> {
  Action(this.node);

  final T node;

  void update(P parameter) {}

  void destroy() {}
}
