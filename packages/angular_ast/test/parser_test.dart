import 'package:test/test.dart';
import 'package:angular_ast/angular_ast.dart';

List<Standalone> parse(String template) {
  return const Parser().parse(
    template,
    sourceUrl: '/test/parser_test.dart#inline',
  );
}

void main() {
  group('Parser', () {
    test('should parse empty string', () {
      expect(parse(''), <Node>[]);
    });

    test('should parse a text node', () {
      expect(parse('Hello World'), <Node>[Text('Hello World')]);
    });

    test('should parse a DOM element', () {
      expect(parse('<div></div  >'), <Node>[Element('div', CloseElement('div'))]);
    });

    test('should parse a comment', () {
      expect(parse('<!--Hello World-->'), <Node>[Comment('Hello World')]);
    });

    test('should parse multi-line comments', () {
      expect(parse('<!--Hello\nWorld-->'), <Node>[Comment('Hello\nWorld')]);
      expect(parse('<!--\nHello\nWorld\n-->'), <Node>[Comment('\nHello\nWorld\n')]);
    });

    test('shoud parse a nested DOM structure', () {
      expect(
          parse(''
              '<div>\n'
              '  <span>Hello World</span>\n'
              '</div>\n'),
          <Node>[
            Element('div', CloseElement('div'), childNodes: <Standalone>[
              Text('\n  '),
              Element('span', CloseElement('span'), childNodes: <Standalone>[Text('Hello World')]),
              Text('\n')
            ]),
            Text('\n')
          ]);
    });

    test('should parse an attribute without a value', () {
      expect(parse('<button disabled ></button>'), <Node>[
        Element('button', CloseElement('button'), attributes: <Attribute>[Attribute('disabled')])
      ]);
    });

    test('should parse an attribute with a value', () {
      expect(parse('<button title="Submit"></button>'), <Node>[
        Element('button', CloseElement('button'),
            attributes: <Attribute>[Attribute('title', 'Submit', <Interpolation>[])])
      ]);
    });

    test('should parse a property without a value', () {
      expect(parse('<button [value]></button>'), <Node>[
        Element('button', CloseElement('button'), properties: <Property>[Property('value')])
      ]);
    });

    test('should parse a reference', () {
      expect(parse('<button #btnRef></button>'), <Node>[
        Element('button', CloseElement('button'), references: <Reference>[Reference('btnRef')])
      ]);
    });

    test('should parse a reference with an identifier', () {
      expect(parse('<mat-button #btnRef="mat-button"></mat-button>'), <Node>[
        Element('mat-button', CloseElement('mat-button'), references: <Reference>[Reference('btnRef', 'mat-button')])
      ]);
    });

    test('should parse a container', () {
      expect(parse('<ng-container></ng-container>'), [Container()]);
    });

    test('should parse an embedded content directive', () {
      expect(parse('<ng-content></ng-content>'), <Node>[EmbeddedContent()]);
    });

    test('should parse an embedded content directive with a selector', () {
      expect(parse('<ng-content select="tab"></ng-content>'), <Node>[EmbeddedContent('tab')]);
    });

    test('should parse an embedded content directive with an ngProjectAs', () {
      expect(parse('<ng-content select="foo" ngProjectAs="bar"></ng-content>'), <Node>[EmbeddedContent('foo', 'bar')]);
    });

    test('should parse an embedded content directive with a name selector', () {
      expect(parse('<ng-content select="foo" ngProjectAs="bar" #baz></ng-content>'),
          <Node>[EmbeddedContent('foo', 'bar', Reference('baz'))]);
    });

    test('should parse a <template> directive', () {
      expect(parse('<template></template>'), <Node>[EmbeddedNode()]);
    });

    test('should parse a <template> directive with attributes', () {
      expect(parse('<template ngFor let-item let-i="index"></template>'), <Node>[
        EmbeddedNode(
            attributes: <Attribute>[Attribute('ngFor')],
            letBindings: <LetBinding>[LetBinding('item'), LetBinding('i', 'index')])
      ]);
    });

    test('should parse a <template> directive with let-binding and hashref', () {
      expect(parse('<template let-foo="bar" let-baz #tempRef></template>'), <Node>[
        EmbeddedNode(
            references: <Reference>[Reference('tempRef')],
            letBindings: <LetBinding>[LetBinding('foo', 'bar'), LetBinding('baz')])
      ]);
    });

    test('should parse a <template> directive with a reference', () {
      expect(parse('<template #named ></template>'), <Node>[
        EmbeddedNode(references: <Reference>[Reference('named')])
      ]);
    });

    test('should parse a <template> directive with children', () {
      expect(parse('<template>Hello World</template>'), <Node>[
        EmbeddedNode(childNodes: <Standalone>[Text('Hello World')])
      ]);
    });

    test('should parse a structural directive with the * sugar syntax', () {
      expect(parse('<div *ngIf="someValue">Hello World</div>'),
          parse('<template [ngIf]="someValue"><div>Hello World</div></template>'));
    });

    test('should handle a microsyntax expression with leading whitespace', () {
      expect(
          parse('<div *ngFor="\n  let item of items">{{item}}</div>'),
          parse('<template ngFor let-item [ngForOf]="items">'
              '<div>{{item}}</div>'
              '</template>'));
    });

    test('should parse a structural directive in child position', () {
      expect(parse('<div><div *ngIf="someValue">Hello World</div></div>'),
          parse('<div><template [ngIf]="someValue"><div>Hello World</div></template></div>'));
    });

    test('should parse a structural directive on a container', () {
      expect(
          parse('<ng-container *ngIf="someValue">Hello world</ng-container>'),
          parse('<template [ngIf]="someValue">'
              '<ng-container>Hello world</ng-container>'
              '</template>'));
    });

    test('should parse a void element (implicit)', () {
      expect(parse('<input><div></div>'), <Node>[Element('input', null), Element('div', CloseElement('div'))]);
    });

    test('should parse svg elements as void (explicit) or non void', () {
      expect(parse('<path /><path></path>'), <Node>[Element('path', null), Element('path', CloseElement('path'))]);
    });

    test('should parse an annotation with a value', () {
      expect(parse('<div @foo="bar"></div>'), <Node>[
        Element('div', CloseElement('div'), annotations: <Annotation>[Annotation('foo', 'bar')])
      ]);
    });

    test('should parse an annotation on a container', () {
      expect(parse('<ng-container @annotation></ng-container>'), <Node>[
        Container(annotations: <Annotation>[Annotation('annotation')])
      ]);
    });

    test('should parse an annotation on an embedded template', () {
      expect(parse('<template @annotation></template>'), <Node>[
        EmbeddedNode(annotations: <Annotation>[Annotation('annotation')])
      ]);
    });

    test('should include annotation value in source span', () {
      var source = '@foo="bar"';
      var template = '<p $source></p>';
      var ast = parse(template).single as Element;
      var annotation = ast.annotations.single;
      expect(annotation.sourceSpan.text, source);
    });

    test('should parse an annotation with a compound name', () {
      expect(parse('<div @foo.bar></div>'), <Node>[
        Element('div', CloseElement('div'), annotations: <Annotation>[Annotation('foo.bar')])
      ]);
    });
  });
}
