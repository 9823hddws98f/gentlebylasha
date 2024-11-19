import 'dart:convert';

class AppPage {
  final String id;
  final String name;
  final int order;

  AppPage({
    required this.id,
    required this.name,
    required this.order,
  });

  AppPage copyWith({
    String? id,
    String? name,
    int? order,
  }) {
    return AppPage(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'order': order,
    };
  }

  factory AppPage.fromMap(Map<String, dynamic> map) {
    return AppPage(
      id: map['id'] as String,
      name: map['name'] as String,
      order: map['order'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppPage.fromJson(String source) =>
      AppPage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AppPage(id: $id, name: $name, order: $order)';

  @override
  bool operator ==(covariant AppPage other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.order == order;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ order.hashCode;
}
