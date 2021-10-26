import 'package:test/test.dart';
import 'package:angular_ast/angular_ast.dart';

void main() {
  List<StandaloneTemplate> parse(String template) {
    return const NgParser().parse(
      template,
      sourceUrl: '/test/parser_test.dart#inline',
    );
  }

  test('should parse empty string', () {
    expect(parse(''), []);
  });

  test('should parse a text node', () {
    expect(
      parse('Hello World'),
      [
        Text('Hello World'),
      ],
    );
  });

  test('should parse a DOM element', () {
    expect(
      parse('<div></div  >'),
      [
        Element('div', CloseElement('div')),
      ],
    );
  });

  test('should parse a comment', () {
    expect(
      parse('<!--Hello World-->'),
      [
        Comment('Hello World'),
      ],
    );
  });

  test('should parse multi-line comments', () {
    expect(parse('<!--Hello\nWorld-->'), [
      Comment('Hello\nWorld'),
    ]);

    expect(
      parse('<!--\nHello\nWorld\n-->'),
      [
        Comment('\nHello\nWorld\n'),
      ],
    );
  });

  test('shoud parse a nested DOM structure', () {
    expect(
      parse(''
          '<div>\n'
          '  <span>Hello World</span>\n'
          '</div>\n'),
      [
        Element('div', CloseElement('div'), childNodes: [
          Text('\n  '),
          Element('span', CloseElement('span'), childNodes: [
            Text('Hello World'),
          ]),
          Text('\n'),
        ]),
        Text('\n'),
      ],
    );
  });

  test('should parse an attribute without a value', () {
    expect(
      parse('<button disabled ></button>'),
      [
        Element('button', CloseElement('button'), attributes: [
          Attribute('disabled'),
        ]),
      ],
    );
  });

  test('should parse an attribute with a value', () {
    expect(
      parse('<button title="Submit"></button>'),
      [
        Element('button', CloseElement('button'), attributes: [
          Attribute('title', 'Submit', <Interpolation>[]),
        ]),
      ],
    );
  });

  test('should parse a property without a value', () {
    expect(
      parse('<button [value]></button>'),
      [
        Element('button', CloseElement('button'), properties: [
          Property('value'),
        ]),
      ],
    );
  });

  test('should parse a reference', () {
    expect(
      parse('<button #btnRef></button>'),
      [
        Element('button', CloseElement('button'), references: [
          Reference('btnRef'),
        ]),
      ],
    );
  });

  test('should parse a reference with an identifier', () {
    expect(
      parse('<mat-button #btnRef="mat-button"></mat-button>'),
      [
        Element('mat-button', CloseElement('mat-button'), references: [
          Reference('btnRef', 'mat-button'),
        ]),
      ],
    );
  });

  test('should parse a container', () {
    expect(parse('<ng-container></ng-container>'), [Container()]);
  });

  test('should parse an embedded content directive', () {
    expect(
      parse('<ng-content></ng-content>'),
      [
        EmbeddedContent(),
      ],
    );
  });

  test('should parse an embedded content directive with a selector', () {
    expect(
      parse('<ng-content select="tab"></ng-content>'),
      [
        EmbeddedContent('tab'),
      ],
    );
  });

  test('should parse an embedded content directive with an ngProjectAs', () {
    expect(parse('<ng-content select="foo" ngProjectAs="bar"></ng-content>'), [EmbeddedContent('foo', 'bar')]);
  });

  test('should parse an embedded content directive with a name selector', () {
    expect(parse('<ng-content select="foo" ngProjectAs="bar" #baz></ng-content>'),
        [EmbeddedContent('foo', 'bar', Reference('baz'))]);
  });

  test('should parse a <template> directive', () {
    expect(
      parse('<template></template>'),
      [
        EmbeddedTemplateAst(),
      ],
    );
  });

  test('should parse a <template> directive with attributes', () {
    expect(
      parse('<template ngFor let-item let-i="index"></template>'),
      [
        EmbeddedTemplateAst(attributes: [
          Attribute('ngFor'),
        ], letBindings: [
          LetBinding('item'),
          LetBinding('i', 'index'),
        ]),
      ],
    );
  });

  test('should parse a <template> directive with let-binding and hashref', () {
    expect(
      parse('<template let-foo="bar" let-baz #tempRef></template>'),
      [
        EmbeddedTemplateAst(references: [
          Reference('tempRef'),
        ], letBindings: [
          LetBinding('foo', 'bar'),
          LetBinding('baz'),
        ]),
      ],
    );
  });

  test('should parse a <template> directive with a reference', () {
    expect(
      parse('<template #named ></template>'),
      [
        EmbeddedTemplateAst(
          references: [
            Reference('named'),
          ],
        ),
      ],
    );
  });

  test('should parse a <template> directive with children', () {
    expect(
      parse('<template>Hello World</template>'),
      [
        EmbeddedTemplateAst(
          childNodes: [
            Text('Hello World'),
          ],
        ),
      ],
    );
  });

  test('should parse a structural directive with the * sugar syntax', () {
    expect(
      parse('<div *ngIf="someValue">Hello World</div>'),
      parse('<template [ngIf]="someValue"><div>Hello World</div></template>'),
    );
  });

  test('should handle a microsyntax expression with leading whitespace', () {
    expect(
      parse('<div *ngFor="\n  let item of items">{{item}}</div>'),
      parse('<template ngFor let-item [ngForOf]="items">'
          '<div>{{item}}</div>'
          '</template>'),
    );
  });

  test('should parse a structural directive in child position', () {
    expect(
      parse('<div><div *ngIf="someValue">Hello World</div></div>'),
      parse('<div><template [ngIf]="someValue"><div>Hello World</div></template></div>'),
    );
  });

  test('should parse a structural directive on a container', () {
    expect(
        parse('<ng-container *ngIf="someValue">Hello world</ng-container>'),
        parse('<template [ngIf]="someValue">'
            '<ng-container>Hello world</ng-container>'
            '</template>'));
  });

  test('should parse a void element (implicit)', () {
    expect(
      parse('<input><div></div>'),
      [
        Element('input', null),
        Element('div', CloseElement('div')),
      ],
    );
  });

  test('should parse svg elements as void (explicit) or non void', () {
    expect(
      parse('<path /><path></path>'),
      [
        Element('path', null),
        Element('path', CloseElement('path')),
      ],
    );
  });

  test('should parse an annotation with a value', () {
    expect(parse('<div @foo="bar"></div>'), [
      Element('div', CloseElement('div'), annotations: [
        Annotation('foo', 'bar'),
      ]),
    ]);
  });

  test('should parse an annotation on a container', () {
    expect(parse('<ng-container @annotation></ng-container>'), [
      Container(annotations: [
        Annotation('annotation'),
      ])
    ]);
  });

  test('should parse an annotation on an embedded template', () {
    expect(parse('<template @annotation></template>'), [
      EmbeddedTemplateAst(annotations: [
        Annotation('annotation'),
      ])
    ]);
  });

  test('should include annotation value in source span', () {
    final source = '@foo="bar"';
    final template = '<p $source></p>';
    final ast = parse(template).single as Element;
    final annotation = ast.annotations.single;
    expect(annotation.sourceSpan.text, source);
  });

  test('should parse an annotation with a compound name', () {
    expect(parse('<div @foo.bar></div>'), [
      Element('div', CloseElement('div'), annotations: [
        Annotation('foo.bar'),
      ])
    ]);
  });
}
