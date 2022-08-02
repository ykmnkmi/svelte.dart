import 'package:meta/meta.dart';
import 'package:piko/src/runtime/component.dart';

@immutable
class Scope {
  Scope(this.context, this.dirty);

  final Context context;

  final Set<String> dirty;
}
