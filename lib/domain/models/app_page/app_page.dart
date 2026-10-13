import 'dart:convert';

import '/utils/localized_content.dart';
import 'app_page_config.dart';

class AppPage {
  final String id;
  final String _name;

  /// Dutch name; shown when the app is in Dutch and it is filled in.
  final String? nameNl;
  final int order;
  final AppPageConfig config;

  /// Name in the app language.
  String get name => localizedContent(_name, nameNl);

  AppPage({
    required this.id,
    required String name,
    this.nameNl,
    required this.order,
    required this.config,
  }) : _name = name;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': _name,
      if (nameNl != null) 'nameNl': nameNl,
      'order': order,
      'config': config.toMap(),
    };
  }

  factory AppPage.fromMap(Map<String, dynamic> map) {
    return AppPage(
      id: map['id'] as String,
      name: map['name'] as String,
      nameNl: optionalString(map['nameNl']),
      order: map['order'] as int,
      config: AppPageConfig.fromMap(map['config'] as Map<String, dynamic>),
    );
  }

  factory AppPage.fromJson(String source) =>
      AppPage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AppPage(id: $id, name: $_name, nameNl: $nameNl, order: $order, config: $config)';

  // Pages are map keys (PagesState), so equality uses the stored fields, not
  // the name in the current language.
  @override
  bool operator ==(covariant AppPage other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other._name == _name &&
        other.nameNl == nameNl &&
        other.order == order &&
        other.config == config;
  }

  @override
  int get hashCode => id.hashCode ^ _name.hashCode ^ order.hashCode ^ config.hashCode;
}
