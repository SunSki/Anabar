import 'package:meta/meta.dart';

class Pref {
  final String name;
  final String code;

  const Pref({
    @required this.name,
    @required this.code,
  })  : assert(name != null),
        assert(code != null);
}
