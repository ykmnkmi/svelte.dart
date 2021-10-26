import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import '../ast.dart';
import '../exception_handler/exception_handler.dart';
import '../token/tokens.dart';
import 'reader.dart';

/// A recursive descent AST parser from a series of tokens.
class RecursiveAstParser {
  final NgTokenReversibleReader<Object> _reader;
  final SourceFile _source;
  final List<String> _voidElements;
  final List<String> _svgElements;
  final ExceptionHandler exceptionHandler;

  RecursiveAstParser(
    SourceFile sourceFile,
    Iterable<NgToken> tokens,
    this._voidElements,
    this._svgElements,
    this.exceptionHandler,
  )   : _reader = NgTokenReversibleReader<NgTokenType>(sourceFile, tokens),
        _source = sourceFile;

  /// Iterates through and returns the top-level AST nodes from the tokens.
  List<StandaloneTemplate> parse() {
    // Start with an empty list.
    var nodes = <StandaloneTemplate>[];
    NgToken? token;
    // Iterate through until and wait until EOF.
    //
    // Collects comments, elements, and text.
    //
    // Any other AST structure should be handled by the parseElement case.
    while ((token = _reader.next() as NgToken?) != null) {
      nodes.add(parseStandalone(token!)!);
    }

    // Return the collected nodes.
    return nodes;
  }

  /// Parses and returns a [CloseElement].
  CloseElement parseCloseElement(NgToken beginToken) {
    var nameToken = _reader.next()!;
    if (_voidElements.contains(nameToken.lexeme)) {
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.VOID_ELEMENT_IN_CLOSE_TAG,
        nameToken.offset,
        nameToken.length,
      ));
    }

    while (_reader.peekType() == NgTokenType.whitespace) {
      _reader.next();
    }
    var closeElementEnd = _reader.next();
    return CloseElement.parsed(
      _source,
      beginToken,
      nameToken as NgToken,
      closeElementEnd as NgToken,
    );
  }

  /// Parses and returns a comment beginning at the token provided.
  Comment parseComment(NgToken beginToken) {
    NgToken valueToken;
    if (_reader.peekType() == NgTokenType.commentEnd) {
      valueToken = NgToken.commentValue(_reader.peek()!.offset, '');
    } else {
      valueToken = _reader.next() as NgToken;
    }
    var endToken = _reader.next();
    return Comment.parsed(
      _source,
      beginToken,
      valueToken,
      endToken as NgToken,
    );
  }

  /// Parses and returns an `<ng-container>` AST.
  Container parseContainer(
    NgToken beginToken,
    NgToken nameToken,
    List<String> tagStack,
  ) {
    final annotations = <Annotation>[];
    final childNodes = <StandaloneTemplate>[];
    final stars = <Star>[];

    while (_reader.peekType() == NgTokenType.beforeElementDecorator) {
      final nextToken = _reader.next();
      final decorator = parseDecorator(nextToken as NgToken);
      if (decorator is Annotation) {
        annotations.add(decorator);
      } else if (decorator is Star) {
        _addStarAst(decorator, stars);
      } else {
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.INVALID_DECORATOR_IN_NGCONTAINER,
          decorator.beginToken!.offset,
          decorator.endToken!.end - decorator.beginToken!.offset,
        ));
      }
    }

    final endToken = _parseOpenElementEnd();
    final closeComplement = _parseCloseElement(beginToken, nameToken, endToken, childNodes, tagStack);

    return Container.parsed(
      _source,
      beginToken,
      endToken,
      closeComplement,
      annotations: annotations,
      childNodes: childNodes,
      stars: stars,
    );
  }

  /// Parses and returns a template AST beginning at the token provided.
  /// No desugaring of any kind occurs here.
  Template parseDecorator(NgToken beginToken) {
    // The first token is the decorator/name.
    NgToken? prefixToken;
    NgToken? decoratorToken;
    NgToken? suffixToken;

    var peekType = _reader.peekType();
    if (peekType == NgTokenType.bananaPrefix ||
        peekType == NgTokenType.eventPrefix ||
        peekType == NgTokenType.propertyPrefix) {
      prefixToken = _reader.next() as NgToken;
      decoratorToken = _reader.next() as NgToken;
      suffixToken = _reader.next() as NgToken;
    } else if (peekType == NgTokenType.referencePrefix ||
        peekType == NgTokenType.templatePrefix ||
        peekType == NgTokenType.annotationPrefix) {
      prefixToken = _reader.next() as NgToken;
      decoratorToken = _reader.next() as NgToken;
    } else {
      decoratorToken = _reader.next() as NgToken;
    }

    NgAttributeValueToken? valueToken;
    NgToken? equalSignToken;

    if (_reader.peekTypeIgnoringType(NgTokenType.whitespace) == NgTokenType.beforeElementDecoratorValue) {
      _consumeWhitespaces();
      equalSignToken = _reader.next() as NgToken;
      _consumeWhitespaces();
      valueToken = _reader.next() as NgAttributeValueToken;
    }

    if (prefixToken != null) {
      var prefixType = prefixToken.type;

      if (prefixType == NgTokenType.bananaPrefix) {
        return Banana.parsed(
          _source,
          prefixToken,
          decoratorToken,
          suffixToken as NgToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.eventPrefix) {
        // Disabling: event names can be as long as keyup.ctrl.shift.alt.mod.+
        // Should this be limited to 6 then? Or should it be left open?
        //if (decoratorToken.lexeme.split('.').length > 2) {
        //  exceptionHandler.handle(new AngularParserException(
        //    NgParserWarningCode.EVENT_NAME_TOO_MANY_FIXES,
        //    decoratorToken.offset,
        //    decoratorToken.length,
        //  ));
        //}

        return Event.parsed(
          _source,
          prefixToken,
          decoratorToken,
          suffixToken as NgToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.propertyPrefix) {
        if (decoratorToken.lexeme.split('.').length > 3) {
          exceptionHandler.handle(AngularParserException(
            ParserErrorCode.PROPERTY_NAME_TOO_MANY_FIXES,
            decoratorToken.offset,
            decoratorToken.length,
          ));
        }

        return Property.parsed(
          _source,
          prefixToken,
          decoratorToken,
          suffixToken as NgToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.referencePrefix) {
        return Reference.parsed(
          _source,
          prefixToken,
          decoratorToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.templatePrefix) {
        return Star.parsed(
          _source,
          prefixToken,
          decoratorToken,
          valueToken,
          equalSignToken,
        );
      } else if (prefixType == NgTokenType.annotationPrefix) {
        return Annotation.parsed(
          _source,
          prefixToken,
          decoratorToken,
          valueToken,
          equalSignToken,
        );
      }
    }

    // At this point, it is a TextAttribute, but handle cases
    // with 'on-' and 'bind-' prefix.
    if (decoratorToken.lexeme.startsWith('on-')) {
      var onToken = NgToken.onPrefix(decoratorToken.offset);
      decoratorToken = NgToken.elementDecorator(
        decoratorToken.offset + 'on-'.length,
        decoratorToken.lexeme.substring('on-'.length),
      );
      if (decoratorToken.lexeme == '') {
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.ELEMENT_DECORATOR_AFTER_PREFIX,
          onToken.offset,
          onToken.length,
        ));
      }
      return Event.parsed(
        _source,
        onToken,
        decoratorToken,
        null,
        valueToken,
        equalSignToken,
      );
    }
    if (decoratorToken.lexeme.startsWith('bind-')) {
      var bindToken = NgToken.bindPrefix(decoratorToken.offset);
      decoratorToken = NgToken.elementDecorator(
        decoratorToken.offset + 'bind-'.length,
        decoratorToken.lexeme.substring('bind-'.length),
      );
      if (decoratorToken.lexeme == '') {
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.ELEMENT_DECORATOR_AFTER_PREFIX,
          bindToken.offset,
          bindToken.length,
        ));
      }
      return Property.parsed(
        _source,
        bindToken,
        decoratorToken,
        null,
        valueToken,
        equalSignToken,
      );
    }
    if (decoratorToken.lexeme.startsWith('let-')) {
      var letToken = NgToken.letPrefix(decoratorToken.offset);
      decoratorToken = NgToken.elementDecorator(
        decoratorToken.offset + 'let-'.length,
        decoratorToken.lexeme.substring('let-'.length),
      );
      return LetBinding.parsed(
        _source,
        letToken,
        decoratorToken,
        valueToken,
        equalSignToken,
      );
    }

    List<StandaloneTemplate> parsedMustaches;

    if (valueToken != null) {
      parsedMustaches = _parseMustacheInPlainAttributeValue(valueToken.innerValue!);
    } else {
      parsedMustaches = const <StandaloneTemplate>[];
    }

    return Attribute.parsed(_source, decoratorToken, valueToken, equalSignToken, parsedMustaches);
  }

  /// Returns a DOM element AST starting at the provided token.
  ///
  /// It's possible the element will end up not being an [Element].
  StandaloneTemplate parseElement(NgToken beginToken, List<String> tagStack) {
    var isTemplateElement = false;

    // Parse the element identifier.
    var nameToken = _reader.next()!;
    if (nameToken.lexeme == 'ng-container') {
      return parseContainer(beginToken, nameToken as NgToken, tagStack);
    } else if (nameToken.lexeme == 'ng-content') {
      return parseEmbeddedContent(beginToken, nameToken as NgToken);
    } else if (nameToken.lexeme.toLowerCase() == 'template') {
      isTemplateElement = true;
    }
    var isVoidElement = _voidElements.contains(nameToken.lexeme);
    // TODO(alorenzen): Add better namespace handling.
    var isSvgElement = _svgElements.contains(nameToken.lexeme.replaceAll('svg:', ''));

    // Start collecting decorators.
    var attributes = <Attribute>[];
    var childNodes = <StandaloneTemplate>[];
    var events = <Event>[];
    var properties = <Property>[];
    var references = <Reference>[];
    var bananas = <Banana>[];
    var stars = <Star>[];
    var annotations = <Annotation>[];
    var letBindings = <LetBinding>[];
    NgToken nextToken;

    // Start looping and get all of the decorators within the element.
    do {
      nextToken = _reader.next() as NgToken;
      if (nextToken.type == NgTokenType.beforeElementDecorator) {
        var decoratorAst = parseDecorator(nextToken);
        if (decoratorAst is Attribute) {
          attributes.add(decoratorAst);
        } else if (decoratorAst is LetBinding) {
          if (!isTemplateElement) {
            // 'let-' binding can only exist in <template>.
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.INVALID_LET_BINDING_IN_NONTEMPLATE,
              decoratorAst.beginToken!.offset,
              decoratorAst.endToken!.end - decoratorAst.beginToken!.offset,
            ));
          } else if (decoratorAst.name.isEmpty) {
            var letToken = (decoratorAst as ParsedLetBinding).prefixToken;
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.ELEMENT_DECORATOR_AFTER_PREFIX,
              letToken.offset,
              letToken.length,
            ));
          } else {
            letBindings.add(decoratorAst);
          }
        } else if (decoratorAst is Star) {
          if (isTemplateElement) {
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.INVALID_DECORATOR_IN_TEMPLATE,
              decoratorAst.beginToken!.offset,
              decoratorAst.endToken!.end - decoratorAst.beginToken!.offset,
            ));
          } else {
            if (stars.isNotEmpty) {
              exceptionHandler.handle(AngularParserException(
                ParserErrorCode.DUPLICATE_STAR_DIRECTIVE,
                decoratorAst.beginToken!.offset,
                decoratorAst.endToken!.end - decoratorAst.beginToken!.offset,
              ));
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
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.INVALID_DECORATOR_IN_TEMPLATE,
              decoratorAst.beginToken!.offset,
              decoratorAst.endToken!.end - decoratorAst.beginToken!.offset,
            ));
          } else {
            bananas.add(decoratorAst);
          }
        } else if (decoratorAst is Reference) {
          references.add(decoratorAst);
        } else {
          throw StateError('Invalid decorator AST: $decoratorAst');
        }
      }
    } while (nextToken.type != NgTokenType.openElementEnd && nextToken.type != NgTokenType.openElementEndVoid);

    if (!isVoidElement && !isSvgElement && nextToken.type == NgTokenType.openElementEndVoid) {
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.NONVOID_ELEMENT_USING_VOID_END,
        nextToken.offset,
        nextToken.length,
      ));
      nextToken = NgToken.generateErrorSynthetic(
        nextToken.offset,
        NgTokenType.openElementEnd,
      );
    }
    var endToken = nextToken;
    CloseElement? closeElementAst;

    // If not a void element, look for closing tag OR child nodes.
    if (!isVoidElement && nextToken.type != NgTokenType.openElementEndVoid) {
      closeElementAst = _parseCloseElement(
        beginToken,
        nameToken as NgToken,
        endToken,
        childNodes,
        tagStack,
      );
    }

    if (isTemplateElement) {
      return EmbeddedTemplateAst.parsed(
        _source,
        beginToken,
        endToken,
        closeComplement: closeElementAst,
        annotations: annotations,
        attributes: attributes,
        childNodes: childNodes,
        events: events,
        properties: properties,
        references: references,
        letBindings: letBindings,
      );
    } else {
      return Element.parsed(
        _source,
        beginToken,
        nameToken as NgToken,
        endToken,
        annotations: annotations,
        attributes: attributes,
        childNodes: childNodes,
        events: events,
        properties: properties,
        references: references,
        bananas: bananas,
        stars: stars,
        closeComplement: closeElementAst,
      );
    }
  }

  /// Returns and parses an embedded content directive/transclusions.
  EmbeddedContent parseEmbeddedContent(NgToken beginToken, NgToken elementIdentifierToken) {
    NgToken endToken;
    Attribute? selectAttribute, ngProjectAsAttribute;
    Reference? reference;
    var selectAttributeFound = false;
    var ngProjectAsAttributeFound = false;
    var referenceAttributeFound = false;
    CloseElement closeElementAst;

    // Ensure that ng-content has only 'select', 'ngProjectAs' and a reference,
    // if any. Also catch for multiple ones; if multiple, accept the first one
    // seen.
    while (_reader.peekType() == NgTokenType.beforeElementDecorator) {
      final nextToken = _reader.next();
      final decorator = parseDecorator(nextToken as NgToken);
      final startOffset = decorator.beginToken!.offset;
      final endOffset = decorator.endToken!.end;
      if (decorator is Attribute && decorator.name == 'select') {
        if (selectAttributeFound) {
          var e = AngularParserException(
            ParserErrorCode.DUPLICATE_SELECT_DECORATOR,
            startOffset,
            endOffset - startOffset,
          );
          exceptionHandler.handle(e);
        } else {
          selectAttributeFound = true;
          selectAttribute = decorator;
        }
      } else if (decorator is Attribute && decorator.name == 'ngProjectAs') {
        if (ngProjectAsAttributeFound) {
          var e = AngularParserException(
            ParserErrorCode.DUPLICATE_PROJECT_AS_DECORATOR,
            startOffset,
            endOffset - startOffset,
          );
          exceptionHandler.handle(e);
        } else {
          ngProjectAsAttributeFound = true;
          ngProjectAsAttribute = decorator;
        }
      } else if (decorator is Reference) {
        if (referenceAttributeFound) {
          var e = AngularParserException(
            ParserErrorCode.DUPLICATE_REFERENCE_DECORATOR,
            startOffset,
            endOffset - startOffset,
          );
          exceptionHandler.handle(e);
        } else {
          referenceAttributeFound = true;
          reference = decorator;
          if (reference.identifier != null) {
            var e = AngularParserException(
              ParserErrorCode.REFERENCE_IDENTIFIER_FOUND,
              startOffset,
              endOffset - startOffset,
            );
            exceptionHandler.handle(e);
          }
        }
      } else {
        var e = AngularParserException(
          ParserErrorCode.INVALID_DECORATOR_IN_NGCONTENT,
          decorator.beginToken!.offset,
          decorator.endToken!.end - decorator.beginToken!.offset,
        );
        exceptionHandler.handle(e);
      }
    }

    endToken = _parseOpenElementEnd();

    // Skip whitespace after <ng-content>.
    if (_reader.peekType() == NgTokenType.text) {
      final textToken = _reader.next();
      final text = parseText(textToken as NgToken);
      if (text.value.trim().isNotEmpty) {
        _reader.putBack(textToken);
      }
    }

    // Ensure closing </ng-content> exists.
    if (_reader.peekType() != NgTokenType.closeElementStart) {
      var e = AngularParserException(
        ParserErrorCode.NGCONTENT_MUST_CLOSE_IMMEDIATELY,
        beginToken.offset,
        endToken.end - beginToken.offset,
      );
      exceptionHandler.handle(e);
      closeElementAst = CloseElement('ng-content');
    } else {
      var closeElementStart = _reader.next();
      var closeElementName = _reader.peek()!.lexeme;

      if (closeElementName != 'ng-content') {
        var e = AngularParserException(
          ParserErrorCode.NGCONTENT_MUST_CLOSE_IMMEDIATELY,
          beginToken.offset,
          endToken.end - beginToken.offset,
        );
        exceptionHandler.handle(e);
        _reader.putBack(closeElementStart!);
        closeElementAst = CloseElement('ng-content');
      } else {
        closeElementAst = parseCloseElement(closeElementStart as NgToken);
      }
    }
    return EmbeddedContent.parsed(
      _source,
      beginToken,
      elementIdentifierToken,
      endToken,
      closeElementAst,
      selectAttribute,
      ngProjectAsAttribute,
      reference,
    );
  }

  /// Helper function that, given a plain attribute value,
  /// parses it and generates a list of [StandaloneTemplate].
  /// Upon mustache errors, either throws or recovers based on
  /// [ExceptionHandler] used.
  List<StandaloneTemplate> _parseMustacheInPlainAttributeValue(NgToken innerValue) {
    var text = innerValue.lexeme;
    var absoluteTextOffset = innerValue.offset;
    var tokens = RegExp(r'({{)|(}})');
    var childNodes = <StandaloneTemplate>[];
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
                _source, NgToken.text(absoluteTextOffset + position, text.substring(position, matchPosition))));
          }

          // '{{' found.
          if (seenOpenMustache == null) {
            seenOpenMustache = matchPosition;
          } else {
            // Second '{{' found before '}}' closes it.
            var firstMustacheBegin = absoluteTextOffset + seenOpenMustache;
            exceptionHandler
                .handle(AngularParserException(ParserErrorCode.UNTERMINATED_MUSTACHE, firstMustacheBegin, 2));

            childNodes.add(Interpolation.parsed(
              _source,
              NgToken.interpolationStart(firstMustacheBegin),
              NgToken.interpolationValue(firstMustacheBegin + 2, text.substring(seenOpenMustache + 2, matchPosition)),
              NgToken.generateErrorSynthetic(absoluteTextOffset + matchPosition, NgTokenType.interpolationEnd),
            ));
            seenOpenMustache = matchPosition;
          }
        }

        if (match.group(2) != null) {
          if (seenOpenMustache != null) {
            var mustacheBegin = absoluteTextOffset + seenOpenMustache;
            var mustacheEnd = absoluteTextOffset + matchPosition;
            childNodes.add(Interpolation.parsed(
              _source,
              NgToken.interpolationStart(mustacheBegin),
              NgToken.interpolationValue(mustacheBegin + 2, text.substring(seenOpenMustache + 2, matchPosition)),
              NgToken.interpolationEnd(mustacheEnd),
            ));
            seenOpenMustache = null;
          } else {
            // Found '}}' before any '{{'
            var mustacheBegin = absoluteTextOffset + position;
            var mustacheEnd = absoluteTextOffset + matchPosition;
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.UNOPENED_MUSTACHE,
              mustacheEnd,
              '}}'.length,
            ));
            childNodes.add(Interpolation.parsed(
              _source,
              NgToken.generateErrorSynthetic(mustacheBegin, NgTokenType.interpolationStart),
              NgToken.interpolationValue(mustacheBegin, text.substring(position, matchPosition)),
              NgToken.interpolationEnd(mustacheEnd),
            ));
          }
        }

        scanner.position += match.end;
      } else {
        if (seenOpenMustache == null) {
          var token = NgToken.text(absoluteTextOffset + scanner.position, text.substring(scanner.position));
          childNodes.add(Text.parsed(_source, token));
        }

        scanner.position += scanner.rest.length;
      }
    }

    // Dangling '{{' and hit end of value-text
    if (seenOpenMustache != null) {
      var mustacheBegin = absoluteTextOffset + seenOpenMustache;

      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.UNTERMINATED_MUSTACHE,
        mustacheBegin,
        2,
      ));

      childNodes.add(Interpolation.parsed(
        _source,
        NgToken.interpolationStart(mustacheBegin),
        NgToken.interpolationValue(mustacheBegin + 2, text.substring(seenOpenMustache + 2)),
        NgToken.generateErrorSynthetic(absoluteTextOffset + text.length, NgTokenType.interpolationEnd),
      ));
    }

    return childNodes;
  }

  /// Returns and parses an interpolation AST.
  Interpolation parseInterpolation(NgToken beginToken) {
    var valueToken = _reader.next();
    var endToken = _reader.next();
    return Interpolation.parsed(_source, beginToken, valueToken as NgToken, endToken as NgToken);
  }

  /// Returns and parses a top-level AST structure.
  StandaloneTemplate? parseStandalone(
    NgToken token, [
    List<String>? tagStack,
  ]) {
    tagStack ??= [];
    switch (token.type) {
      case NgTokenType.commentStart:
        return parseComment(token);
      case NgTokenType.openElementStart:
        return parseElement(token, tagStack);
      case NgTokenType.interpolationStart:
        return parseInterpolation(token);
      case NgTokenType.text:
        return parseText(token);
      // Dangling close tag. If error recovery is enabled, returns
      // a synthetic open with the dangling close. If not enabled,
      // simply throws error.
      case NgTokenType.closeElementStart:
        var danglingCloseIdentifier = _reader.peek()!.lexeme;
        var closeComplement = parseCloseElement(token);
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.DANGLING_CLOSE_ELEMENT,
          closeComplement.beginToken!.offset,
          closeComplement.endToken!.end - closeComplement.beginToken!.offset,
        ));
        if (danglingCloseIdentifier == 'ng-content') {
          var synthOpenElement = EmbeddedContent();
          synthOpenElement.closeComplement = closeComplement;
          return synthOpenElement;
        } else {
          var synthOpenElement = Element(danglingCloseIdentifier, closeComplement);
          return synthOpenElement;
        }
      default:
        // Simply throw error here; should never hit.
        if (exceptionHandler is RecoveringExceptionHandler) {
          // Throw an error here - this should never hit in recovery mode
          // unless something went really wrong. If so, FIX IT ASAP!
          throw Exception('Non-standalone starting token found!');
        }
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.EXPECTED_STANDALONE,
          token.offset,
          token.length,
        ));
        return null;
    }
  }

  /// Adds [starAst] to [starAsts] if empty, otherwise produces an error.
  void _addStarAst(Star starAst, List<Star> starAsts) {
    if (starAsts.isEmpty) {
      starAsts.add(starAst);
    } else {
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.DUPLICATE_STAR_DIRECTIVE,
        starAst.beginToken!.offset,
        starAst.beginToken!.end - starAst.beginToken!.offset,
      ));
    }
  }

  /// Parses child nodes until the closing tag, which is then returned.
  ///
  /// Child nodes are appended to [childNodes].
  CloseElement _parseCloseElement(
    NgToken beginToken,
    NgToken nameToken,
    NgToken endToken,
    List<StandaloneTemplate> childNodes,
    List<String> tagStack,
  ) {
    tagStack.add(nameToken.lexeme);
    var closingTagFound = false;
    late CloseElement closeElementAst;
    while (!closingTagFound) {
      final nextToken = _reader.next();
      if (nextToken == null) {
        exceptionHandler.handle(AngularParserException(
          ParserErrorCode.CANNOT_FIND_MATCHING_CLOSE,
          beginToken.offset,
          endToken.end - beginToken.offset,
        ));
        closeElementAst = CloseElement(nameToken.lexeme);
        closingTagFound = true;
      } else if (nextToken.type == NgTokenType.closeElementStart) {
        var closeNameToken = _reader.peek()!;
        var closeIdentifier = closeNameToken.lexeme;
        if (closeIdentifier != nameToken.lexeme) {
          // Found a closing tag, but not matching current [ElementAst].
          // Generate initial error code; could be dangling or unmatching.
          if (tagStack.contains(closeIdentifier)) {
            // If the closing tag is in the seen [ElementAst] stack,
            // leave it alone. Instead create a synthetic close.
            _reader.putBack(nextToken);
            closeElementAst = CloseElement(nameToken.lexeme);
            closingTagFound = true;
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.CANNOT_FIND_MATCHING_CLOSE,
              beginToken.offset,
              endToken.end - beginToken.offset,
            ));
          } else {
            // If the closing tag is not in the stack, create a synthetic
            // [ElementAst] to pair the dangling close and add as child.
            var closeComplement = parseCloseElement(nextToken as NgToken);
            exceptionHandler.handle(AngularParserException(
              ParserErrorCode.DANGLING_CLOSE_ELEMENT,
              closeComplement.beginToken!.offset,
              closeComplement.endToken!.end - closeComplement.beginToken!.offset,
            ));
            if (closeIdentifier == 'ng-container') {
              var synthContainer = Container();
              synthContainer.closeComplement = closeComplement;
              childNodes.add(synthContainer);
            } else if (closeIdentifier == 'ng-content') {
              var synthContent = EmbeddedContent();
              synthContent.closeComplement = closeComplement;
              childNodes.add(synthContent);
            } else if (closeIdentifier == 'template') {
              var synthTemplate = EmbeddedTemplateAst();
              synthTemplate.closeComplement = closeComplement;
              childNodes.add(synthTemplate);
            } else {
              var synthOpenElement = Element(closeNameToken.lexeme, closeComplement);
              childNodes.add(synthOpenElement);
            }
          }
        } else {
          closeElementAst = parseCloseElement(nextToken as NgToken);
          closingTagFound = true;
        }
      } else {
        var childAst = parseStandalone(nextToken as NgToken, tagStack)!;
        childNodes.add(childAst);
      }
    }
    tagStack.removeLast();
    return closeElementAst;
  }

  /// Ensures open element ends with `>` and not `/>`.
  NgToken _parseOpenElementEnd() {
    _consumeWhitespaces();
    final endToken = _reader.next()!;
    if (endToken.type == NgTokenType.openElementEndVoid) {
      exceptionHandler.handle(AngularParserException(
        ParserErrorCode.NONVOID_ELEMENT_USING_VOID_END,
        endToken.offset,
        endToken.length,
      ));
      return NgToken.generateErrorSynthetic(
        endToken.offset,
        NgTokenType.openElementEnd,
      );
    }
    return endToken as NgToken;
  }

  void _consumeWhitespaces() {
    while (_reader.peekType() != null && _reader.peekType() == NgTokenType.whitespace) {
      _reader.next();
    }
  }

  /// Returns and parses a text AST.
  Text parseText(NgToken token) => Text.parsed(_source, token);
}
