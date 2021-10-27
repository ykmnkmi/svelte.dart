import 'package:test/test.dart';
import 'package:angular_ast/angular_ast.dart';

const HumanizingTemplateAstVisitor humanizer = HumanizingTemplateAstVisitor();

void main() {
  group('Humanizing', () {
    test('should humanize a simple template and preserve inner spaces', () {
      var templateString = '<button [title]="aTitle">Hello {{name}}</button>';
      var nodes = parse(templateString, sourceUrl: '/test/visitor_test.dart#inline');
      expect(nodes.map((node) => node.accept(humanizer)).join(''), equals(templateString));
    });

    test('should humanize a simple template *with* de-sugaring applied', () {
      var nodes = parse('<widget *ngIf="someValue" [(value)]="value"></widget>',
          sourceUrl: '/test/visitor_test.dart#inline', desugar: true);
      expect(nodes.map((node) => node.accept(humanizer)).join(''), equalsIgnoringWhitespace(r'''
        <template [ngIf]="someValue"><widget (valueChange)="value = $event" [value]="value"></widget></template>
      '''));
    });
  });
}
