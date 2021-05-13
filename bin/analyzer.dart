import 'package:analyzer/dart/analysis/utilities.dart';

void main() {
  final result = parseString(content: 'void main() {}');
  print(result.unit);
}
