import 'package:source_span/source_span.dart' show SourceFile, SourceSpan;

import '../token/tokens.dart';
import '../visitor.dart';

abstract class Node {
  const Node.parsed(this.beginToken, this.endToken, this._sourceFile);

  final Token? beginToken;

  final Token? endToken;

  // All parsed ASTs come from a source file; used to get a source span.
  final SourceFile _sourceFile;

  SourceSpan get sourceSpan {
    return _sourceFile.span(beginToken!.offset, endToken!.end);
  }

  String? get sourceUrl {
    return _sourceFile.url.toString();
  }

  bool get isSynthetic {
    return false;
  }

  bool get isStandalone {
    return this is Standalone;
  }

  bool get isParent {
    return false;
  }

  List<Standalone> get childNodes {
    return const <Standalone>[];
  }

  R? accept<R, C>(Visitor<R, C> visitor, [C context]);
}

abstract class Standalone implements Node {}

abstract class Synthetic implements Node {
  const Synthetic() : origin = null;

  const Synthetic.from(this.origin);

  final Node? origin;

  @override
  Token? get beginToken {
    if (origin != null) {
      return origin!.beginToken;
    }

    throw unsupported();
  }

  @override
  Token? get endToken {
    if (origin != null) {
      return origin!.endToken;
    }

    throw unsupported();
  }

  @override
  SourceSpan get sourceSpan {
    if (origin != null) {
      return origin!.sourceSpan;
    }

    throw unsupported();
  }

  @override
  String? get sourceUrl {
    if (origin != null) {
      return origin!.sourceUrl;
    }

    throw unsupported();
  }

  @override
  bool get isSynthetic {
    return true;
  }

  @override
  bool get isStandalone {
    return this is Standalone;
  }

  @override
  bool get isParent {
    return childNodes.isNotEmpty;
  }

  @override
  List<Standalone> get childNodes {
    return const <Standalone>[];
  }

  // Indicates that some fields/properties for this AST are not viewable.
  static Error unsupported() {
    return UnsupportedError('Has no originating source code (synthetic)');
  }
}

abstract class TagOffsetInfo {
  int get nameOffset;

  int? get valueOffset;

  int? get equalSignOffset;

  int? get quotedValueOffset;
}

abstract class ParsedDecorator {
  Token? get prefixToken;

  int? get prefixOffset;

  Token get nameToken;

  AttributeValueToken? get valueToken;

  Token? get suffixToken;

  int? get suffixOffset; //May be null for reference and template
}
