
class Categories{
  final String id;
  final String categoryName;

  Categories({required this.id, required this.categoryName});

  // Convert the model to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryName': categoryName,
    };
  }

  // Create a model object from a map
  factory Categories.fromMap(Map<String, dynamic> map) {
    return Categories(
      id: map['id'],
      categoryName: map['categoryName'],
    );
  }

}