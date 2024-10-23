import 'package:get_it/get_it.dart';

class Get {
  static T the<T extends Object>() => GetIt.I<T>();
}
