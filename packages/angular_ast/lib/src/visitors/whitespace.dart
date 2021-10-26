import '../ast.dart';
import 'recursive.dart';

/// Applies whitespace reduction to implement (`preserveWhitespace: false`).
///
/// Use [visitAllRoot] to process root nodes:
/// ```dart
/// var nodes = parse(template, sourceUrl: url);
/// nodes = const MinimizeWhitespaceVisitor().visitAllRoot(nodes);
/// ```
class MinimizeWhitespaceVisitor extends RecursiveTemplateAstVisitor<bool> {
  const MinimizeWhitespaceVisitor();

  /// Returns [rootNodes], visited, with whitespace removed.
  List<StandaloneTemplate> visitAllRoot(List<StandaloneTemplate> rootNodes) {
    return visitAll(_visitRemovingWhitespace(rootNodes)) as List<StandaloneTemplate>;
  }

  @override
  Template visitContainer(Container astNode, [bool? context]) {
    if (_bailOutToPreserveWhitespace(astNode)) {
      return astNode;
    }

    if (astNode.childNodes.isNotEmpty) {
      astNode = Container.from(
        astNode,
        annotations: astNode.annotations,
        childNodes: _visitRemovingWhitespace(astNode.childNodes),
        stars: astNode.stars,
      );
    }
    return super.visitContainer(astNode, true);
  }

  @override
  Template visitElement(Element astNode, [bool? context]) {
    if (_bailOutToPreserveWhitespace(astNode)) {
      return astNode;
    }

    if (astNode.childNodes.isNotEmpty) {
      astNode = Element.from(astNode, astNode.name, astNode.closeComplement,
          attributes: astNode.attributes,
          childNodes: _visitRemovingWhitespace(astNode.childNodes),
          events: astNode.events,
          properties: astNode.properties,
          references: astNode.references,
          bananas: astNode.bananas,
          stars: astNode.stars,
          annotations: astNode.annotations);
    }

    return super.visitElement(astNode, true)!;
  }

  @override
  Template visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [bool? context]) {
    if (_bailOutToPreserveWhitespace(astNode)) {
      return astNode;
    }

    if (astNode.childNodes.isNotEmpty) {
      astNode = EmbeddedTemplateAst.from(astNode,
          annotations: astNode.annotations,
          attributes: astNode.attributes,
          childNodes: _visitRemovingWhitespace(astNode.childNodes),
          events: astNode.events,
          properties: astNode.properties,
          references: astNode.references,
          letBindings: astNode.letBindings);
    }

    return super.visitEmbeddedTemplate(astNode, true);
  }

  @override
  Template visitText(Text astNode, [bool? context]) {
    return Text.from(astNode, astNode.value.replaceAll(_ngsp, ' '));
  }

  /// Returns [text], with all significant whitespace reduced to a single space.
  static Text? _collapseWhitespace(Text text, {required bool trimLeft, required bool trimRight}) {
    // Collapses all adjacent whitespace into a single space.
    const preserveNbsp = '\uE501';
    var value = text.value.replaceAll(_nbsp, preserveNbsp);
    value = value.replaceAll(_allWhitespace, ' ');

    if (trimLeft) {
      value = value.trimLeft();
    }

    if (trimRight) {
      value = value.trimRight();
    }

    value = value.replaceAll(preserveNbsp, _nbsp);

    if (value.isEmpty) {
      return null;
    }

    return Text.from(text, value);
  }

  List<StandaloneTemplate> _visitRemovingWhitespace(List<StandaloneTemplate?> childNodes) {
    // 1. Remove whitespace-only text nodes where previous/after nodes are
    //    not an InterpolationAst, but are anything else. For example, in the
    //    following case:
    //
    // <div>
    //   <span>Hello World</span>
    // </div>
    //
    // ... we should collapse to "<div><span>Hello World</span></div>".
    Template? prevNode;
    Template? nextNode = childNodes.length > 1 ? childNodes[1] : null;
    var returnedNodes = <StandaloneTemplate>[];

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
        if (_shouldCollapseAdjacentTo(prevNode, lastNode: true) &&
            _shouldCollapseAdjacentTo(nextNode, lastNode: false) &&
            currentNodeCasted.value.trim().isEmpty &&
            !currentNodeCasted.value.contains(_nbsp)) {
          currentNode = null;
        } else {
          // Otherwise, we collapse whitespace:
          // 1. All adjacent whitespace is collapsed into a single space.
          // 2. Depending on siblings, *also* trimLeft or trimRight.
          currentNode = _collapseWhitespace(currentNode,
              trimLeft: _shouldCollapseAdjacentTo(prevNode, lastNode: true),
              trimRight: _shouldCollapseAdjacentTo(nextNode, lastNode: false));
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
  static final Set<String> _commonInlineElements = <String>{
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

  static final RegExp _allWhitespace = RegExp(r'\s\s+', multiLine: true);

  static const String _nbsp = '\u00A0';

  static const String _ngsp = '\uE500';

  static bool _bailOutToPreserveWhitespace(StandaloneTemplate astNode) {
    var annotations = const <Annotation>[];

    if (astNode is Container) {
      annotations = astNode.annotations;
    } else if (astNode is Element) {
      if (astNode.name == 'pre') {
        // Don't modify whitespace of preformatted text.
        return true;
      }

      annotations = astNode.annotations;
    } else if (astNode is EmbeddedTemplateAst) {
      annotations = astNode.annotations;
    }

    for (var annotation in annotations) {
      if (annotation.name == 'preserveWhitespace') {
        return true;
      }
    }

    return false;
  }

  /// Returns whether [tagName] is normally an `display: inline` element.
  ///
  /// This helps to make the right (default) decision around whitespace.
  static bool _isPotentiallyInline(Element astNode) {
    return _commonInlineElements.contains(astNode.name.toLowerCase());
  }

  /// Whether [astNode] should be treated as insignficant to nearby whitespace.
  static bool _shouldCollapseAdjacentTo(Template? astNode, {bool lastNode = false}) {
    return astNode is! StandaloneTemplate ||
        // Sometimes collapse adjacent to another element if not inline.
        astNode is Element && !_isPotentiallyInline(astNode) ||
        // Sometimes collapse adjacent to a template or container node.
        _shouldCollapseWrapperNode(astNode, lastNode: lastNode);
  }

  // Determining how to collapse next to a template/container is more complex.
  //
  // If the <template> wraps HTML DOM, i.e. <div *ngIf>, we should just use the
  // immediate wrapped DOM node as the indicator of collapsing. <div *ngIf>
  // should be treated just like a <div>.
  //
  // Otherwise, return `false` and assume it could be a source of inline nodes.
  static bool _shouldCollapseWrapperNode(StandaloneTemplate astNode, {bool lastNode = false}) {
    if (astNode is! Container && astNode is! EmbeddedTemplateAst) {
      return false;
    }

    var nodes = astNode.childNodes;

    if (nodes.isNotEmpty) {
      var checkChild = lastNode ? nodes.last : nodes.first;
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

        checkChild = lastNode ? nodes[nodes.length - 2] : nodes[1];
      }

      return _shouldCollapseAdjacentTo(checkChild);
    }
    return false;
  }
}
