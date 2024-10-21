class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? language;
  final String? heardFrom;
  final List<dynamic>? goals;
  final String? photoURL;

  const UserModel({
    this.id,
    this.email,
    this.language,
    this.name,
    this.goals,
    this.heardFrom,
    this.photoURL,
  });
}
