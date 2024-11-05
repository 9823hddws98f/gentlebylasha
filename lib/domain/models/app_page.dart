import 'dart:convert';

class AppPage {
  final String id;
  final String name;
  final int sequence;

  AppPage({
    required this.id,
    required this.name,
    required this.sequence,
  });

  AppPage copyWith({
    String? id,
    String? name,
    int? sequence,
  }) {
    return AppPage(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'sequence': sequence,
    };
  }

  factory AppPage.fromMap(Map<String, dynamic> map) {
    return AppPage(
      id: map['id'] as String,
      name: map['name'] as String,
      sequence: map['sequence'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppPage.fromJson(String source) =>
      AppPage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AppPage(id: $id, name: $name, sequence: $sequence)';

  @override
  bool operator ==(covariant AppPage other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.sequence == sequence;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ sequence.hashCode;
}
