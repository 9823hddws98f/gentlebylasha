
class UserModel{
  String? id;
  String? name;
  String? email;
  String? language;
  String? heardFrom;
  List<dynamic>? goals;
  String? photoURL;


  UserModel({
    this.id,
    this.email,
    this.language,
    this.name,
    this.goals,
    this.heardFrom,
    this.photoURL,
  });
}