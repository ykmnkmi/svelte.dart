import 'package:source_span/source_span.dart' show SourceFile;
import 'package:string_scanner/string_scanner.dart' show StringScanner;

import '../parser_exception.dart';
import '../ast.dart';
import '../token/tokens.dart';
import 'reader.dart';

class RecursiveASTParser {
  RecursiveASTParser(this.source, Iterable<Token> tokens, this.voidElements, this.svgElements)
      : reader = TokenReversibleReader<TokenType>(tokens.iterator);

  final TokenReversibleReader<Object> reader;

  final SourceFile source;

  final List<String> voidElements;

  final List<String> svgElements;

  List<Standalone> parse() {
    // Start with an empty list.
    var nodes = <Standalone>[];
    Token? token;

    // Iterate through until and wait until EOF.
    //
    // Collects comments, elements, and text.
    //
    // Any other AST structure should be handled by the parseElement case.
    while ((token = reader.next() as Token?) != null) {
      nodes.add(parseStandalone(token!)!);
    }

    // Return the collected nodes.
    return nodes;
  }

  CloseElement parseCloseElement(Token beginToken) {
    var nameToken = reader.next()!;

    if (voidElements.contains(nameToken.lexeme)) {
      throw ParserException(ParserErrorCode.voidElementInCloseTag, nameToken.offset, nameToken.length);
    }

    while (reader.peekType() == TokenType.whitespace) {
      reader.next();
    }

    var closeElementEnd = reader.next();
    return CloseElement.parsed(source, beginToken, nameToken as Token, closeElementEnd as Token);
  }

  Comment parseComment(Token beginToken) {
    Token valueToken;

    if (reader.peekType() == TokenType.commentEnd) {
      valueToken = Token.commentValue(reader.peek()!.offset, '');
    } else {
      valueToken = reader.next() as Token;
    }

    var endToken = reader.next();
    return Comment.parsed(source, beginToken, valueToken, endToken as Token);
  }

  Container parseContainer(Token beginToken, Token nameToken, List<String> tagStack) {
    var annotations = <Annotation>[];
    var childNodes = <Standalone>[];
    var stars = <Star>[];

    while (reader.peekType() == TokenType.beforeElementDecorator) {
      var nextToken = reader.next();
      var decorator = parseDecorator(nextToken as Token);

      if (decorator is Annotation) {
        annotations.add(decorator);
      } else if (decorator is Star) {
        addStarAst(decorator, stars);
      } else {
        var offset = decorator.beginToken!.offset;
        var length = decorator.endToken!.end - decorator.beginToken!.offset;
        throw ParserException(ParserErrorCode.invalidDecoratorInContainer, offset, length);
      }
    }

    var endToken = parseOpenElementEnd();
    var closeComplement = _parseCloseElement(beginToken, nameToken, endToken, childNodes, tagStack);
    return Container.parsed(source, beginToken, endToken, closeComplement,
        annotations: annotations, childNodes: childNodes, stars: stars);
  }

  Node parseDecorator(Token beginToken) {
    // The first token is the decorator/name.
    Token? prefixToken;
    Token? decoratorToken;
    Token? suffixToken;

    var peekType = reader.peekType();

    if (peekType == TokenType.bananaPrefix ||
        peekType == TokenType.eventPrefix ||
        peekType == TokenType.propertyPrefix) {
      prefixToken = reader.next() as Token;
      decoratorToken = reader.next() as Token;
      suffixToken = reader.next() as Token;
    } else if (peekType == TokenType.referencePrefix ||
        peekType == TokenType.templatePrefix ||
        peekType == TokenType.annotationPrefix) {
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
        return Banana.parsed(source, prefixToken, decoratorToken, suffixToken as Token, valueToken, equalSignToken);
      } else if (prefixType == TokenType.eventPrefix) {
        // Disabling: event names can be as long as keyup.ctrl.shift.alt.mod.+
        // Should this be limited to 6 then? Or should it be left open?
        // if (decoratorToken.lexeme.split('.').length > 2) {
        //   exceptionHandler.handle(new AngularParserException(
        //     NgParserWarningCode.EVENT_NAME_TOO_MANY_FIXES,
        //     decoratorToken.offset,
        //     decoratorToken.length,
        //   ));
        // }
        return Event.parsed(source, prefixToken, decoratorToken, suffixToken as Token, valueToken, equalSignToken);
      } else if (prefixType == TokenType.propertyPrefix) {
        if (decoratorToken.lexeme.split('.').length > 3) {
          var offset = decoratorToken.offset;
          var length = decoratorToken.length;
          throw ParserException(ParserErrorCode.propertyNameTooManyFixes, offset, length);
        }

        return Property.parsed(source, prefixToken, decoratorToken, suffixToken as Token, valueToken, equalSignToken);
      } else if (prefixType == TokenType.referencePrefix) {
        return Reference.parsed(source, prefixToken, decoratorToken, valueToken, equalSignToken);
      } else if (prefixType == TokenType.templatePrefix) {
        return Star.parsed(source, prefixToken, decoratorToken, valueToken, equalSignToken);
      } else if (prefixType == TokenType.annotationPrefix) {
        return Annotation.parsed(source, prefixToken, decoratorToken, valueToken, equalSignToken);
      }
    }

    // At this point, it is a TextAttribute, but handle cases
    // with 'on-' and 'bind-' prefix.
    if (decoratorToken.lexeme.startsWith('on-')) {
      var onToken = Token.onPrefix(decoratorToken.offset);
      decoratorToken = Token.elementDecorator(decoratorToken.offset + 3, decoratorToken.lexeme.substring(3));

      if (decoratorToken.lexeme == '') {
        var offset = onToken.offset;
        var length = onToken.length;
        throw ParserException(ParserErrorCode.elementDecoratorAfterPrefix, offset, length);
      }

      return Event.parsed(source, onToken, decoratorToken, null, valueToken, equalSignToken);
    }
    if (decoratorToken.lexeme.startsWith('bind-')) {
      var bindToken = Token.bindPrefix(decoratorToken.offset);
      decoratorToken = Token.elementDecorator(decoratorToken.offset + 5, decoratorToken.lexeme.substring(5));

      if (decoratorToken.lexeme == '') {
        var offset = bindToken.offset;
        var length = bindToken.length;
        throw ParserException(ParserErrorCode.elementDecoratorAfterPrefix, offset, length);
      }

      return Property.parsed(source, bindToken, decoratorToken, null, valueToken, equalSignToken);
    }

    if (decoratorToken.lexeme.startsWith('let-')) {
      var letToken = Token.letPrefix(decoratorToken.offset);
      decoratorToken = Token.elementDecorator(decoratorToken.offset + 4, decoratorToken.lexeme.substring(4));
      return LetBinding.parsed(source, letToken, decoratorToken, valueToken, equalSignToken);
    }

    List<Standalone> parsedMustaches;

    if (valueToken != null) {
      parsedMustaches = parseMustacheInPlainAttributeValue(valueToken.innerValue!);
    } else {
      parsedMustaches = const <Standalone>[];
    }

    return Attribute.parsed(source, decoratorToken, valueToken, equalSignToken, parsedMustaches);
  }

  Standalone parseElement(Token beginToken, List<String> tagStack) {
    var isTemplateElement = false;

    // Parse the element identifier.
    var nameToken = reader.next()!;
    if (nameToken.lexeme == 'ng-container') {
      return parseContainer(beginToken, nameToken as Token, tagStack);
    } else if (nameToken.lexeme == 'ng-content') {
      return parseEmbeddedContent(beginToken, nameToken as Token);
    } else if (nameToken.lexeme.toLowerCase() == 'template') {
      isTemplateElement = true;
    }

    var isVoidElement = voidElements.contains(nameToken.lexeme);
    // TODO(alorenzen): Add better namespace handling.
    var isSvgElement = svgElements.contains(nameToken.lexeme.replaceAll('svg:', ''));

    // Start collecting decorators.
    var attributes = <Attribute>[];
    var childNodes = <Standalone>[];
    var events = <Event>[];
    var properties = <Property>[];
    var references = <Reference>[];
    var bananas = <Banana>[];
    var stars = <Star>[];
    var annotations = <Annotation>[];
    var letBindings = <LetBinding>[];
    Token nextToken;

    // Start looping and get all of the decorators within the element.
    do {
      nextToken = reader.next() as Token;

      if (nextToken.type == TokenType.beforeElementDecorator) {
        var decoratorAst = parseDecorator(nextToken);

        if (decoratorAst is Attribute) {
          attributes.add(decoratorAst);
        } else if (decoratorAst is LetBinding) {
          if (!isTemplateElement) {
            // 'let-' binding can only exist in <template>.
            var offset = decoratorAst.beginToken!.offset;
            var length = decoratorAst.endToken!.end - decoratorAst.beginToken!.offset;
            throw ParserException(ParserErrorCode.invalidLetBindingInNonTemplate, offset, length);
          } else if (decoratorAst.name.isEmpty) {
            var letToken = (decoratorAst as ParsedLetBinding).prefixToken;
            var offset = letToken.offset;
            var length = letToken.length;
            throw ParserException(ParserErrorCode.elementDecoratorAfterPrefix, offset, length);
          } else {
            letBindings.add(decoratorAst);
          }
        } else if (decoratorAst is Star) {
          if (isTemplateElement) {
            var offset = decoratorAst.beginToken!.offset;
            var length = decoratorAst.endToken!.end - decoratorAst.beginToken!.offset;
            throw ParserException(ParserErrorCode.invalidDecoratorInTemplate, offset, length);
          } else {
            if (stars.isNotEmpty) {
              var offset = decoratorAst.beginToken!.offset;
              var length = decoratorAst.endToken!.end - decoratorAst.beginToken!.offset;
              throw ParserException(ParserErrorCode.duplicateStarDirective, offset, length);
            } else {
              stars.add(decoratorAst);
            }
          }
        } else if (decoratorAst is Annotation) {
          annotations.add(decoratorAst);
        } else if (decoratorAst is Event) {
          events.add(decoratorAst);
        } else if (decoratorAst is Property) {
          properties.add(decoratorAst);
        } else if (decoratorAst is Banana) {
          if (isTemplateElement) {
            var offset = decoratorAst.beginToken!.offset;
            var length = decoratorAst.endToken!.end - decoratorAst.beginToken!.offset;
            throw ParserException(ParserErrorCode.invalidDecoratorInTemplate, offset, length);
          } else {
            bananas.add(decoratorAst);
          }
        } else if (decoratorAst is Reference) {
          references.add(decoratorAst);
        } else {
          throw StateError('Invalid decorator AST: $decoratorAst');
        }
      }
    } while (nextToken.type != TokenType.openElementEnd && nextToken.type != TokenType.openElementEndVoid);

    if (!isVoidElement && !isSvgElement && nextToken.type == TokenType.openElementEndVoid) {
      var offset = nextToken.offset;
      var length = nextToken.length;
      throw ParserException(ParserErrorCode.nonVoidElementUsingVoidEnd, offset, length);
    }

    var endToken = nextToken;
    CloseElement? closeElementAst;

    // If not a void element, look for closing tag OR child nodes.
    if (!isVoidElement && nextToken.type != TokenType.openElementEndVoid) {
      closeElementAst = _parseCloseElement(beginToken, nameToken as Token, endToken, childNodes, tagStack);
    }

    if (isTemplateElement) {
      return EmbeddedNode.parsed(source, beginToken, endToken,
          closeComplement: closeElementAst,
          annotations: annotations,
          attributes: attributes,
          childNodes: childNodes,
          events: events,
          properties: properties,
          references: references,
          letBindings: letBindings);
    } else {
      return Element.parsed(source, beginToken, nameToken as Token, endToken,
          annotations: annotations,
          attributes: attributes,
          childNodes: childNodes,
          events: events,
          properties: properties,
          references: references,
          bananas: bananas,
          stars: stars,
          closeComplement: closeElementAst);
    }
  }

  EmbeddedContent parseEmbeddedContent(Token beginToken, Token elementIdentifierToken) {
    Token endToken;
    Attribute? selectAttribute, ngProjectAsAttribute;
    Reference? reference;
    var selectAttributeFound = false;
    var ngProjectAsAttributeFound = false;
    var referenceAttributeFound = false;
    CloseElement closeElementAst;

    // Ensure that ng-content has only 'select', 'ngProjectAs' and a reference,
    // if any. Also catch for multiple ones; if multiple, accept the first one
    // seen.
    while (reader.peekType() == TokenType.beforeElementDecorator) {
      var nextToken = reader.next();
      var decorator = parseDecorator(nextToken as Token);
      var startOffset = decorator.beginToken!.offset;
      var endOffset = decorator.endToken!.end;

      if (decorator is Attribute && decorator.name == 'select') {
        if (selectAttributeFound) {
          var length = endOffset - startOffset;
          throw ParserException(ParserErrorCode.duplicateSelectorDecorator, startOffset, length);
        } else {
          selectAttributeFound = true;
          selectAttribute = decorator;
        }
      } else if (decorator is Attribute && decorator.name == 'ngProjectAs') {
        if (ngProjectAsAttributeFound) {
          var length = endOffset - startOffset;
          throw ParserException(ParserErrorCode.duplicateProjectAsDecorator, startOffset, length);
        } else {
          ngProjectAsAttributeFound = true;
          ngProjectAsAttribute = decorator;
        }
      } else if (decorator is Reference) {
        if (referenceAttributeFound) {
          var length = endOffset - startOffset;
          throw ParserException(ParserErrorCode.duplicateReferenceDecorator, startOffset, length);
        } else {
          referenceAttributeFound = true;
          reference = decorator;

          if (reference.identifier != null) {
            var length = endOffset - startOffset;
            throw ParserException(ParserErrorCode.referenceIdetifierFound, startOffset, length);
          }
        }
      } else {
        var offset = decorator.beginToken!.offset;
        var length = decorator.endToken!.end - decorator.beginToken!.offset;
        throw ParserException(ParserErrorCode.invalidDecoratorInContent, offset, length);
      }
    }

    endToken = parseOpenElementEnd();

    // Skip whitespace after <ng-content>.
    if (reader.peekType() == TokenType.text) {
      var textToken = reader.next();
      var text = parseText(textToken as Token);

      if (text.value.trim().isNotEmpty) {
        reader.putBack(textToken);
      }
    }

    // Ensure closing </ng-content> exists.
    if (reader.peekType() != TokenType.closeElementStart) {
      var offset = beginToken.offset;
      var length = endToken.end - beginToken.offset;
      throw ParserException(ParserErrorCode.contentMustCloseImmediately, offset, length);
    } else {
      var closeElementStart = reader.next();
      var closeElementName = reader.peek()!.lexeme;

      if (closeElementName != 'ng-content') {
        var offset = beginToken.offset;
        var length = endToken.end - beginToken.offset;
        throw ParserException(ParserErrorCode.contentMustCloseImmediately, offset, length);
      } else {
        closeElementAst = parseCloseElement(closeElementStart as Token);
      }
    }

    return EmbeddedContent.parsed(source, beginToken, elementIdentifierToken, endToken, closeElementAst,
        selectAttribute, ngProjectAsAttribute, reference);
  }

  List<Standalone> parseMustacheInPlainAttributeValue(Token innerValue) {
    var text = innerValue.lexeme;
    var absoluteTextOffset = innerValue.offset;
    var tokens = RegExp(r'({{)|(}})');
    var childNodes = <Standalone>[];
    int? seenOpenMustache;

    var scanner = StringScanner(text);

    while (!scanner.isDone) {
      var position = scanner.position;
      var match = tokens.firstMatch(scanner.rest);

      if (match != null) {
        var matchPosition = position + match.start;

        if (match.group(1) != null) {
          if (position != matchPosition) {
            childNodes.add(Text.parsed(
                source, Token.text(absoluteTextOffset + position, text.substring(position, matchPosition))));
          }

          // '{{' found.
          if (seenOpenMustache == null) {
            seenOpenMustache = matchPosition;
          } else {
            // Second '{{' found before '}}' closes it.
            var firstMustacheBegin = absoluteTextOffset + seenOpenMustache;
            throw ParserException(ParserErrorCode.unterminatedMustache, firstMustacheBegin, 2);
          }
        }

        if (match.group(2) != null) {
          if (seenOpenMustache != null) {
            var mustacheBegin = absoluteTextOffset + seenOpenMustache;
            var mustacheEnd = absoluteTextOffset + matchPosition;
            childNodes.add(Interpolation.parsed(
                source,
                Token.interpolationStart(mustacheBegin),
                Token.interpolationValue(mustacheBegin + 2, text.substring(seenOpenMustache + 2, matchPosition)),
                Token.interpolationEnd(mustacheEnd)));
            seenOpenMustache = null;
          } else {
            // Found '}}' before any '{{'
            var mustacheEnd = absoluteTextOffset + matchPosition;
            throw ParserException(ParserErrorCode.unopenedMustache, mustacheEnd, 2);
          }
        }

        scanner.position += match.end;
      } else {
        if (seenOpenMustache == null) {
          var token = Token.text(absoluteTextOffset + scanner.position, text.substring(scanner.position));
          childNodes.add(Text.parsed(source, token));
        }

        scanner.position += scanner.rest.length;
      }
    }

    // Dangling '{{' and hit end of value-text
    if (seenOpenMustache != null) {
      var mustacheBegin = absoluteTextOffset + seenOpenMustache;
      throw ParserException(ParserErrorCode.unterminatedMustache, mustacheBegin, 2);
    }

    return childNodes;
  }

  Interpolation parseInterpolation(Token beginToken) {
    var valueToken = reader.next();
    var endToken = reader.next();
    return Interpolation.parsed(source, beginToken, valueToken as Token, endToken as Token);
  }

  Standalone? parseStandalone(Token token, [List<String>? tagStack]) {
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
        var closeComplement = parseCloseElement(token);
        var offset = closeComplement.beginToken!.offset;
        var length = closeComplement.endToken!.end - closeComplement.beginToken!.offset;
        throw ParserException(ParserErrorCode.danglingCloseElement, offset, length);
      default:
        // Simply throw error here; should never hit.
        var offset = token.offset;
        var length = token.length;
        throw ParserException(ParserErrorCode.expectedStandalone, offset, length);
    }
  }

  void addStarAst(Star starAst, List<Star> starAsts) {
    if (starAsts.isEmpty) {
      starAsts.add(starAst);
    } else {
      var offset = starAst.beginToken!.offset;
      var length = starAst.beginToken!.end - starAst.beginToken!.offset;
      throw ParserException(ParserErrorCode.duplicateStarDirective, offset, length);
    }
  }

  CloseElement _parseCloseElement(
      Token beginToken, Token nameToken, Token endToken, List<Standalone> childNodes, List<String> tagStack) {
    tagStack.add(nameToken.lexeme);
    var closingTagFound = false;
    late CloseElement closeElementAst;

    while (!closingTagFound) {
      var nextToken = reader.next();

      if (nextToken == null) {
        var offset = beginToken.offset;
        var length = endToken.end - beginToken.offset;
        throw ParserException(ParserErrorCode.cannotFindMatchingClose, offset, length);
      } else if (nextToken.type == TokenType.closeElementStart) {
        var closeNameToken = reader.peek()!;
        var closeIdentifier = closeNameToken.lexeme;

        if (closeIdentifier != nameToken.lexeme) {
          // Found a closing tag, but not matching current [ElementAst].
          // Generate initial error code; could be dangling or unmatching.
          if (tagStack.contains(closeIdentifier)) {
            // If the closing tag is in the seen [ElementAst] stack,
            // leave it alone. Instead create a synthetic close.
            var offset = beginToken.offset;
            var length = endToken.end - beginToken.offset;
            throw ParserException(ParserErrorCode.cannotFindMatchingClose, offset, length);
          } else {
            // If the closing tag is not in the stack, create a synthetic
            // [ElementAst] to pair the dangling close and add as child.
            var closeComplement = parseCloseElement(nextToken as Token);
            var offset = closeComplement.beginToken!.offset;
            var length = closeComplement.endToken!.end - closeComplement.beginToken!.offset;
            throw ParserException(ParserErrorCode.danglingCloseElement, offset, length);
          }
        } else {
          closeElementAst = parseCloseElement(nextToken as Token);
          closingTagFound = true;
        }
      } else {
        var childAst = parseStandalone(nextToken as Token, tagStack)!;
        childNodes.add(childAst);
      }
    }

    tagStack.removeLast();
    return closeElementAst;
  }

  Token parseOpenElementEnd() {
    consumeWhitespaces();
    var endToken = reader.next()!;

    if (endToken.type == TokenType.openElementEndVoid) {
      var offset = endToken.offset;
      var length = endToken.length;
      throw ParserException(ParserErrorCode.nonVoidElementUsingVoidEnd, offset, length);
    }

    return endToken as Token;
  }

  void consumeWhitespaces() {
    while (reader.peekType() != null && reader.peekType() == TokenType.whitespace) {
      reader.next();
    }
  }

  Text parseText(Token token) {
    return Text.parsed(source, token);
  }
}
