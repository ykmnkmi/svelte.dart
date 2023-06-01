import 'package:analyzer/dart/ast/ast.dart'
    show DartPattern, Expression, SimpleIdentifier;
import 'package:svelte_ast/src/dart_to_json.dart';

part 'ast/blocks.dart';
part 'ast/interface.dart';
part 'ast/tags.dart';
part 'ast/visitor.dart';

const DartToJsonVisitor dart2Json = DartToJsonVisitor();
