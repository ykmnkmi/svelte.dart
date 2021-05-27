import 'package:piko/runtime.dart';

class App extends Component<App> {
  App({this.count = 0});

  int count;

  void handleClick() {
    count += 1;
  }

  @override
  Fragment<App> render(RenderTree tree) {
    throw UnimplementedError();
  }
}
