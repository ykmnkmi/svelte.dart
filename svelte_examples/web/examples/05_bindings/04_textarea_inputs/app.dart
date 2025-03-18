import 'package:markdown/markdown.dart' show markdownToHtml;
// ignore: directives_ordering, library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root = $.template<DocumentFragment>(
    '<textarea class="svelte-edipxk"></textarea> <!>',
    1,
  );

  @override
  void call(Node anchor) {
    $.push();
    $.appendStyles(anchor, 'svelte-edipxk', '''
  textarea.svelte-edipxk {
    width:100%;
    height:200px;
  }''');

    var text = state<String>('Some words are *italic*, some are **bold**');

    var fragment = root();
    var textarea = $.firstChild<HTMLTextAreaElement>(fragment);

    $.removeTextAreaChild(textarea);

    var node = $.sibling<Comment>(textarea, 2);

    $.html(node, () => markdownToHtml(text(), inlineOnly: true), false, false);
    $.bindValueState<String>(textarea, text);
    $.append(anchor, fragment);
    $.pop();
  }
}
