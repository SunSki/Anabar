import 'package:meta/meta.dart';

class Unit {
  final String name;
  final String imageUrl;
  final String address;
  final String opentime;
  final String pr;

  const Unit({
    @required this.name,
    @required this.imageUrl,
    @required this.address,
    @required this.opentime,
    @required this.pr,
  })  : assert(name != null),
        assert(imageUrl != null),
        assert(address != null),
        assert(opentime != null),
        assert(pr != null);
}
