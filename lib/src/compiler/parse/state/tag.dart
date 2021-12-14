import '../../utils/html.dart';
import '../../utils/names.dart';
import '../../utils/patterns.dart';
import '../../interface.dart';
import '../parse.dart';

extension TagParser on Parser {
  static const Map<String, String> metaTags = <String, String>{
    'svelte:head': 'Head',
    'svelte:options': 'Options',
    'svelte:window': 'Window',
    'svelte:body': 'Body',
  };

  static const Set<String> validMetaTags = <String>{
    'svelte:head',
    'svelte:options',
    'svelte:window',
    'svelte:body',
    'svelte:self',
    'svelte:component',
    'svelte:fragment',
  };

  static late final RegExp selfRe = compile(r'^svelte:self(?=[\s/>])');

  static late final RegExp componentRe = compile(r'^svelte:component(?=[\s/>])');

  static late final RegExp slotRe = compile(r'^svelte:fragment(?=[\s/>])');

  static late final RegExp componentNameRe = compile('^[A-Z].*');

  bool parentIsHead() {
    for (var node in stack.reversed) {
      var type = node.type;
      if (type == 'Head') return true;
      if (type == 'Element' || type == 'InlineComponent') return false;
    }

    return false;
  }

  void tag() {
    expect('<');

    var start = index;
    var parent = current;

    if (scan('!--')) {
      var data = readUntil('-->');

      if (scan('-->')) {
        current.children.add(Node(type: 'CommentTag', start: start, data: data));
        return;
      }

      error('unclosed-comment', 'comment was left open, expected -->');
    }

    var isClosingTag = scan('/');
    var name = readTagName();
    var slug = metaTags[name];

    if (slug != null) {
      slug = slug.toLowerCase();

      if (isClosingTag) {
        if ((name == 'svelte:window' || name == 'svelte:body') && current.children.isNotEmpty) {
          error('invalid-$slug-content', '<$name> cannot have children', position: current.children.first.start);
        }
      } else {
        if (this.metaTags.contains(name)) {
          error('duplicate-$slug', 'a component can only have one <$name> tag', position: start);
        }

        if (stack.length > 1) {
          error('invalid-$slug-placement', '<$name> cannot be inside elements or blocks', position: start);
        }

        this.metaTags.add(name);
      }
    }

    var type = metaTags[name];

    if (type == null && componentNameRe.hasMatch(name) || name == 'svelte:self' || name == 'svelte:component') {
      type = 'InlineComponent';
    } else if (name == 'svelte:fragment') {
      type = 'SlotTemplate';
    } else if (name == 'title' && parentIsHead()) {
      type = 'Title';
    } else if (name == 'slot') {
      type = 'Slot';
    } else {
      type = 'Element';
    }

    var element = Node(type: type, name: name, start: start);

    allowWhitespace();

    if (isClosingTag) {
      if (isVoid(name)) {
        var message = '<$name> is a void element and cannot have children, or a closing tag';
        error('invalid-void-content', message, position: start);
      }

      expect('>');

      var lastClosedTag = lastAutoClosedTag;

      while (parent.name != name) {
        if (parent.type != 'Element') {
          var code = 'invalid-closing-tag';
          var prefix = '</$name> attempted to close';

          if (lastClosedTag != null && lastClosedTag.tag == name) {
            var message = '$prefix $name that was already automatically closed by ${lastClosedTag.reason}';
            error(code, message, position: start);
          }

          var message = '$prefix an element that was not open';
          error(code, message, position: start);
        }

        parent.end = start;
        stack.removeLast();
        parent = current;
      }

      parent.end = index;
      stack.removeLast();

      if (lastClosedTag != null && stack.length < lastClosedTag.depth) {
        lastAutoClosedTag = null;
      }

      return;
    } else if (closingTagOmitted(parent.name, name)) {
      parent.end = start;
      stack.removeLast();
      lastAutoClosedTag = LastAutoClosedTag(name, name, stack.length);
    }

    // TODO: attribute parsing
    // TODO: svelte:component parsing
    // TODO: top-level script/style parsing

    current.children.add(element);

    var selfClosing = scan('/') || isVoid(name);

    expect('>');

    if (selfClosing) {
      element.end = index;
    } else if (name == 'textarea') {
      // TODO: read textarea content
      throw UnimplementedError();
    } else if (name == 'script' || name == 'style') {
      // TODO: read script/style content
      throw UnimplementedError();
    } else {
      stack.add(element);
    }
  }

  String readTagName() {
    // TODO: implement readTagName
    throw UnimplementedError();
  }
}
