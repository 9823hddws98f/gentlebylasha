import 'package:cloud_firestore/cloud_firestore.dart';

class SubCategory {
  final String subCategoryID;
  final String categoryID;
  final String name;

  SubCategory({required this.subCategoryID,required this.categoryID, required this.name});

  factory SubCategory.fromFirestore(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String subCategoryID = document.id;
    String categoryID = data['category_id'];
    String name = data['name'];
    return SubCategory(subCategoryID:subCategoryID,categoryID: categoryID, name: name);
  }
}
