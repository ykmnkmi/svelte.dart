// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App extends ComponentFactory {
  static final root1 = $.template('<label><input type="checkbox"> </label>');
  static final root2 = $.template('<p>Please select at least one flavour</p>');
  static final root4 = $.template(
    "<p>Can't order more flavours than scoops!</p>",
  );
  static final root5 = $.template('<p> </p>');
  static final root = $.template<DocumentFragment>(
    '<h2>Size</h2> <label><input type="radio"> One scoop</label> <label><input type="radio"> Two scoops</label> <label><input type="radio"> Three scoops</label> <h2>Flavours</h2> <!> <!>',
    1,
  );

  @override
  void create(Node anchor) {
    $.push();

    var scoops = $.source<int>(1);
    var flavours = $.source<List<String>>(['Mint choc chip']);

    var menu = <String>[
      'Cookies and cream',
      'Mint choc chip',
      'Raspberry ripple',
    ];

    String join(List<String> flavours) {
      if (flavours.length == 1) {
        return flavours[0];
      }

      return '${flavours.take(flavours.length - 1).join(', ')} and ${flavours.last}';
    }

    var bindingGroup = <HTMLInputElement>[];
    var bindingGroup1 = <HTMLInputElement>[];

    var fragment = root();
    var label = $.sibling<HTMLLabelElement>($.firstChild(fragment), 2);
    var input = $.child<HTMLInputElement>(label);

    $.removeInputDefaults(input);

    $.setElementValue(input, 1);

    $.next();
    $.reset(label);

    var label1 = $.sibling<HTMLLabelElement>(label, 2);
    var input1 = $.child<HTMLInputElement>(label1);

    $.setElementValue(input1, 2);

    $.next();
    $.reset(label1);

    var label2 = $.sibling<HTMLLabelElement>(label1, 2);
    var input2 = $.child<HTMLInputElement>(label2);

    $.setElementValue(input2, 3);

    $.next();
    $.reset(label2);

    var node = $.sibling<Comment>(label2, 4);

    $.eachBlock(node, 17, () => menu, $.index, (anchor, flavour, index) {
      var label3 = root1();
      var input3 = $.child<HTMLInputElement>(label3);

      $.removeInputDefaults(input3);

      String? input3value;
      var text = $.sibling<Text>(input3);

      $.reset(label3);

      $.templateEffect(() {
        if (input3value != (input3value = flavour())) {
          $.setElementValue(input3, flavour());
        }

        $.setText(text, ' ${flavour()}');
      });

      $.bindCheckedGroup<String>(
        bindingGroup1,
        <int>[],
        input3,
        () {
          flavour();
          return flavours();
        },
        (value) {
          flavours.set(value);
        },
      );

      $.append(anchor, label3);
    });

    var node1 = $.sibling<Comment>(node, 2);

    {
      void consequent(Node archon) {
        var p = root2();

        $.append(anchor, p);
      }

      void alternate1(Node anchor) {
        var fragment = $.comment();
        var node2 = $.firstChild<Comment>(fragment);

        {
          void consequent1(Node anchor) {
            var p1 = root4();

            $.append(anchor, p1);
          }

          void alternate(Node anchor) {
            var p2 = root5();
            var text1 = $.child<Text>(p2);

            $.templateEffect(() {
              $.setText(
                text1,
                'You ordered ${scoops()} ${scoops() == 1 ? 'scoop' : 'scoops'} of ${join(flavours())}',
              );
            });

            $.reset(p2);
            $.append(anchor, p2);
          }

          $.ifBlock(node2, (render) {
            if (flavours().length > scoops()) {
              render(consequent1);
            } else {
              render(alternate, false);
            }
          });
        }

        $.append(anchor, fragment);
      }

      $.ifBlock(node1, (render) {
        if (flavours().isEmpty) {
          render(consequent);
        } else {
          render(alternate1, false);
        }
      });
    }

    $.bindRadioGroup<int>(
      bindingGroup,
      <int>[],
      input,
      () {
        1;
        return scoops();
      },
      (value) {
        scoops.set(value);
      },
    );

    $.bindRadioGroup<int>(
      bindingGroup,
      <int>[],
      input1,
      () {
        2;
        return scoops();
      },
      (value) {
        scoops.set(value);
      },
    );

    $.bindRadioGroup<int>(
      bindingGroup,
      <int>[],
      input2,
      () {
        3;
        return scoops();
      },
      (value) {
        scoops.set(value);
      },
    );

    $.append(anchor, fragment);
    $.pop();
  }
}
