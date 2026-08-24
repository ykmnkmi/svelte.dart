import 'package:svelte/svelte.dart';

final class User {
  User({required bool loggedIn}) : _loggedIn = state<bool>(loggedIn);

  final State<bool> _loggedIn;

  bool get loggedIn => _loggedIn();

  set loggedIn(bool value) {
    _loggedIn.set(value);
  }
}
