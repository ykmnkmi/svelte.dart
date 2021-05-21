part of 'exception_handler.dart';

@sealed
class ParserErrorCode {
  static const ParserErrorCode cannotFindMatchingClose = ParserErrorCode('cannotFindMatchingClose', 'Cannot find matching close element to this');

  static const ParserErrorCode danglingCloseElement = ParserErrorCode('danglingCloseElement', 'Closing tag is dangling and no matching open tag can be found');

  static const ParserErrorCode duplicateStarDirective = ParserErrorCode('duplicateStarDirective', 'Already found a *-directive, limit 1 per element.');

  static const ParserErrorCode duplicateSelectDecorator =
      ParserErrorCode('duplicateSelectDecorator', "Only 1 'select' decorator can exist in <piko:content>, found duplicate");

  static const ParserErrorCode duplicateProjectAsDecorator =
      ParserErrorCode('duplicateProjectAsDecorator', "Only 1 'ngProjectAs' decorator can exist in <piko:content>, found duplicate");

  static const ParserErrorCode duplicateReferenceDecorator =
      ParserErrorCode('duplicateReferenceDecorator', 'Only 1 reference decorator can exist in <piko:content>, found duplicate');

  static const ParserErrorCode elementDecorator = ParserErrorCode('elementDecorator', 'Expected element decorator after whitespace');

  static const ParserErrorCode elementDecoratorAfterPrefix =
      ParserErrorCode('elementDecoratorAfterPrefix', 'Expected element decorator identifier after prefix');

  static const ParserErrorCode elementDecoratorSuffixBeforePrefix = ParserErrorCode('elementDecorator', 'Found special decorator suffix before prefix');

  static const ParserErrorCode elementDecoratorValue = ParserErrorCode('elementDecoratorValue', "Expected quoted value following '='");

  static const ParserErrorCode elementDecoratorValueMissingQuotes =
      ParserErrorCode('elementDecoratorValueMissingQuotes', 'Decorator values must contain quotes');

  static const ParserErrorCode elementIdentifier = ParserErrorCode('elementIdentifier', 'Expected element tag name');

  static const ParserErrorCode expectedAfterElementIdentifier =
      ParserErrorCode('expectedAfterElementIdentifier', 'Expected either whitespace or close tag end after element identifier');

  static const ParserErrorCode expectedEqualSign = ParserErrorCode('expectedEqualSign', "Expected '=' between decorator and value");

  static const ParserErrorCode expectedStandalone = ParserErrorCode('expectingStandalone', 'Expected standalone token');

  static const ParserErrorCode expectedTagClose = ParserErrorCode('expectedTagClose', 'Expected tag close.');

  // 'Catch-all' error code.
  static const ParserErrorCode unexpectedToken = ParserErrorCode('unexpectedToken', 'Unexpected token');

  static const ParserErrorCode expectedWhitespaceBeforeNewDecorator =
      ParserErrorCode('expectedWhitespaceBeforeDecorator', 'Expected whitespace before a new decorator');

  static const ParserErrorCode emptyInterpolation = ParserErrorCode('emptyInterpolation', 'Interpolation expression cannot be empty');

  static const ParserErrorCode invalidDecoratorInContainer =
      ParserErrorCode('invalidDecoratorInNgcontainer', "Only '*' bindings are supported on <ng-container>");

  static const ParserErrorCode invalidDecoratorInContent =
      ParserErrorCode('invalidDecoratorInNgcontent', "Only 'select' is a valid attribute/decorate in <piko:content>");

  static const ParserErrorCode invalidDecoratorInTemplate = ParserErrorCode('invalidDecoratorInTemplate', "Invalid decorator in 'template' element");

  static const ParserErrorCode invalidLetBindingInNontemplate =
      ParserErrorCode('invalidLetBindingInNontemplate', "'let-' binding can only be used in 'template' element");

  static const ParserErrorCode invalidMicroExpression = ParserErrorCode('invalidMicroExpression', 'Failed parsing micro expression');

  static const ParserErrorCode nonVoidElementUsingVoidEnd = ParserErrorCode('nonvoidElementUsingVoidEnd', 'Element is not a void-element');

  static const ParserErrorCode contentMustCloseImmediately =
      ParserErrorCode('ngcontentMustCloseImmediately', "'<piko:content ...>' must be followed immediately by close '</piko:content>'");

  static const ParserErrorCode propertyNameTooManyFixes =
      ParserErrorCode('propertyNameTooManyFixes', "Property name can only be in format: 'name[.postfix[.unit]]");

  static const ParserErrorCode referenceIdentifierFound =
      ParserErrorCode('referenceIdentifierFound', 'Reference decorator only supports #<variable> on <piko:content>');

  static const ParserErrorCode suffixBanana = ParserErrorCode('suffixBanana', "Expected closing banana ')]'");

  static const ParserErrorCode suffixEvent = ParserErrorCode('suffixEvent', "Expected closing parenthesis ')'");

  static const ParserErrorCode suffixProperty = ParserErrorCode('suffixProperty', "Expected closing bracket ']'");

  static const ParserErrorCode unclosedQuote = ParserErrorCode('unclosedQuote', 'Expected close quote for element decorator value');

  static const ParserErrorCode unopenedMustache = ParserErrorCode('unopenedMustache', 'Unopened mustache');

  static const ParserErrorCode unterminatedComment = ParserErrorCode('unterminated COMMENT', 'Unterminated comment');

  static const ParserErrorCode unterminatedMustache = ParserErrorCode('unterminatedMustache', 'Unterminated mustache');

  static const ParserErrorCode voidElementInCloseTag = ParserErrorCode('voidElementInCloseTag', 'Void element identifiers cannot be used in close element tag');

  static const ParserErrorCode voidCloseInCloseTag = ParserErrorCode('voidCloseInCloseTag', "Void close '/>' cannot be used in a close element");

  const ParserErrorCode(this.name, this.message);

  final String name;

  final String message;
}
