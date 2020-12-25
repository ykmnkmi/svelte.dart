import 'package:jdom/jdom.dart';

void main() {
  final button = document.createElement('button');
  final text = document.createTextNode('click!');
  button.append(text);
  button.addEventListener('click', log.js);
  document.body.append(button);
}

void log(dynamic event) {
  console.log(event);
  print('hehe');
}
