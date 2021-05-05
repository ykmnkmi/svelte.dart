import 'visitor.dart';

abstract class Node {
  R accept<R>(covariant Visitor<R> visitor);
}
