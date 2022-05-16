import 'package:html_unescape/html_unescape.dart';

void main() {
  print(HtmlUnescape().convert('semi:&quot;space:&quot letter:&quote number:&quot1 end:&quot'));
}
