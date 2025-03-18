// ignore: library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class CustomButton extends Component {
  static final root = $.template<HTMLButtonElement>(
    '<button class="svelte-hg07jm">Click me</button>',
  );

  CustomButton({required this.onClick});

  void Function(Event event) onClick;

  @override
  void call(Node anchor) {
    $.appendStyles(anchor, 'svelte-hg07jm', '''
  button {
    height: 4rem;
    width: 8rem;
    background-color: #aaa;
    border-color: #f1c40f;
    color: #f1c40f;
    font-size: 1.25rem;
    background-image: linear-gradient(45deg, #f1c40f 50%, transparent 50%);
    background-position: 100%;
    background-size: 400%;
    transition: background 300ms ease-in-out;
  }

  button:hover {
    background-position: 0;
    color: #aaa;
  }''');

    var button = root();

    $.event<Event>('click', button, onClick);
    $.append(anchor, button);
  }
}
