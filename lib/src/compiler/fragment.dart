import 'package:angular_ast/angular_ast.dart' hide parse;
import 'package:path/path.dart' as path;

import 'compiler.dart';
import 'parser.dart';

String compile(String template, {required String sourceUrl, List<String> exports = const <String>[]}) {
  var nodes = parse(template, sourceUrl: sourceUrl);
  var name = sourceUrl.isEmpty ? 'App' : path.basenameWithoutExtension(sourceUrl);
  return compileNodes(name, nodes);
}

String compileNodes(String name, List<Standalone> nodes, {List<String> exports = const <String>[]}) {
  var compiler = FragmentCompiler(name, nodes, exports);
  return compiler.compile();
}

class FragmentCompiler extends Compiler implements Visitor<String?, String> {
  FragmentCompiler(String name, this.nodes, [List<String> exports = const <String>[]]) : super(name, exports);

  final List<Standalone> nodes;

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
  String? visitAnnotation(Annotation node, [String? context]) {
    throw UnimplementedError('visitAnnotation');
  }

  @override
  String? visitAttribute(Attribute node, [String? context]) {
    var id = context!;
    var attr = node.name;

    created.add('attr($id, $attr, \'${interpolateAll(node.childNodes)}\')');
  }

  @override
  String? visitBanana(Banana node, [String? context]) {
    throw UnimplementedError('visitBanana');
  }

  @override
  String? visitCloseElement(CloseElement node, [String? context]) {
    throw UnimplementedError('visitCloseElement');
  }

  @override
  String? visitComment(Comment node, [String? context]) {
    throw UnimplementedError('visitComment');
  }

  @override
  String? visitContainer(Container node, [String? context]) {
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
  String? visitEmbeddedContent(EmbeddedContent node, [String? context]) {
    throw UnimplementedError('visitEmbeddedContent');
  }

  @override
  String? visitEmbeddedTemplate(EmbeddedNode node, [String? context]) {
    throw UnimplementedError('visitEmbeddedTemplate');
  }

  @override
  String? visitEvent(Event node, [String? context]) {
    var id = context!;
    listened.add('listen($id, ${node.name}, (event) => context.${node.value})');
  }

  @override
  String? visitInterpolation(Interpolation node, [String? context]) {
    var id = getId('text');
    fields.add('late Text $id');
    created.add('$id = text(\'${interpolate(node)}\')');
    mount(id, context);
    return id;
  }

  @override
  String? visitLetBinding(LetBinding node, [String? context]) {
    throw UnimplementedError('visitLetBinding');
  }

  @override
  String? visitProperty(Property node, [String? context]) {
    throw UnimplementedError('visitProperty');
  }

  @override
  String? visitReference(Reference node, [String? context]) {
    throw UnimplementedError('visitReference');
  }

  @override
  String? visitStar(Star node, [String? context]) {
    throw UnimplementedError('visitStar');
  }

  @override
  String? visitText(Text node, [String? context]) {
    var id = getId('text');
    var text = node.value;
    fields.add('late Text $id');
    created.add(text == ' ' ? '$id = space()' : '$id = text(\'$text\')');
    mount(id, context);
    return id;
  }

  static String interpolate(Standalone node) {
    if (node is Interpolation) {
      return '\${context.${node.value}}';
    }

    if (node is Text) {
      return node.value;
    }

    throw UnimplementedError();
  }

  static String interpolateAll(Iterable<Standalone> nodes) {
    var buffer = StringBuffer();

    for (var node in nodes) {
      buffer.write(interpolate(node));
    }

    return buffer.toString();
  }
}
