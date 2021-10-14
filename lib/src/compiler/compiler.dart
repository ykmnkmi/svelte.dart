import 'package:angular_ast/angular_ast.dart' hide parse;
import 'package:path/path.dart' as path;

import 'parser.dart';

String compile(String template, {required String sourceUrl, List<String> exports = const <String>[]}) {
  var nodes = parse(template, sourceUrl: sourceUrl);
  var name = sourceUrl.isEmpty ? 'App' : path.basenameWithoutExtension(sourceUrl);
  return compileNodes(name, nodes);
}

String compileNodes(String name, List<StandaloneTemplateAst> nodes, {List<String> exports = const <String>[]}) {
  var compiler = TemplateCompiler(name, nodes, exports);
  return compiler.compile();
}

abstract class Compiler {
  Compiler(this.name, [this.exports = const <String>[]])
      : buffer = StringBuffer(),
        fields = <String>[],
        initialized = <String>[],
        constructed = <String>[],
        created = <String>[],
        mounted = <String>[],
        listened = <String>[],
        removed = <String>[],
        counts = <String, int>{};

  final String name;

  final List<String> exports;

  final StringBuffer buffer;

  final List<String> fields;

  final List<String> initialized;

  final List<String> constructed;

  final List<String> created;

  final List<String> mounted;

  final List<String> listened;

  final List<String> removed;

  final Map<String, int> counts;

  String getId(String tag) {
    var id = counts[tag] ??= 0;
    counts[tag] = ++id;
    return '$tag$id';
  }

  void mount(String id, [String? context]) {
    if (context == null) {
      mounted.add('insert(target, $id, anchor)');
    } else {
      mounted.add('append($context, $id)');
    }
  }

  int indent = 0;

  void tab() {
    indent += 1;
  }

  void untab() {
    indent -= 1;
  }

  void newline() {
    buffer.writeln();
  }

  void pad() {
    buffer.write('  ' * indent);
  }

  void write(String string) {
    buffer.write(string);
  }

  void line(String string) {
    pad();
    write(string);
    newline();
  }

  String compile() {
    if (listened.isNotEmpty) {
      initialized.add('mounted = false');
      fields
        ..add('bool mounted')
        ..add('late ${listened.length == 1 ? 'Function' : 'List<Function>'} dispose');
    }

    initialized.add('super(context, tree)');

    var className = '${name}Fragment';
    line('class $className extends Fragment<$name> {');
    tab();
    line('$className($name context, RenderTree tree)');
    tab();
    tab();
    pad();
    write(': ${initialized.first}');

    if (initialized.length > 1) {
      tab();

      for (var expression in initialized.skip(1)) {
        write(',');
        newline();
        pad();
        write(expression);
      }

      untab();
    }

    untab();

    if (constructed.isEmpty) {
      write(';');
      untab();
    } else {
      write(' {');

      for (var expression in constructed) {
        newline();
        pad();
        write('$expression;');
      }

      newline();
      untab();
      pad();
      write('}');
    }

    newline();
    newline();

    for (var field in fields) {
      line('$field;');
    }

    if (created.isNotEmpty) {
      newline();
      line('@override');
      line('void create() {');
      tab();

      for (var expression in created) {
        line('$expression;');
      }

      untab();
      line('}');
    }

    if (mounted.isNotEmpty) {
      newline();
      line('@override');
      line('void mount(Element target, [Node? anchor]) {');
      tab();

      for (var expression in mounted) {
        line('$expression;');
      }

      if (listened.isNotEmpty) {
        newline();
        line('if (!mounted) {');
        tab();
        pad();
        write('dispose = ');

        if (listened.length == 1) {
          write(listened.first);
        } else {
          write('<Function>[');
          newline();
          tab();

          for (var expression in listened) {
            line('$expression;');
          }

          untab();
          write(']');
        }

        write(';');
        newline();
        untab();
        line('}');
      }

      untab();
      line('}');
    }

    if (removed.isNotEmpty) {
      newline();
      line('@override');
      line('void detach([bool detaching = true]) {');
      tab();
      line('if (detaching) {');
      tab();

      for (var id in removed) {
        line('remove($id);');
      }

      untab();
      line('}');
      newline();

      if (listened.isNotEmpty) {
        line('mounted = false;');

        if (listened.length == 1) {
          line('dispose();');
        } else {
          line('dispose.forEach((fn) => fn());');
        }
      }

      untab();
      line('}');
    }

    untab();
    write('}');
    return buffer.toString();
  }
}

class TemplateCompiler extends Compiler implements TemplateAstVisitor<String?, String> {
  TemplateCompiler(String name, this.nodes, [List<String> exports = const <String>[]]) : super(name, exports);

  final List<StandaloneTemplateAst> nodes;

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
  String? visitAnnotation(AnnotationAst astNode, [String? context]) {
    throw UnimplementedError('visitAnnotation');
  }

  @override
  String? visitAttribute(AttributeAst astNode, [String? context]) {
    var id = context!;
    var attr = astNode.name;
    var value = astNode.value;
    created.add('attr($id, $attr, \'$value\')');
  }

  @override
  String? visitBanana(BananaAst astNode, [String? context]) {
    throw UnimplementedError('visitBanana');
  }

  @override
  String? visitCloseElement(CloseElementAst astNode, [String? context]) {
    throw UnimplementedError('visitCloseElement');
  }

  @override
  String? visitComment(CommentAst astNode, [String? context]) {
    throw UnimplementedError('visitComment');
  }

  @override
  String? visitContainer(ContainerAst astNode, [String? context]) {
    throw UnimplementedError('visitContainer');
  }

  @override
  String? visitElement(ElementAst node, [String? context]) {
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
  String? visitEmbeddedContent(EmbeddedContentAst astNode, [String? context]) {
    throw UnimplementedError('visitEmbeddedContent');
  }

  @override
  String? visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [String? context]) {
    throw UnimplementedError('visitEmbeddedTemplate');
  }

  @override
  String? visitEvent(EventAst astNode, [String? context]) {
    var id = context!;
    listened.add('listen($id, ${astNode.name}, (event) => context.${astNode.value})');
  }

  @override
  String? visitInterpolation(InterpolationAst astNode, [String? context]) {
    var id = getId('text');
    var identifier = astNode.value.trim();
    fields.add('late Text $id');
    created.add('$id = text(context.$identifier)');
    mount(id, context);
    return id;
  }

  @override
  String? visitLetBinding(LetBindingAst astNode, [String? context]) {
    throw UnimplementedError('visitLetBinding');
  }

  @override
  String? visitProperty(PropertyAst astNode, [String? context]) {
    throw UnimplementedError('visitProperty');
  }

  @override
  String? visitReference(ReferenceAst astNode, [String? context]) {
    throw UnimplementedError('visitReference');
  }

  @override
  String? visitStar(StarAst astNode, [String? context]) {
    throw UnimplementedError('visitStar');
  }

  @override
  String? visitText(TextAst astNode, [String? context]) {
    var id = getId('text');
    var text = astNode.value;
    fields.add('late Text $id');
    created.add(text == ' ' ? '$id = space()' : '$id = text(\'$text\')');
    mount(id, context);
    return id;
  }
}
