// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root1 = $.template<HTMLOptionElement>('<option> </option>');
  static final root = $.template<DocumentFragment>(
    '<h2>Insecurity questions</h2> <form><select></select> <input class="svelte-14lf6jh"> <button type="submit">Submit</button></form> <p> </p>',
    1,
  );

  @override
  void call(Node anchor) {
    $.appendStyles(anchor, 'svelte-14lf6jh', '''
  input.svelte-14lf6jh {
    display:block;
    width:500px;
    max-width:100%;
  }''');

    var questions = [
      (id: 1, text: 'Where did you go to school?'),
      (id: 2, text: "What is your mother's name?"),
      (
        id: 3,
        text:
            'What is another personal fact that an attacker could easily find with Google?',
      ),
    ];

    var selected = state<({int id, String text})?>(null);
    var answer = state<String>('');

    void handleSubmit(Event event) {
      event.preventDefault();
      window.alert(
        'Answered question ${selected()!.id} ${selected()!.text} with "${answer()}".',
      );
    }

    var fragment = root();
    var form = $.sibling<HTMLFormElement>($.firstChild(fragment), 2);
    var select = $.child<HTMLSelectElement>(form);

    $.eachBlock(select, 21, () => questions, $.index, (
      anchor,
      question,
      index,
    ) {
      var option = root1();
      var option_value = () as Object?;
      var text = $.child<Text>(option, true);

      $.reset(option);

      $.templateEffect(() {
        if (option_value != (option_value = question())) {
          $.setElementValue(option, option_value);
        }

        $.setText(text, question().text);
      });

      $.append(anchor, option);
    });

    $.reset(select);

    var input = $.sibling<HTMLInputElement>(select, 2);

    $.removeInputDefaults(input);

    var button = $.sibling<HTMLButtonElement>(input, 2);

    $.reset(form);

    var p = $.sibling<HTMLParagraphElement>(form, 2);
    var text1 = $.child<Text>(p);

    $.reset(p);

    $.templateEffect(() {
      button.disabled = answer().isEmpty;
      $.setText(
        text1,
        'selected question ${selected() != null ? selected()!.id : '[waiting...]'}',
      );
    });

    $.bindSelectValue(select, selected.call, (value) {
      selected.set(value as ({int id, String text})?);
    });

    $.event0('change', select, () => answer.set(''));

    $.bindValue(input, answer.call, (value) {
      answer.set(value as String);
    });

    $.event<Event>('submit', form, handleSubmit);
    $.append(anchor, fragment);
  }
}
