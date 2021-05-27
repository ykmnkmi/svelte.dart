import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

void main() {
  final result = parseFile(path: 'bin/app.dart', featureSet: FeatureSet.latestLanguageVersion());
  final analyzer = ComponentAnalyzer();
  analyzer.visitCompilationUnit(result.unit);

  for (final component in analyzer.componnets) {
    component..fields.forEach(print)..methods.forEach(print);
  }
}

class ComponentAnalyzer extends ThrowingAstVisitor<void> {
  ComponentAnalyzer() : componnets = <ComponentContext>[];

  final List<ComponentContext> componnets;

  ComponentContext get current {
    return componnets.last;
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.extendsClause?.superclass.name.name == 'Component') {
      componnets.add(ComponentContext());

      for (final member in node.members) {
        if (member is ConstructorDeclaration) {
          continue;
        }

        member.accept(this);
      }
    }
  }

  @override
  void visitCompilationUnit(CompilationUnit node) {
    node.visitChildren(this);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    current.fields.add(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.name != 'render') {
      current.methods.add(node);
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    print(node);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    // ...
  }
}

class ComponentContext {
  ComponentContext()
      : fields = <FieldDeclaration>[],
        methods = <MethodDeclaration>[];

  final List<FieldDeclaration> fields;

  final List<MethodDeclaration> methods;
}
