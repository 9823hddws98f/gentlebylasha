import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryBlock{
  final String id;
  final String name;
  final int sequence;


  CategoryBlock({required this.id, required this.name,required this.sequence});

  // Convert the model to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sequence':sequence
    };
  }

  // Create a model object from a map
  factory CategoryBlock.fromMap(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CategoryBlock(
      id: doc.id,
      name: data['name'],
      sequence: data['sequence'],
    );
  }

}
