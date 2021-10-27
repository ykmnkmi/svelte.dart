import '../ast.dart';
import '../visitor.dart';

class HumanizingTemplateAstVisitor extends Visitor<String, StringBuffer?> {
  const HumanizingTemplateAstVisitor();

  @override
  String visitAnnotation(Annotation node, [StringBuffer? context]) {
    return '@${node.name}';
  }

  @override
  String visitAttribute(Attribute node, [StringBuffer? context]) {
    if (node.value != null) {
      return '${node.name}="${node.value}"';
    }

    return node.name;
  }

  @override
  String visitBanana(Banana node, [StringBuffer? context]) {
    var name = '[(${node.name})]';

    if (node.value != null) {
      return '$name="${node.value}"';
    }

    return name;
  }

  @override
  String visitCloseElement(CloseElement node, [StringBuffer? context]) {
    context ??= StringBuffer();
    context
      ..write('</')
      ..write(node.name)
      ..write('>');
    return context.toString();
  }

  @override
  String visitComment(Comment node, [StringBuffer? context]) {
    return '<!--${node.value}-->';
  }

  @override
  String visitContainer(Container node, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('<ng-container');

    if (node.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.annotations.map<String>(visitAnnotation), ' ');
    }

    if (node.stars.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.stars.map<String>(visitStar), ' ');
    }

    context.write('>');

    if (node.childNodes.isNotEmpty) {
      context.writeAll(node.childNodes.map<String>((child) => child.accept(this) as String));
    }

    context.write('</ng-container>');
    return context.toString();
  }

  @override
  String visitElement(Element node, [StringBuffer? context]) {
    context ??= StringBuffer();
    context
      ..write('<')
      ..write(node.name);

    if (node.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.annotations.map<String>(visitAnnotation), ' ');
    }

    if (node.attributes.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.attributes.map<String>(visitAttribute), ' ');
    }

    if (node.events.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.events.map<String>(visitEvent), ' ');
    }

    if (node.properties.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.properties.map<String>(visitProperty), ' ');
    }

    if (node.references.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.references.map<String>(visitReference), ' ');
    }

    if (node.bananas.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.bananas.map<String>(visitBanana), ' ');
    }

    if (node.stars.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.stars.map<String>(visitStar), ' ');
    }

    if (node.isSynthetic) {
      context.write(node.isVoidElement ? '/>' : '>');
    } else {
      context.write(node.endToken!.lexeme);
    }

    if (node.childNodes.isNotEmpty) {
      context.writeAll(node.childNodes.map<String>((child) => child.accept(this) as String));
    }

    if (node.closeComplement != null) {
      context.write(visitCloseElement(node.closeComplement!));
    }

    return context.toString();
  }

  @override
  String visitEmbeddedContent(EmbeddedContent node, [StringBuffer? context]) {
    context ??= StringBuffer();

    if (node.selector != null) {
      context.write('<ng-content select="${node.selector}">');
    } else {
      context.write('<ng-content>');
    }

    context.write('</ng-content>');
    return context.toString();
  }

  @override
  String visitEmbeddedTemplate(EmbeddedNode node, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('<template');

    if (node.annotations.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.annotations.map<String>(visitAnnotation), ' ');
    }

    if (node.attributes.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.attributes.map<String>(visitAttribute), ' ');
    }

    if (node.properties.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.properties.map<String>(visitProperty), ' ');
    }

    if (node.references.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.references.map<String>(visitReference), ' ');
    }

    if (node.letBindings.isNotEmpty) {
      context
        ..write(' ')
        ..writeAll(node.letBindings.map<String>(visitLetBinding), ' ');
    }

    context.write('>');

    if (node.childNodes.isNotEmpty) {
      context.writeAll(node.childNodes.map<String>((child) => child.accept(this) as String));
    }

    context.write('</template>');
    return context.toString();
  }

  @override
  String visitEvent(Event node, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('(${node.name}');

    if (node.reductions.isNotEmpty) {
      context.write('.${node.reductions.join('.')}');
    }

    context.write(')');

    if (node.value != null) {
      context.write('="${node.value}"');
    }

    return context.toString();
  }

  @override
  String visitInterpolation(Interpolation node, [StringBuffer? context]) {
    return '{{${node.value}}}';
  }

  @override
  String visitLetBinding(LetBinding node, [StringBuffer? context]) {
    if (node.value == null) {
      return 'let-${node.name}';
    }

    return 'let-${node.name}="${node.value}"';
  }

  @override
  String visitProperty(Property node, [StringBuffer? context]) {
    context ??= StringBuffer();
    context.write('[${node.name}');

    if (node.postfix != null) {
      context.write('.${node.postfix}');
    }

    if (node.unit != null) {
      context.write('.${node.unit}');
    }

    context.write(']');

    if (node.value != null) {
      context.write('="${node.value}"');
    }

    return context.toString();
  }

  @override
  String visitReference(Reference node, [StringBuffer? context]) {
    var variable = '#${node.variable}';

    if (node.identifier != null) {
      return '$variable="${node.identifier}"';
    }

    return variable;
  }

  @override
  String visitStar(Star node, [StringBuffer? context]) {
    var name = '*${node.name}';

    if (node.value != null) {
      return '$name="${node.value}"';
    }

    return name;
  }

  @override
  String visitText(Text node, [StringBuffer? context]) {
    return node.value;
  }
}
