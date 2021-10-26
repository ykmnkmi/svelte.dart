import '../ast.dart';
import '../visitor.dart';

/// Provides a human-readable view of a template AST tree.
class HumanizingTemplateAstVisitor extends TemplateVisitor<String, StringBuffer?> {
  const HumanizingTemplateAstVisitor();

  @override
  String visitAnnotation(Annotation astNode, [StringBuffer? context]) => '@${astNode.name}';

  @override
  String visitAttribute(Attribute astNode, [StringBuffer? context]) {
    if (astNode.value != null) {
      return '${astNode.name}="${astNode.value}"';
    }

    return astNode.name;
  }

  @override
  String visitBanana(Banana astNode, [StringBuffer? context]) {
    var name = '[(${astNode.name})]';

    if (astNode.value != null) {
      return '$name="${astNode.value}"';
    }

    return name;
  }

  @override
  String visitCloseElement(CloseElement astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context
      ..write('</')
      ..write(astNode.name)
      ..write('>');
    return context.toString();
  }

  @override
  String visitComment(Comment astNode, [StringBuffer? context]) {
    return '<!--${astNode.value}-->';
  }

  @override
  String visitContainer(Container astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('<ng-container');

    if (astNode.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.annotations.map<String>(visitAnnotation), ' ');
    }

    if (astNode.stars.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.stars.map<String>(visitStar), ' ');
    }

    context.write('>');

    if (astNode.childNodes.isNotEmpty) {
      context.writeAll(astNode.childNodes.map<String>((child) => child.accept(this) as String));
    }

    context.write('</ng-container>');
    return context.toString();
  }

  @override
  String visitElement(Element astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context
      ..write('<')
      ..write(astNode.name);

    if (astNode.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.annotations.map<String>(visitAnnotation), ' ');
    }

    if (astNode.attributes.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.attributes.map<String>(visitAttribute), ' ');
    }

    if (astNode.events.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.events.map<String>(visitEvent), ' ');
    }

    if (astNode.properties.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.properties.map<String>(visitProperty), ' ');
    }

    if (astNode.references.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.references.map<String>(visitReference), ' ');
    }

    if (astNode.bananas.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.bananas.map<String>(visitBanana), ' ');
    }

    if (astNode.stars.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.stars.map<String>(visitStar), ' ');
    }

    if (astNode.isSynthetic) {
      context.write(astNode.isVoidElement ? '/>' : '>');
    } else {
      context.write(astNode.endToken!.lexeme);
    }

    if (astNode.childNodes.isNotEmpty) {
      context.writeAll(astNode.childNodes.map<String>((child) => child.accept(this) as String));
    }

    if (astNode.closeComplement != null) {
      context.write(visitCloseElement(astNode.closeComplement!));
    }

    return context.toString();
  }

  @override
  String visitEmbeddedContent(EmbeddedContent astNode, [StringBuffer? context]) {
    context ??= StringBuffer();

    if (astNode.selector != null) {
      context.write('<ng-content select="${astNode.selector}">');
    } else {
      context.write('<ng-content>');
    }

    context.write('</ng-content>');
    return context.toString();
  }

  @override
  String visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('<template');

    if (astNode.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.annotations.map<String>(visitAnnotation), ' ');
    }

    if (astNode.attributes.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.attributes.map<String>(visitAttribute), ' ');
    }

    if (astNode.properties.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.properties.map<String>(visitProperty), ' ');
    }

    if (astNode.references.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.references.map<String>(visitReference), ' ');
    }

    if (astNode.letBindings.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(astNode.letBindings.map<String>(visitLetBinding), ' ');
    }

    context.write('>');

    if (astNode.childNodes.isNotEmpty) {
      context.writeAll(astNode.childNodes.map<String>((child) => child.accept(this) as String));
    }

    context.write('</template>');
    return context.toString();
  }

  @override
  String visitEvent(Event astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('(${astNode.name}');

    if (astNode.reductions.isNotEmpty) {
      context.write('.${astNode.reductions.join('.')}');
    }

    context.write(')');

    if (astNode.value != null) {
      context.write('="${astNode.value}"');
    }

    return context.toString();
  }

  @override
  String visitInterpolation(Interpolation astNode, [StringBuffer? context]) {
    return '{{${astNode.value}}}';
  }

  @override
  String visitLetBinding(LetBinding astNode, [StringBuffer? context]) {
    if (astNode.value == null) {
      return 'let-${astNode.name}';
    }

    return 'let-${astNode.name}="${astNode.value}"';
  }

  @override
  String visitProperty(Property astNode, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('[${astNode.name}');

    if (astNode.postfix != null) {
      context.write('.${astNode.postfix}');
    }

    if (astNode.unit != null) {
      context.write('.${astNode.unit}');
    }

    context.write(']');

    if (astNode.value != null) {
      context.write('="${astNode.value}"');
    }

    return context.toString();
  }

  @override
  String visitReference(Reference astNode, [StringBuffer? context]) {
    var variable = '#${astNode.variable}';

    if (astNode.identifier != null) {
      return '$variable="${astNode.identifier}"';
    }

    return variable;
  }

  @override
  String visitStar(Star astNode, [StringBuffer? context]) {
    var name = '*${astNode.name}';

    if (astNode.value != null) {
      return '$name="${astNode.value}"';
    }

    return name;
  }

  @override
  String visitText(Text astNode, [StringBuffer? context]) {
    return astNode.value;
  }
}
