import 'package:source_span/source_span.dart';

import '../token/tokens.dart';
import '../visitor.dart';

/// Represents an AST node parsed from an Angular template.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Template {
  /// Initializes an AST node by specifying where it was parsed from.
  ///
  /// This constructor is considered a convenience for most forms of ASTs.
  const Template.parsed(this.beginToken, this.endToken, this._sourceFile);

  /// First token that was used to form this AST.
  final NgToken? beginToken;

  /// Last token that was used to form this AST.
  final NgToken? endToken;

  // All parsed ASTs come from a source file; used to get a source span.
  final SourceFile _sourceFile;

  /// Segment of source text from which the AST was parsed from.
  ///
  /// Includes all *significant* parts of the source text, including child nodes
  /// and identifying characters. May not include pre or post whitespace or
  /// delimiters.
  SourceSpan get sourceSpan {
    return _sourceFile.span(beginToken!.offset, endToken!.end);
  }

  String? get sourceUrl {
    return _sourceFile.url.toString();
  }

  /// Whether this node did not truly originate from the parsed source.
  ///
  /// May be `true` when:
  /// - The parser needed this node to have a valid tree, but it was missing
  /// - A developer created a node programmatically for testing
  /// - An original AST node was transformed
  ///
  /// In the _original AST node was transformed_ case, you can view the original
  /// AST by casting to [SyntheticTemplate] and reading the `origin` field.
  bool get isSynthetic {
    return false;
  }

  /// Whether this node needs to be 'attached' to another node to be valid.
  bool get isStandalone {
    return this is StandaloneTemplate;
  }

  /// Whether this node is capable of containing children and does.
  ///
  /// If `true` then [childNodes] has at least one element.
  bool get isParent {
    return false;
  }

  /// Child nodes, if any.
  List<StandaloneTemplate> get childNodes {
    return const <StandaloneTemplate>[];
  }

  /// Have the [visitor] start visiting this node.
  R? accept<R, C>(TemplateVisitor<R, C> visitor, [C context]);
}

/// A marker interface for [Template] types that do not need to be attached.
///
/// For example, elements, comments, and text may be free-standing nodes.
abstract class StandaloneTemplate implements Template {}

/// An AST node that was created programmatically (not from parsed source).
///
/// Synthetic ASTs are useful for:
/// - Error fallback (parser can add nodes that were missing but expected)
/// - Testing (i.e. comparing actual parsed nodes to expected synthetic ones)
/// - Transformation (modifying an AST tree that originally was parsed)
abstract class SyntheticTemplate implements Template {
  // Indicates that some fields/properties for this AST are not viewable.
  static Error _unsupported() {
    return UnsupportedError('Has no originating source code (synthetic)');
  }

  /// Create a synthetic AST that has no origin from parsed source.
  ///
  /// ASTs created this way will throw `UnsupportedError` on [sourceSpan].
  const SyntheticTemplate() : origin = null;

  /// Create a synthetic AST that originated from another AST node.
  const SyntheticTemplate.from(this.origin);

  /// What AST node this node originated from (before transformation); optional.
  final Template? origin;

  @override
  NgToken? get beginToken {
    if (origin != null) {
      return origin!.beginToken;
    }

    throw _unsupported();
  }

  @override
  NgToken? get endToken {
    if (origin != null) {
      return origin!.endToken;
    }

    throw _unsupported();
  }

  @override
  SourceSpan get sourceSpan {
    if (origin != null) {
      return origin!.sourceSpan;
    }

    throw _unsupported();
  }

  @override
  String? get sourceUrl {
    if (origin != null) {
      return origin!.sourceUrl;
    }

    throw _unsupported();
  }

  @override
  bool get isSynthetic {
    return true;
  }

  @override
  bool get isStandalone {
    return this is StandaloneTemplate;
  }

  @override
  bool get isParent {
    return childNodes.isNotEmpty;
  }

  /// Child nodes, if any.
  @override
  List<StandaloneTemplate> get childNodes {
    return const <StandaloneTemplate>[];
  }
}

/// Mixin used to preserve offsets of tokens to be able to reproduce the same
/// text. In addition, preserves offsets in cases where banana syntax and
/// template syntax are desugared.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class TagOffsetInfo {
  int get nameOffset;

  int? get valueOffset;

  int? get equalSignOffset;

  int? get quotedValueOffset;
}

/// Represents an interface for a parsed element decorator.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class ParsedDecorator {
  NgToken? get prefixToken;

  int? get prefixOffset;

  NgToken get nameToken;

  NgAttributeValueToken? get valueToken;

  NgToken? get suffixToken;

  int? get suffixOffset; //May be null for reference and template
}
