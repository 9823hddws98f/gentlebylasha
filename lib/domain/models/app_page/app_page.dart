import 'dart:convert';

import 'app_page_config.dart';

class AppPage {
  final String id;
  final String name;
  final int order;
  final AppPageConfig config;

  AppPage({
    required this.id,
    required this.name,
    required this.order,
    required this.config,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'order': order,
      'config': config.toMap(),
    };
  }

  factory AppPage.fromMap(Map<String, dynamic> map) {
    return AppPage(
      id: map['id'] as String,
      name: map['name'] as String,
      order: map['order'] as int,
      config: AppPageConfig.fromMap(map['config'] as Map<String, dynamic>),
    );
  }

  factory AppPage.fromJson(String source) =>
      AppPage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AppPage(id: $id, name: $name, order: $order, config: $config)';

  @override
  bool operator ==(covariant AppPage other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.order == order &&
        other.config == config;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ order.hashCode ^ config.hashCode;
}
