// ignore: directives_ordering, library_prefixes
import 'package:svelte_runtime/src/internal.dart' as $;
import 'package:svelte_runtime/svelte_runtime.dart';
import 'package:web/web.dart';

base class App extends Component {
  static final root2 = $.template<HTMLParagraphElement>('<p> </p>');
  static final root1 = $.template<DocumentFragment>(
    '<h2>Selected files:</h2> <!>',
    1,
  );
  static final root = $.template<DocumentFragment>(
    '<label for="avatar">Upload a picture:</label> <input accept="image/png, image/jpeg" id="avatar" name="avatar" type="file"> <label for="many">Upload multiple files of any type:</label> <input id="many" multiple type="file"> <!>',
    1,
  );

  @override
  void call(Node anchor) {
    $.push();

    var files = state<FileList?>(null);

    $.userEffect<void>(() {
      if (files() != null) {
        // Note that `files` is of type `FileList`, not an Array:
        // https://developer.mozilla.org/en-US/docs/Web/API/FileList
        console.log(files());

        for (var file in JSImmutableListWrapper<FileList, File>(files()!)) {
          print('${file.name}: ${file.size} bytes');
        }
      }
    });

    var fragment = root();
    var input = $.sibling<HTMLInputElement>($.firstChild(fragment), 2);
    var input1 = $.sibling<HTMLInputElement>(input, 4);
    var node = $.sibling<Comment>(input1, 2);

    {
      void consequent(Node anchor) {
        var fragment1 = root1();
        var node1 = $.sibling<Comment>($.firstChild(fragment1), 2);

        $.eachBlock<File>(
          node1,
          17,
          () => JSImmutableListWrapper<FileList, File>(files()!),
          $.index,
          (anchor, file, index) {
            var p = root2();
            var text = $.child<Text>(p);

            $.reset(p);

            $.templateEffect(() {
              $.setText(text, '${file().name} (${file().size} bytes)');
            });

            $.append(anchor, p);
          },
        );

        $.append(anchor, fragment1);
      }

      $.ifBlock(node, (render) {
        if (files() != null) {
          render(consequent);
        }
      });
    }

    $.bindFiles(input, files.call, files.set);
    $.bindFiles(input1, files.call, files.set);
    $.append(anchor, fragment);
    $.pop();
  }
}
