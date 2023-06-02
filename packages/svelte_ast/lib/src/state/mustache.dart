import 'package:analyzer/dart/ast/ast.dart'
    show AssignmentExpression, Expression, SimpleIdentifier;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/read.dart';
import 'package:svelte_ast/src/state/text.dart';

final RegExp _comma = RegExp('\\s*,\\s*');

final RegExp _eachIn = RegExp('\\s*in\\s*');

extension MustacheParser on Parser {
  Node mustache() {
    var start = position;
    expect(openCurlRe);

    Node node;

    if (scan('#')) {
      node = _parseBlock(start);
    } else if (scan('@debug')) {
      node = _parseDebugTag(start);
    } else if (scan('@const')) {
      node = _parseConstTag(start);
    } else {
      node = _parseExpression(start);
    }

    return node;
  }

  Node _parseBlock(int start) {
    Node node;

    if (match('if')) {
      node = _parseIfBlock(start);
    } else if (match('each')) {
      node = _parseEachBlock(start);
    } else if (match('await')) {
      node = _parseAwaitBlock(start);
    } else {
      error(expectedBlockType);
    }

    return node;
  }

  IfBlock _parseIfBlock(int start) {
    const elseEndIf = <String>[':else', '/if'];
    const endIf = <String>['/if'];

    expect('if');
    allowSpace(required: true);

    var test = expression();
    var body = blockBody(elseEndIf);
    var orElse = const <Node>[];

    if (scan(':else')) {
      if (match(closeCurlRe)) {
        orElse = blockBody(endIf);
      } else {
        allowSpace(required: true);
        orElse = <Node>[_parseIfBlock(position)];
      }
    } else {
      expect('/if');
      expect(closeCurlRe);
    }

    return IfBlock(
      start: start,
      end: position,
      test: test,
      body: body,
      orElse: orElse,
    );
  }

  EachBlock _parseEachBlock(int start) {
    const elseEndEach = <String>[':else', '/each'];
    const endEach = <String>['/each'];

    expect('each');
    allowSpace(required: true);

    var context = pattern();
    expect(_eachIn);

    var value = expression();

    String? index;

    if (scan(_comma)) {
      index = identifier();
    }

    allowSpace();

    Expression? key;

    if (match('(')) {
      key = expression();
    }

    var body = blockBody(elseEndEach);
    var orElse = const <Node>[];

    if (scan(':else')) {
      orElse = blockBody(endEach);
    }

    expect('/each');
    expect(closeCurlRe);

    return EachBlock(
      start: start,
      end: position,
      context: context,
      iterable: value,
      body: body,
      index: index,
      key: key,
      orElse: orElse,
    );
  }

  IfBlock _parseAwaitBlock(int start) {
    // const elseEndAwait = <String>[':catch', '/await'];
    // const endAwait = <String>['/await'];

    expect('await');
    allowSpace(required: true);

    var future = expression();
    throw UnimplementedError('$future');
  }

  List<Node> blockBody(List<String> endTags) {
    expect(closeCurlRe);

    var nodes = <Node>[];
    endTagsStack.add(endTags);

    outer:
    while (isNotDone) {
      if (match(openCurlRe)) {
        var lastMatchEnd = lastMatch!.end;

        for (var tag in endTags) {
          if (matchFrom(tag, lastMatchEnd)) {
            position = lastMatchEnd;
            break outer;
          }
        }

        nodes.add(mustache());
      } else if (text() case var node?) {
        nodes.add(node);
      }
    }

    endTagsStack.removeLast();

    if (isDone) {
      // TODO(mustache): replace with error
      throw StateError(endTags.join(', '));
    }

    return nodes;
  }

  DebugTag _parseDebugTag(int start) {
    var identifiers = <SimpleIdentifier>[];

    if (!scan(closeCurlRe)) {
      allowSpace(required: true);

      do {
        var identifier = expression();

        if (identifier is! SimpleIdentifier) {
          error(invalidDebugArgs, start);
        }

        identifiers.add(identifier);
      } while (scan(_comma));

      expect(closeCurlRe);
    }

    return DebugTag(
      start: start,
      end: position,
      identifiers: identifiers,
    );
  }

  ConstTag _parseConstTag(int start) {
    allowSpace(required: true);

    var assign = expression();

    if (assign is! AssignmentExpression) {
      error(invalidConstArgs, start);
    }

    expect(closeCurlRe);
    return ConstTag(
      start: start,
      end: position,
      assign: assign,
    );
  }

  MustacheTag _parseExpression(int start) {
    var value = expression();
    expect(closeCurlRe);

    return MustacheTag(
      start: start,
      end: position,
      value: value,
    );
  }
}
