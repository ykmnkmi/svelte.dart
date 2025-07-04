import 'package:markdown/markdown.dart' show markdownToHtml;
// ignore: library_prefixes
import 'package:svelte/src/internal.dart' as $;
import 'package:svelte/svelte.dart';
import 'package:web/web.dart';

base class App implements Component {
  static final root = $.template<DocumentFragment>(
    '<textarea class="svelte-edipxk"></textarea> <!>',
    1,
  );

  @override
  void create(Node anchor) {
    $.push();
    $.appendStyles(anchor, 'svelte-edipxk', '''
  textarea.svelte-edipxk {
    width:100%;
    height:200px;
  }''');

    var text = $.source<String>('Some words are *italic*, some are **bold**');

    var fragment = root();
    var textarea = $.firstChild<HTMLTextAreaElement>(fragment);

    $.removeTextAreaChild(textarea);

    var node = $.sibling<Comment>(textarea, 2);

    $.html(node, () => markdownToHtml(text(), inlineOnly: true), false, false);

    $.bindValue(textarea, text.call, (value) {
      text.set(value as String);
    });

    $.append(anchor, fragment);
    $.pop();
  }
}
