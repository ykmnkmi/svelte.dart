import 'package:angular_ast/angular_ast.dart' hide parse;
import 'package:path/path.dart' as path;

import 'compiler.dart';
import 'parser.dart';

String compile(String template, {required String sourceUrl, List<String> exports = const <String>[]}) {
  var nodes = parse(template, sourceUrl: sourceUrl);
  var name = sourceUrl.isEmpty ? 'App' : path.basenameWithoutExtension(sourceUrl);
  return compileNodes(name, nodes);
}

String compileNodes(String name, List<StandaloneTemplate> nodes, {List<String> exports = const <String>[]}) {
  var compiler = FragmentCompiler(name, nodes, exports);
  return compiler.compile();
}

class FragmentCompiler extends Compiler implements TemplateVisitor<String?, String> {
  FragmentCompiler(String name, this.nodes, [List<String> exports = const <String>[]]) : super(name, exports);

  final List<StandaloneTemplate> nodes;

  @override
  String compile() {
    for (var node in nodes) {
      var id = node.accept(this);

      if (id != null) {
        removed.add(id);
      }
    }

    return super.compile();
  }

  @override
  String? visitAnnotation(Annotation astNode, [String? context]) {
    throw UnimplementedError('visitAnnotation');
  }

  @override
  String? visitAttribute(Attribute astNode, [String? context]) {
    var id = context!;
    var attr = astNode.name;

    created.add('attr($id, $attr, \'${interpolateAll(astNode.childNodes)}\')');
  }

  @override
  String? visitBanana(Banana astNode, [String? context]) {
    throw UnimplementedError('visitBanana');
  }

  @override
  String? visitCloseElement(CloseElement astNode, [String? context]) {
    throw UnimplementedError('visitCloseElement');
  }

  @override
  String? visitComment(Comment astNode, [String? context]) {
    throw UnimplementedError('visitComment');
  }

  @override
  String? visitContainer(Container astNode, [String? context]) {
    throw UnimplementedError('visitContainer');
  }

  @override
  String? visitElement(Element node, [String? context]) {
    var id = getId(node.name);
    fields.add('late Element $id');
    created.add('$id = element(\'${node.name}\')');
    mount(id, context);

    for (var attribute in node.attributes) {
      attribute.accept(this, id);
    }

    for (var property in node.properties) {
      property.accept(this, id);
    }

    for (var event in node.events) {
      event.accept(this, id);
    }

    if (node.childNodes.isNotEmpty) {
      for (var child in node.childNodes) {
        child.accept(this, id);
      }
    }

    return id;
  }

  @override
  String? visitEmbeddedContent(EmbeddedContent astNode, [String? context]) {
    throw UnimplementedError('visitEmbeddedContent');
  }

  @override
  String? visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [String? context]) {
    throw UnimplementedError('visitEmbeddedTemplate');
  }

  @override
  String? visitEvent(Event astNode, [String? context]) {
    var id = context!;
    listened.add('listen($id, ${astNode.name}, (event) => context.${astNode.value})');
  }

  @override
  String? visitInterpolation(Interpolation astNode, [String? context]) {
    var id = getId('text');
    fields.add('late Text $id');
    created.add('$id = text(\'${interpolate(astNode)}\')');
    mount(id, context);
    return id;
  }

  @override
  String? visitLetBinding(LetBinding astNode, [String? context]) {
    throw UnimplementedError('visitLetBinding');
  }

  @override
  String? visitProperty(Property astNode, [String? context]) {
    throw UnimplementedError('visitProperty');
  }

  @override
  String? visitReference(Reference astNode, [String? context]) {
    throw UnimplementedError('visitReference');
  }

  @override
  String? visitStar(Star astNode, [String? context]) {
    throw UnimplementedError('visitStar');
  }

  @override
  String? visitText(Text astNode, [String? context]) {
    var id = getId('text');
    var text = astNode.value;
    fields.add('late Text $id');
    created.add(text == ' ' ? '$id = space()' : '$id = text(\'$text\')');
    mount(id, context);
    return id;
  }

  static String interpolate(StandaloneTemplate node) {
    if (node is Interpolation) {
      return '\${context.${node.value}}';
    }

    if (node is Text) {
      return node.value;
    }

    throw UnimplementedError();
  }

  static String interpolateAll(Iterable<StandaloneTemplate> nodes) {
    var buffer = StringBuffer();

    for (var node in nodes) {
      buffer.write(interpolate(node));
    }

    return buffer.toString();
  }
}
