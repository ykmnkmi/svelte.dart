// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class Keypad implements Component {
  static final root = $.template<HTMLDivElement>(
    '<div class="keypad svelte-1iljj4z"><button class="svelte-1iljj4z">1</button> <button class="svelte-1iljj4z">2</button> <button class="svelte-1iljj4z">3</button> <button class="svelte-1iljj4z">4</button> <button class="svelte-1iljj4z">5</button> <button class="svelte-1iljj4z">6</button> <button class="svelte-1iljj4z">7</button> <button class="svelte-1iljj4z">8</button> <button class="svelte-1iljj4z">9</button> <button class="svelte-1iljj4z">clear</button> <button class="svelte-1iljj4z">0</button> <button class="svelte-1iljj4z">submit</button></div>',
  );

  Keypad({this.value = '', this.onSubmit});

  String value;

  void Function()? onSubmit;

  @override
  void create(Node anchor) {
    $.appendStyles(anchor, 'svelte-1iljj4z', '''
  .keypad.svelte-1iljj4z {
    display: grid;
    grid-template-columns: repeat(3, 5em);
    grid-template-rows: repeat(4, 3em);
    grid-gap: 0.5em;
  }

  button.svelte-1iljj4z {
    margin: 0;
  }''');

    void Function() select(String num) {
      return () {
        value += num;
      };
    }

    void clear() {
      value = '';
    }

    var div = root();
    var button = $.child<HTMLButtonElement>(div);
    var eventHandler = $.derived(() => select('1'));
    var button1 = $.sibling<HTMLButtonElement>(button, 2);
    var eventHandler1 = $.derived(() => select('2'));
    var button2 = $.sibling<HTMLButtonElement>(button1, 2);
    var eventHandler2 = $.derived(() => select('3'));
    var button3 = $.sibling<HTMLButtonElement>(button2, 2);
    var eventHandler3 = $.derived(() => select('4'));
    var button4 = $.sibling<HTMLButtonElement>(button3, 2);
    var eventHandler4 = $.derived(() => select('5'));
    var button5 = $.sibling<HTMLButtonElement>(button4, 2);
    var eventHandler5 = $.derived(() => select('6'));
    var button6 = $.sibling<HTMLButtonElement>(button5, 2);
    var eventHandler6 = $.derived(() => select('7'));
    var button7 = $.sibling<HTMLButtonElement>(button6, 2);
    var eventHandler7 = $.derived(() => select('8'));
    var button8 = $.sibling<HTMLButtonElement>(button7, 2);
    var eventHandler8 = $.derived(() => select('9'));
    var button9 = $.sibling<HTMLButtonElement>(button8, 2);
    var button10 = $.sibling<HTMLButtonElement>(button9, 2);
    var eventHandler9 = $.derived(() => select('0'));
    var button11 = $.sibling<HTMLButtonElement>(button10, 2);

    $.reset(div);

    $.templateEffect(() {
      button9.disabled = value.isEmpty;
      button11.disabled = value.isEmpty;
    });

    $.eventVoid('click', button, () {
      eventHandler()();
    });

    $.eventVoid('click', button1, () {
      eventHandler1()();
    });

    $.eventVoid('click', button2, () {
      eventHandler2()();
    });

    $.eventVoid('click', button3, () {
      eventHandler3()();
    });

    $.eventVoid('click', button4, () {
      eventHandler4()();
    });

    $.eventVoid('click', button5, () {
      eventHandler5()();
    });

    $.eventVoid('click', button6, () {
      eventHandler6()();
    });

    $.eventVoid('click', button7, () {
      eventHandler7()();
    });

    $.eventVoid('click', button8, () {
      eventHandler8()();
    });

    $.eventVoid('click', button9, clear);

    $.eventVoid('click', button10, () {
      eventHandler9()();
    });

    $.eventVoid('click', button11, () {
      onSubmit?.call();
    });

    $.append(anchor, div);
  }
}
