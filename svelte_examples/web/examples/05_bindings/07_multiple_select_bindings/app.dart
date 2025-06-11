// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:web/web.dart';

base class App extends $.Component {
  static final root1 = $.template<HTMLOptionElement>('<option> </option>');
  static final root2 = $.template<HTMLParagraphElement>(
    '<p>Please select at least one flavour</p>',
  );
  static final root4 = $.template<HTMLParagraphElement>(
    "<p>Can't order more flavours than scoops!</p>",
  );
  static final root5 = $.template<HTMLParagraphElement>('<p> </p>');
  static final root = $.template<DocumentFragment>(
    '<h2>Size</h2> <label><input type="radio"> One scoop</label> <label><input type="radio"> Two scoops</label> <label><input type="radio"> Three scoops</label> <h2>Flavours</h2> <select multiple></select> <!>',
    1,
  );

  @override
  void call(Node anchor) {
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

    var select = $.sibling<HTMLSelectElement>(label2, 4);

    $.eachBlock(select, 21, () => menu, $.index, (anchor, flavour, index) {
      var option = root1();
      var optionValue = null as String?;
      var text = $.child<Text>(option, true);

      $.reset(option);

      $.templateEffect(() {
        if (optionValue != (optionValue = flavour())) {
          $.setElementValue(option, flavour());
        }

        $.setText(text, flavour());
      });

      $.append(anchor, option);
    });

    $.reset(select);

    var node = $.sibling<Comment>(select, 2);

    {
      void consequent(Node archon) {
        var p = root2();

        $.append(anchor, p);
      }

      void alternate1(Node anchor) {
        var fragment1 = $.comment();
        var node1 = $.firstChild<Comment>(fragment1);

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

          $.ifBlock(node1, (render) {
            if (flavours().length > scoops()) {
              render(consequent1);
            } else {
              render(alternate, false);
            }
          }, true);
        }

        $.append(anchor, fragment1);
      }

      $.ifBlock(node, (render) {
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

    $.bindSelectValue(select, flavours.call, (value) {
      flavours.set((value as List).cast<String>());
    });

    $.append(anchor, fragment);
    $.pop();
  }
}
