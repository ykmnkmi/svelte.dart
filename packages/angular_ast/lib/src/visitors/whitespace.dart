import '../ast.dart';
import 'recursive.dart';

class MinimizeWhitespaceVisitor extends RecursiveTemplateAstVisitor<bool> {
  const MinimizeWhitespaceVisitor();

  List<Standalone> visitAllRoot(List<Standalone> rootNodes) {
    return visitAll(visitRemovingWhitespace(rootNodes)) as List<Standalone>;
  }

  @override
  Node visitContainer(Container node, [bool? context]) {
    if (bailOutToPreserveWhitespace(node)) {
      return node;
    }

    if (node.childNodes.isNotEmpty) {
      node = Container.from(node,
          annotations: node.annotations, childNodes: visitRemovingWhitespace(node.childNodes), stars: node.stars);
    }

    return super.visitContainer(node, true);
  }

  @override
  Node visitElement(Element node, [bool? context]) {
    if (bailOutToPreserveWhitespace(node)) {
      return node;
    }

    if (node.childNodes.isNotEmpty) {
      node = Element.from(node, node.name, node.closeComplement,
          attributes: node.attributes,
          childNodes: visitRemovingWhitespace(node.childNodes),
          events: node.events,
          properties: node.properties,
          references: node.references,
          bananas: node.bananas,
          stars: node.stars,
          annotations: node.annotations);
    }

    return super.visitElement(node, true)!;
  }

  @override
  Node visitEmbeddedTemplate(EmbeddedNode node, [bool? context]) {
    if (bailOutToPreserveWhitespace(node)) {
      return node;
    }

    if (node.childNodes.isNotEmpty) {
      node = EmbeddedNode.from(node,
          annotations: node.annotations,
          attributes: node.attributes,
          childNodes: visitRemovingWhitespace(node.childNodes),
          events: node.events,
          properties: node.properties,
          references: node.references,
          letBindings: node.letBindings);
    }

    return super.visitEmbeddedTemplate(node, true);
  }

  @override
  Node visitText(Text node, [bool? context]) {
    return Text.from(node, node.value.replaceAll(ngsp, ' '));
  }

  List<Standalone> visitRemovingWhitespace(List<Standalone?> childNodes) {
    // 1. Remove whitespace-only text nodes where previous/after nodes are
    //    not an InterpolationAst, but are anything else. For example, in the
    //    following case:
    //
    // <div>
    //   <span>Hello World</span>
    // </div>
    //
    // ... we should collapse to "<div><span>Hello World</span></div>".
    Node? prevNode;
    Node? nextNode = childNodes.length > 1 ? childNodes[1] : null;
    var returnedNodes = <Standalone>[];

    for (var i = 0, l = childNodes.length; i < l; i++) {
      var currentNode = childNodes[i];

      if (currentNode is Text) {
        // This is because the re-assignment (currentNode =) below disables the
        // type promotion, but we want everywhere in this if (...) { ... } block
        // to assume it is a TextAst at this point.
        var currentNodeCasted = currentNode;

        // Node i, where i - 1 and i + 1 are not interpolations, we can
        // completely remove the (text) node. For example, this would take
        // `<span>\n</span>` and return `<span></span>`.
        if (shouldCollapseAdjacentTo(prevNode, lnode: true) &&
            shouldCollapseAdjacentTo(nextNode, lnode: false) &&
            currentNodeCasted.value.trim().isEmpty &&
            !currentNodeCasted.value.contains(nbsp)) {
          currentNode = null;
        } else {
          // Otherwise, we collapse whitespace:
          // 1. All adjacent whitespace is collapsed into a single space.
          // 2. Depending on siblings, *also* trimLeft or trimRight.
          currentNode = collapseWhitespace(currentNode,
              trimLeft: shouldCollapseAdjacentTo(prevNode, lnode: true),
              trimRight: shouldCollapseAdjacentTo(nextNode, lnode: false));
        }
      }

      if (currentNode != null) {
        returnedNodes.add(currentNode);
      }

      prevNode = currentNode;
      nextNode = i < l - 2 ? childNodes[i + 2] : null;
    }

    return returnedNodes;
  }

  // https://developer.mozilla.org/en-US/docs/Web/HTML/Inline_elements
  static final Set<String> commonInlineElements = <String>{
    'a',
    'abbr',
    'acronym',
    'b',
    'bdo',
    'big',
    'br',
    'button',
    'cite',
    'code',
    'dfn',
    'em',
    'i',
    'img',
    'input',
    'kbd',
    'label',
    'map',
    'object',
    'q',
    'samp',
    'script',
    'select',
    'small',
    'span',
    'strong',
    'sub',
    'sup',
    'textarea',
    'time',
    'tt',
    'var',
  };

  static const String nbsp = '\u00A0';

  static const String ngsp = '\uE500';

  static RegExp get allWhitespace {
    return RegExp(r'\s\s+', multiLine: true);
  }

  static Text? collapseWhitespace(Text text, {required bool trimLeft, required bool trimRight}) {
    // Collapses all adjacent whitespace into a single space.
    const preserveNbsp = '\uE501';
    var value = text.value.replaceAll(nbsp, preserveNbsp);
    value = value.replaceAll(allWhitespace, ' ');

    if (trimLeft) {
      value = value.trimLeft();
    }

    if (trimRight) {
      value = value.trimRight();
    }

    value = value.replaceAll(preserveNbsp, nbsp);

    if (value.isEmpty) {
      return null;
    }

    return Text.from(text, value);
  }

  static bool bailOutToPreserveWhitespace(Standalone node) {
    var annotations = const <Annotation>[];

    if (node is Container) {
      annotations = node.annotations;
    } else if (node is Element) {
      if (node.name == 'pre') {
        // Don't modify whitespace of preformatted text.
        return true;
      }

      annotations = node.annotations;
    } else if (node is EmbeddedNode) {
      annotations = node.annotations;
    }

    for (var annotation in annotations) {
      if (annotation.name == 'preserveWhitespace') {
        return true;
      }
    }

    return false;
  }

  static bool isPotentiallyInline(Element node) {
    return commonInlineElements.contains(node.name.toLowerCase());
  }

  static bool shouldCollapseAdjacentTo(Node? node, {bool lnode = false}) {
    return node is! Standalone ||
        // Sometimes collapse adjacent to another element if not inline.
        node is Element && !isPotentiallyInline(node) ||
        // Sometimes collapse adjacent to a template or container node.
        shouldCollapseWrapperNode(node, lnode: lnode);
  }

  // Determining how to collapse next to a template/container is more complex.
  //
  // If the <template> wraps HTML DOM, i.e. <div *ngIf>, we should just use the
  // immediate wrapped DOM node as the indicator of collapsing. <div *ngIf>
  // should be treated just like a <div>.
  //
  // Otherwise, return `false` and assume it could be a source of inline nodes.
  static bool shouldCollapseWrapperNode(Standalone node, {bool lnode = false}) {
    if (node is! Container && node is! EmbeddedNode) {
      return false;
    }

    var nodes = node.childNodes;

    if (nodes.isNotEmpty) {
      var checkChild = lnode ? nodes.last : nodes.first;

      // Cover the corner case of:
      // <template [ngIf]>
      //   <span>Hello</span>
      // </template>
      //
      // The immediate child of <template> (in either direction) is a TextAst,
      // but it is just whitespace, so we want to consider the next relevant
      // node.
      if (checkChild is Text && checkChild.value.trim().isEmpty) {
        if (nodes.length == 1) {
          // Another corner-corner case:
          //
          // <template [ngIf]>
          //   <div>
          //     Dynamic Content:
          //     <template>
          //     </template>
          //   </div>
          // </template>
          //
          // We want to assume the inner-template will be modified dynamically
          // at runtime (content inserted), so we assume inline instead of
          // assuming block, hence returning false.
          return false;
        }

        checkChild = lnode ? nodes[nodes.length - 2] : nodes[1];
      }

      return shouldCollapseAdjacentTo(checkChild);
    }

    return false;
  }
}
