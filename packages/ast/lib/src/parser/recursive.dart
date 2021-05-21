import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import '../exception_handler/exception_handler.dart';
import '../nodes.dart';
import '../token/tokens.dart';
import 'reader.dart';

class RecursiveParser {
  RecursiveParser(this.source, Iterable<Token> tokens, this.voidElements, this.svgElements, this.exceptionHandler)
      : reader = TokenReversibleReader<TokenType>(tokens.iterator);

  final TokenReversibleReader<Object> reader;

  final SourceFile source;

  final List<String> voidElements;

  final List<String> svgElements;

  final ExceptionHandler exceptionHandler;

  List<Node> parse() {
    // Start with an empty list.
    final nodes = <Node>[];

    Token? token;

    // Iterate through until and wait until EOF.
    // Collects comments, elements, and text.
    // Any other AST structure should be handled by the parseElement case.
    while ((token = reader.next() as Token?) != null) {
      nodes.add(parseStandalone(token!)!);
    }

    return nodes;
  }

  CloseElementNode parseCloseElement(Token beginToken) {
    final nameToken = reader.next()!;

    if (voidElements.contains(nameToken.lexeme)) {
      exceptionHandler.handle(ParserException(ParserErrorCode.voidElementInCloseTag, nameToken.offset, nameToken.length));
    }

    while (reader.peekType() == TokenType.whitespace) {
      reader.next();
    }

    return CloseElementNode.parsed(source, beginToken, nameToken as Token, reader.next() as Token);
  }

  CommentNode parseComment(Token beginToken) {
    Token valueToken;

    if (reader.peekType() == TokenType.commentEnd) {
      valueToken = Token.commentValue(reader.peek()!.offset, '');
    } else {
      valueToken = reader.next() as Token;
    }

    return CommentNode.parsed(source, beginToken, valueToken, reader.next() as Token);
  }

  ContainerNode parseContainer(Token beginToken, Token nameToken, List<String> tagStack) {
    final annotations = <AnnotationNode>[];
    final childNodes = <Node>[];
    final stars = <StarNode>[];

    while (reader.peekType() == TokenType.beforeElementDecorator) {
      final nextToken = reader.next();
      final decorator = parseDecorator(nextToken as Token);

      if (decorator is AnnotationNode) {
        annotations.add(decorator);
      } else if (decorator is StarNode) {
        addStarNode(decorator, stars);
      } else {
        exceptionHandler.handle(
            ParserException(ParserErrorCode.invalidDecoratorInContainer, decorator.beginToken!.offset, decorator.endToken!.end - decorator.beginToken!.offset));
      }
    }

    final endToken = parseOpenElementEnd();
    final closeComplement = parseCloseComplement(beginToken, nameToken, endToken, childNodes, tagStack);
    return ContainerNode.parsed(source, beginToken, endToken, closeComplement, annotations: annotations, childNodes: childNodes, stars: stars);
  }

  TemplateNode parseDecorator(Token beginToken) {
    Token? prefixToken;
    Token? decoratorToken;
    Token? suffixToken;

    final peekType = reader.peekType();

    if (peekType == TokenType.bananaPrefix || peekType == TokenType.eventPrefix || peekType == TokenType.propertyPrefix) {
      prefixToken = reader.next() as Token;
      decoratorToken = reader.next() as Token;
      suffixToken = reader.next() as Token;
    } else if (peekType == TokenType.referencePrefix || peekType == TokenType.templatePrefix || peekType == TokenType.annotationPrefix) {
      prefixToken = reader.next() as Token;
      decoratorToken = reader.next() as Token;
    } else {
      decoratorToken = reader.next() as Token;
    }

    AttributeValueToken? valueToken;
    Token? equalSignToken;

    if (reader.peekTypeIgnoringType(TokenType.whitespace) == TokenType.beforeElementDecoratorValue) {
      consumeWhitespaces();
      equalSignToken = reader.next() as Token;
      consumeWhitespaces();
      valueToken = reader.next() as AttributeValueToken;
    }

    if (prefixToken != null) {
      var prefixType = prefixToken.type;

      if (prefixType == TokenType.bananaPrefix) {
        return BananaNode.parsed(source, prefixToken, decoratorToken, suffixToken as Token, valueToken, equalSignToken);
      } else if (prefixType == TokenType.eventPrefix) {
        // Disabling: event names can be as long as keyup.ctrl.shift.alt.mod.+
        // Should this be limited to 6 then? Or should it be left open?
        // if (decoratorToken.lexeme.split('.').length > 2) {
        //   exceptionHandler.handle(ParserException(
        //     ParserErrorCode.propertyNameTooManyFixes,
        //     decoratorToken.offset,
        //     decoratorToken.length,
        //   ));
        // }

        return EventNode.parsed(source, prefixToken, decoratorToken, suffixToken as Token, valueToken, equalSignToken);
      } else if (prefixType == TokenType.propertyPrefix) {
        if (decoratorToken.lexeme.split('.').length > 3) {
          exceptionHandler.handle(ParserException(ParserErrorCode.propertyNameTooManyFixes, decoratorToken.offset, decoratorToken.length));
        }

        return PropertyNode.parsed(source, prefixToken, decoratorToken, suffixToken as Token, valueToken, equalSignToken);
      } else if (prefixType == TokenType.referencePrefix) {
        return ReferenceNode.parsed(source, prefixToken, decoratorToken, valueToken, equalSignToken);
      } else if (prefixType == TokenType.templatePrefix) {
        return StarNode.parsed(source, prefixToken, decoratorToken, valueToken, equalSignToken);
      } else if (prefixType == TokenType.annotationPrefix) {
        return AnnotationNode.parsed(source, prefixToken, decoratorToken, valueToken, equalSignToken);
      }
    }

    // At this point, it is a TextAttribute, but handle cases
    // with 'on-' and 'bind-' prefix.
    if (decoratorToken.lexeme.startsWith('on-')) {
      final onToken = Token.onPrefix(decoratorToken.offset);
      final onLength = 'on-'.length;
      decoratorToken = Token.elementDecorator(decoratorToken.offset + onLength, decoratorToken.lexeme.substring(onLength));

      if (decoratorToken.lexeme == '') {
        exceptionHandler.handle(ParserException(ParserErrorCode.elementDecoratorAfterPrefix, onToken.offset, onToken.length));
      }

      return EventNode.parsed(source, onToken, decoratorToken, null, valueToken, equalSignToken);
    }

    if (decoratorToken.lexeme.startsWith('bind-')) {
      final bindToken = Token.bindPrefix(decoratorToken.offset);
      final bindLength = 'bind-'.length;
      decoratorToken = Token.elementDecorator(decoratorToken.offset + bindLength, decoratorToken.lexeme.substring(bindLength));

      if (decoratorToken.lexeme == '') {
        exceptionHandler.handle(ParserException(ParserErrorCode.elementDecoratorAfterPrefix, bindToken.offset, bindToken.length));
      }

      return PropertyNode.parsed(source, bindToken, decoratorToken, null, valueToken, equalSignToken);
    }
    if (decoratorToken.lexeme.startsWith('let-')) {
      final letToken = Token.letPrefix(decoratorToken.offset);
      final letLength = 'let-'.length;
      decoratorToken = Token.elementDecorator(decoratorToken.offset + letLength, decoratorToken.lexeme.substring(letLength));
      return LetBindingNode.parsed(source, letToken, decoratorToken, valueToken, equalSignToken);
    }

    List<InterpolationNode>? parsedMustaches;

    if (valueToken != null) {
      parsedMustaches = parseMustacheInPlainAttributeValue(valueToken.innerValue!);
    }

    return AttributeNode.parsed(source, decoratorToken, valueToken, equalSignToken, parsedMustaches);
  }

  Node parseElement(Token beginToken, List<String> tagStack) {
    // Parse the element identifier.
    final nameToken = reader.next()!;

    var isTemplateElement = false;

    if (nameToken.lexeme == 'piko:container') {
      return parseContainer(beginToken, nameToken as Token, tagStack);
    } else if (nameToken.lexeme == 'piko:content') {
      return parseEmbeddedContent(beginToken, nameToken as Token);
    } else if (nameToken.lexeme.toLowerCase() == 'template') {
      isTemplateElement = true;
    }

    final isVoidElement = voidElements.contains(nameToken.lexeme);
    // TODO(alorenzen): Add better namespace handling.
    final isSvgElement = svgElements.contains(nameToken.lexeme.replaceAll('svg:', ''));

    // Start collecting decorators.
    final attributes = <AttributeNode>[];
    final childNodes = <Node>[];
    final events = <EventNode>[];
    final properties = <PropertyNode>[];
    final references = <ReferenceNode>[];
    final bananas = <BananaNode>[];
    final stars = <StarNode>[];
    final annotations = <AnnotationNode>[];
    final letBindings = <LetBindingNode>[];

    Token nextToken;

    // Start looping and get all of the decorators within the element.
    do {
      nextToken = reader.next() as Token;

      if (nextToken.type == TokenType.beforeElementDecorator) {
        final decoratorNode = parseDecorator(nextToken);

        if (decoratorNode is AttributeNode) {
          attributes.add(decoratorNode);
        } else if (decoratorNode is LetBindingNode) {
          if (!isTemplateElement) {
            // 'let-' binding can only exist in <template>.
            exceptionHandler.handle(ParserException(ParserErrorCode.invalidLetBindingInNontemplate, decoratorNode.beginToken!.offset,
                decoratorNode.endToken!.end - decoratorNode.beginToken!.offset));
          } else if (decoratorNode.name.isEmpty) {
            final letToken = (decoratorNode as ParsedLetBindingNode).prefixToken;
            exceptionHandler.handle(ParserException(ParserErrorCode.elementDecoratorAfterPrefix, letToken.offset, letToken.length));
          } else {
            letBindings.add(decoratorNode);
          }
        } else if (decoratorNode is StarNode) {
          if (isTemplateElement) {
            exceptionHandler.handle(ParserException(
                ParserErrorCode.invalidDecoratorInTemplate, decoratorNode.beginToken!.offset, decoratorNode.endToken!.end - decoratorNode.beginToken!.offset));
          } else {
            if (stars.isNotEmpty) {
              exceptionHandler.handle(ParserException(
                  ParserErrorCode.duplicateStarDirective, decoratorNode.beginToken!.offset, decoratorNode.endToken!.end - decoratorNode.beginToken!.offset));
            } else {
              stars.add(decoratorNode);
            }
          }
        } else if (decoratorNode is AnnotationNode) {
          annotations.add(decoratorNode);
        } else if (decoratorNode is EventNode) {
          events.add(decoratorNode);
        } else if (decoratorNode is PropertyNode) {
          properties.add(decoratorNode);
        } else if (decoratorNode is BananaNode) {
          if (isTemplateElement) {
            exceptionHandler.handle(ParserException(
                ParserErrorCode.invalidDecoratorInTemplate, decoratorNode.beginToken!.offset, decoratorNode.endToken!.end - decoratorNode.beginToken!.offset));
          } else {
            bananas.add(decoratorNode);
          }
        } else if (decoratorNode is ReferenceNode) {
          references.add(decoratorNode);
        } else {
          throw StateError('Invalid decorator AST: $decoratorNode');
        }
      }
    } while (nextToken.type != TokenType.openElementEnd && nextToken.type != TokenType.openElementEndVoid);

    if (!isVoidElement && !isSvgElement && nextToken.type == TokenType.openElementEndVoid) {
      exceptionHandler.handle(ParserException(ParserErrorCode.nonVoidElementUsingVoidEnd, nextToken.offset, nextToken.length));
      nextToken = Token.generateErrorSynthetic(nextToken.offset, TokenType.openElementEnd);
    }

    final endToken = nextToken;

    CloseElementNode? closeElementNode;

    // If not a void element, look for closing tag OR child nodes.
    if (!isVoidElement && nextToken.type != TokenType.openElementEndVoid) {
      closeElementNode = parseCloseComplement(beginToken, nameToken as Token, endToken, childNodes, tagStack);
    }

    if (isTemplateElement) {
      return EmbeddedTemplateNode.parsed(beginToken, endToken,
          closeComplement: closeElementNode,
          annotations: annotations,
          attributes: attributes,
          childNodes: childNodes,
          events: events,
          properties: properties,
          references: references,
          letBindings: letBindings);
    } else {
      return ElementNode.parsed(source, beginToken, nameToken as Token, endToken,
          annotations: annotations,
          attributes: attributes,
          childNodes: childNodes,
          events: events,
          properties: properties,
          references: references,
          bananas: bananas,
          stars: stars,
          closeComplement: closeElementNode);
    }
  }

  EmbeddedContentNode parseEmbeddedContent(Token beginToken, Token elementIdentifierToken) {
    var selectAttributeFound = false;
    var ngProjectAsAttributeFound = false;
    var referenceAttributeFound = false;

    Token endToken;
    CloseElementNode closeElementNode;
    AttributeNode? selectAttribute, ngProjectAsAttribute;
    ReferenceNode? reference;

    // Ensure that piko:content has only 'select', 'ngProjectAs' and a reference,
    // if any. Also catch for multiple ones; if multiple, accept the first one
    // seen.
    while (reader.peekType() == TokenType.beforeElementDecorator) {
      final nextToken = reader.next();
      final decorator = parseDecorator(nextToken as Token);
      final startOffset = decorator.beginToken!.offset;
      final endOffset = decorator.endToken!.end;

      if (decorator is AttributeNode && decorator.name == 'select') {
        if (selectAttributeFound) {
          exceptionHandler.handle(ParserException(ParserErrorCode.duplicateSelectDecorator, startOffset, endOffset - startOffset));
        } else {
          selectAttributeFound = true;
          selectAttribute = decorator;
        }
      } else if (decorator is AttributeNode && decorator.name == 'projectAs') {
        if (ngProjectAsAttributeFound) {
          exceptionHandler.handle(ParserException(ParserErrorCode.duplicateProjectAsDecorator, startOffset, endOffset - startOffset));
        } else {
          ngProjectAsAttributeFound = true;
          ngProjectAsAttribute = decorator;
        }
      } else if (decorator is ReferenceNode) {
        if (referenceAttributeFound) {
          exceptionHandler.handle(ParserException(ParserErrorCode.duplicateReferenceDecorator, startOffset, endOffset - startOffset));
        } else {
          referenceAttributeFound = true;
          reference = decorator;

          if (reference.identifier != null) {
            exceptionHandler.handle(ParserException(ParserErrorCode.referenceIdentifierFound, startOffset, endOffset - startOffset));
          }
        }
      } else {
        exceptionHandler.handle(
            ParserException(ParserErrorCode.invalidDecoratorInContent, decorator.beginToken!.offset, decorator.endToken!.end - decorator.beginToken!.offset));
      }
    }

    endToken = parseOpenElementEnd();

    // Skip whitespace after <piko:content>.
    if (reader.peekType() == TokenType.text) {
      final textToken = reader.next();
      final text = parseText(textToken as Token);

      if (text.value.trim().isNotEmpty) {
        reader.putBack(textToken);
      }
    }

    // Ensure closing </piko:content> exists.
    if (reader.peekType() != TokenType.closeElementStart) {
      exceptionHandler.handle(ParserException(ParserErrorCode.contentMustCloseImmediately, beginToken.offset, endToken.end - beginToken.offset));
      closeElementNode = CloseElementNode('piko:content');
    } else {
      final closeElementStart = reader.next();
      final closeElementName = reader.peek()!.lexeme;

      if (closeElementName != 'piko:content') {
        exceptionHandler.handle(ParserException(ParserErrorCode.contentMustCloseImmediately, beginToken.offset, endToken.end - beginToken.offset));
        reader.putBack(closeElementStart!);
        closeElementNode = CloseElementNode('piko:content');
      } else {
        closeElementNode = parseCloseElement(closeElementStart as Token);
      }
    }

    return EmbeddedContentNode.parsed(source, beginToken, elementIdentifierToken, endToken, closeElementNode, selectAttribute, ngProjectAsAttribute, reference);
  }

  @protected
  List<InterpolationNode> parseMustacheInPlainAttributeValue(Token innerValue) {
    var text = innerValue.lexeme;
    var absoluteTextOffset = innerValue.offset;
    var tokens = RegExp(r'({{)|(}})');
    var mustaches = <InterpolationNode>[];

    int? seenOpenMustache;

    final scanner = StringScanner(text);

    while (!scanner.isDone) {
      final position = scanner.position;
      final match = tokens.firstMatch(scanner.rest);

      if (match != null) {
        final matchPosition = position + match.start;

        if (match.group(1) != null) {
          // '{{' found.
          if (seenOpenMustache == null) {
            seenOpenMustache = matchPosition;
          } else {
            // Second '{{' found before '}}' closes it.
            final firstMustacheBegin = absoluteTextOffset + seenOpenMustache;
            exceptionHandler.handle(ParserException(ParserErrorCode.unterminatedMustache, firstMustacheBegin, '{{'.length));

            mustaches.add(InterpolationNode.parsed(
                source,
                Token.interpolationStart(firstMustacheBegin),
                Token.interpolationValue(firstMustacheBegin + '{{'.length, text.substring(seenOpenMustache + '{{'.length, matchPosition)),
                Token.generateErrorSynthetic(absoluteTextOffset + matchPosition, TokenType.interpolationEnd)));
            seenOpenMustache = matchPosition;
          }
        }

        if (match.group(2) != null) {
          if (seenOpenMustache != null) {
            final mustacheBegin = absoluteTextOffset + seenOpenMustache;
            final mustacheEnd = absoluteTextOffset + matchPosition;

            mustaches.add(InterpolationNode.parsed(
              source,
              Token.interpolationStart(mustacheBegin),
              Token.interpolationValue(mustacheBegin + '{{'.length, text.substring(seenOpenMustache + '{{'.length, matchPosition)),
              Token.interpolationEnd(mustacheEnd),
            ));

            seenOpenMustache = null;
          } else {
            // Found '}}' before any '{{'
            final mustacheBegin = absoluteTextOffset + position;
            final mustacheEnd = absoluteTextOffset + matchPosition;
            exceptionHandler.handle(ParserException(ParserErrorCode.unopenedMustache, mustacheEnd, '}}'.length));

            mustaches.add(InterpolationNode.parsed(
              source,
              Token.generateErrorSynthetic(mustacheBegin, TokenType.interpolationStart),
              Token.interpolationValue(mustacheBegin, text.substring(position, matchPosition)),
              Token.interpolationEnd(mustacheEnd),
            ));
          }
        }
        scanner.position += match.end;
      } else {
        scanner.position += scanner.rest.length;
      }
    }

    // Dangling '{{' and hit end of value-text
    if (seenOpenMustache != null) {
      var mustacheBegin = absoluteTextOffset + seenOpenMustache;
      exceptionHandler.handle(ParserException(ParserErrorCode.unterminatedMustache, mustacheBegin, '{{'.length));
      mustaches.add(InterpolationNode.parsed(
        source,
        Token.interpolationStart(mustacheBegin),
        Token.interpolationValue(mustacheBegin + '{{'.length, text.substring(seenOpenMustache + '{{'.length, text.length)),
        Token.generateErrorSynthetic(absoluteTextOffset + text.length, TokenType.interpolationEnd),
      ));
    }

    return mustaches;
  }

  InterpolationNode parseInterpolation(Token beginToken) {
    final valueToken = reader.next();
    final endToken = reader.next();
    return InterpolationNode.parsed(source, beginToken, valueToken as Token, endToken as Token);
  }

  Node? parseStandalone(Token token, [List<String>? tagStack]) {
    tagStack ??= <String>[];

    switch (token.type) {
      case TokenType.commentStart:
        return parseComment(token);
      case TokenType.openElementStart:
        return parseElement(token, tagStack);
      case TokenType.interpolationStart:
        return parseInterpolation(token);
      case TokenType.text:
        return parseText(token);

      // Dangling close tag. If error recovery is enabled, returns
      // a synthetic open with the dangling close. If not enabled,
      // simply throws error.
      case TokenType.closeElementStart:
        final danglingCloseIdentifier = reader.peek()!.lexeme;
        final closeComplement = parseCloseElement(token);
        exceptionHandler.handle(ParserException(
            ParserErrorCode.danglingCloseElement, closeComplement.beginToken!.offset, closeComplement.endToken!.end - closeComplement.beginToken!.offset));

        if (danglingCloseIdentifier == 'piko:content') {
          final synthOpenElement = EmbeddedContent();
          synthOpenElement.closeComplement = closeComplement;
          return synthOpenElement;
        }

        return ElementNode(danglingCloseIdentifier, closeComplement);

      default:
        // Simply throw error here; should never hit.
        if (exceptionHandler is RecoveringExceptionHandler) {
          // Throw an error here - this should never hit in recovery mode
          // unless something went really wrong. If so, FIX IT ASAP!
          throw Exception('Non-standalone starting token found!');
        }

        exceptionHandler.handle(ParserException(ParserErrorCode.expectedStandalone, token.offset, token.length));
        return null;
    }
  }

  @protected
  void addStarNode(Star node, List<Star> starNodes) {
    if (starNodes.isEmpty) {
      starNodes.add(node);
    } else {
      exceptionHandler.handle(ParserException(ParserErrorCode.duplicateStarDirective, node.beginToken!.offset, node.beginToken!.end - node.beginToken!.offset));
    }
  }

  @protected
  CloseElement parseCloseComplement(Token beginToken, Token nameToken, Token endToken, List<Node> childNodes, List<String> tagStack) {
    var closingTagFound = false;

    CloseElement? closeElementNode;

    tagStack.add(nameToken.lexeme);

    while (!closingTagFound) {
      final nextToken = reader.next();

      if (nextToken == null) {
        exceptionHandler.handle(ParserException(ParserErrorCode.cannotFindMatchingClose, beginToken.offset, endToken.end - beginToken.offset));
        closeElementNode = CloseElement(nameToken.lexeme);
        closingTagFound = true;
      } else if (nextToken.type == TokenType.closeElementStart) {
        final closeNameToken = reader.peek()!;
        final closeIdentifier = closeNameToken.lexeme;

        if (closeIdentifier != nameToken.lexeme) {
          // Found a closing tag, but not matching current [ElementNode].
          // Generate initial error code; could be dangling or unmatching.
          if (tagStack.contains(closeIdentifier)) {
            // If the closing tag is in the seen [ElementNode] stack,
            // leave it alone. Instead create a synthetic close.
            reader.putBack(nextToken);
            closeElementNode = CloseElement(nameToken.lexeme);
            closingTagFound = true;
            exceptionHandler.handle(ParserException(ParserErrorCode.cannotFindMatchingClose, beginToken.offset, endToken.end - beginToken.offset));
          } else {
            // If the closing tag is not in the stack, create a synthetic
            // [ElementNode] to pair the dangling close and add as child.
            var closeComplement = parseCloseElement(nextToken as Token);
            exceptionHandler.handle(ParserException(
                ParserErrorCode.danglingCloseElement, closeComplement.beginToken!.offset, closeComplement.endToken!.end - closeComplement.beginToken!.offset));
            if (closeIdentifier == 'piko:container') {
              final synthContainer = ContainerNode();
              synthContainer.closeComplement = closeComplement;
              childNodes.add(synthContainer);
            } else if (closeIdentifier == 'piko:content') {
              final synthContent = EmbeddedContentNode();
              synthContent.closeComplement = closeComplement;
              childNodes.add(synthContent);
            } else if (closeIdentifier == 'template') {
              final synthTemplate = EmbeddedTemplateNode();
              childNodes.add(synthTemplate);
            } else {
              final synthOpenElement = ElementNode(closeNameToken.lexeme, closeComplement);
              childNodes.add(synthOpenElement);
            }
          }
        } else {
          closeElementNode = parseCloseElement(nextToken as Token);
          closingTagFound = true;
        }
      } else {
        childNodes.add(parseStandalone(nextToken as Token, tagStack)!);
      }
    }

    tagStack.removeLast();
    return closeElementNode;
  }

  @protected
  Token parseOpenElementEnd() {
    consumeWhitespaces();

    final endToken = reader.next()!;

    if (endToken.type == TokenType.openElementEndVoid) {
      exceptionHandler.handle(ParserException(ParserErrorCode.nonVoidElementUsingVoidEnd, endToken.offset, endToken.length));
      return Token.generateErrorSynthetic(endToken.offset, TokenType.openElementEnd);
    }

    return endToken as Token;
  }

  @protected
  void consumeWhitespaces() {
    while (reader.peekType() != null && reader.peekType() == TokenType.whitespace) {
      reader.next();
    }
  }

  Text parseText(Token token) {
    return Text(token);
  }
}
