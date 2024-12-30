final class Component {
  const Component({
    required this.tag,
    this.template,
    this.templateUrl,
  });

  final String tag;

  final String? template;

  final String? templateUrl;
}
