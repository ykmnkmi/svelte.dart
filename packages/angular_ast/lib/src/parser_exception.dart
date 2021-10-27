import 'package:meta/meta.dart' show sealed;

@sealed
class ParserException extends Error {
  ParserException(this.errorCode, this.offset, this.length);

  final ParserErrorCode errorCode;

  final int? length;

  final int? offset;

  @override
  int get hashCode {
    return Object.hash(errorCode, length, offset);
  }

  @override
  bool operator ==(Object? other) {
    return other is ParserException && errorCode == other.errorCode && length == other.length && offset == other.offset;
  }

  @override
  String toString() {
    return 'AngularParserException {$errorCode}';
  }
}

@sealed
class ParserErrorCode {
  static const ParserErrorCode cannotFindMatchingClose =
      ParserErrorCode('cannotFindMatchingClose', 'Cannot find matching close element to this');

  static const ParserErrorCode danglingCloseElement =
      ParserErrorCode('danglingCloseElement', 'Closing tag is dangling and no matching open tag can be found');

  static const ParserErrorCode duplicateStarDirective =
      ParserErrorCode('DUPLICATE_STAR_DIRECTIVE', 'Already found a *-directive, limit 1 per element.');

  static const ParserErrorCode duplicateSelectorDecorator = ParserErrorCode(
      'duplicateSelectorDecorator', "Only 1 'select' decorator can exist in <ng-content>, found duplicate");

  static const ParserErrorCode duplicateProjectAsDecorator = ParserErrorCode(
      'duplicateProjectAsDecorator', "Only 1 'ngProjectAs' decorator can exist in <ng-content>, found duplicate");

  static const ParserErrorCode duplicateReferenceDecorator = ParserErrorCode(
      'duplicateReferenceDecorator', 'Only 1 reference decorator can exist in <ng-content>, found duplicate');

  static const ParserErrorCode elementDecorator =
      ParserErrorCode('elementDecorator', 'Expected element decorator after whitespace');

  static const ParserErrorCode elementDecoratorAfterPrefix =
      ParserErrorCode('elementDecoratorAfterPrefix', 'Expected element decorator identifier after prefix');

  static const ParserErrorCode elementDecoratorSuffixBeforePrefix =
      ParserErrorCode('elementDecoratorSuffixBeforePrefix', 'Found special decorator suffix before prefix');

  static const ParserErrorCode elementDecoratorValue =
      ParserErrorCode('elementDecoratorValue', "Expected quoted value following '='");

  static const ParserErrorCode elementDecoratorValueMissingQuotes =
      ParserErrorCode('elementDecoratorValueMissingQuotes', 'Decorator values must contain quotes');

  static const ParserErrorCode elementIdentifier = ParserErrorCode('elementIdentifier', 'Expected element tag name');

  static const ParserErrorCode expectedAfterElementIdentifier = ParserErrorCode(
      'expectedAfterElementIdentifier', 'Expected either whitespace or close tag end after element identifier');

  static const ParserErrorCode expectedEuqlSign =
      ParserErrorCode('expectedEuqlSign', "Expected '=' between decorator and value");

  static const ParserErrorCode expectedStandalone = ParserErrorCode('expectedStandalone', 'Expected standalone token');

  static const ParserErrorCode expectedTagClose = ParserErrorCode('expectedTagClose', 'Expected tag close.');

  // 'Catch-all' error code.
  static const ParserErrorCode unexpectedToken = ParserErrorCode('unexpectedToken', 'Unexpected token');

  static const ParserErrorCode expectedWhitespaceBeforeNewDecorator =
      ParserErrorCode('expectedWhitespaceBeforeNewDecorator', 'Expected whitespace before a new decorator');

  static const ParserErrorCode emptyInterpolation =
      ParserErrorCode('emptyInterpolation', 'Interpolation expression cannot be empty');

  static const ParserErrorCode invalidDecoratorInContainer =
      ParserErrorCode('invalidDecoratorInContainer', "Only '*' bindings are supported on <ng-container>");

  static const ParserErrorCode invalidDecoratorInContent =
      ParserErrorCode('invalidDecoratorInContent', "Only 'select' is a valid attribute/decorate in <ng-content>");

  static const ParserErrorCode invalidDecoratorInTemplate =
      ParserErrorCode('INVALID_DECORATOR_IN_TEMPLATE', "Invalid decorator in 'template' element");

  static const ParserErrorCode invalidLetBindingInNonTemplate =
      ParserErrorCode('invalidLetBindingInNonTemplate', "'let-' binding can only be used in 'template' element");

  static const ParserErrorCode invalidMicroExpression =
      ParserErrorCode('invalidMicroExpression', 'Failed parsing micro expression');

  static const ParserErrorCode nonVoidElementUsingVoidEnd =
      ParserErrorCode('nonVoidElementUsingVoidEnd', 'Element is not a void-element');

  static const ParserErrorCode contentMustCloseImmediately = ParserErrorCode(
      'contentMustCloseImmediately', "'<ng-content ...>' must be followed immediately by close '</ng-content>'");

  static const ParserErrorCode propertyNameTooManyFixes =
      ParserErrorCode('propertyNameTooManyFixes', "Property name can only be in format: 'name[.postfix[.unit]]");

  static const ParserErrorCode referenceIdetifierFound =
      ParserErrorCode('referenceIdetifierFound', 'Reference decorator only supports #<variable> on <ng-content>');

  static const ParserErrorCode suffixBanana = ParserErrorCode('suffixBanana', "Expected closing banana ')]'");

  static const ParserErrorCode suffixEvent = ParserErrorCode('suffixEvent', "Expected closing parenthesis ')'");

  static const ParserErrorCode suffixProperty = ParserErrorCode('suffixProperty', "Expected closing bracket ']'");

  static const ParserErrorCode uncloseQuote =
      ParserErrorCode('uncloseQuote', 'Expected close quote for element decorator value');

  static const ParserErrorCode unopenedMustache = ParserErrorCode('unopenedMustache', 'Unopened mustache');

  static const ParserErrorCode unterminatedComment = ParserErrorCode('unterminatedComment', 'Unterminated comment');

  static const ParserErrorCode unterminatedMustache = ParserErrorCode('unterminatedMustache', 'Unterminated mustache');

  static const ParserErrorCode voidElementInCloseTag =
      ParserErrorCode('voidElementInCloseTag', 'Void element identifiers cannot be used in close element tag');

  static const ParserErrorCode voidCloseInCloseTag =
      ParserErrorCode('voidCloseInCloseTag', "Void close '/>' cannot be used in a close element");

  const ParserErrorCode(this.name, this.message);

  final String name;

  final String message;
}
