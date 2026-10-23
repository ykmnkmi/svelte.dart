import 'package:svelte/svelte.dart';

final class Task {
  Task(String text, bool done)
    : text = state<String>(text),
      done = state<bool>(done);

  State<String> text;

  State<bool> done;
}
