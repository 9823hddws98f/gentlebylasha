/// Language of admin-written content (tracks, playlists, pages and rows).
/// LanguageCubit keeps it equal to the app language.
class ContentLanguage {
  ContentLanguage._();

  static String code = 'en';
}

/// The Dutch text when the language is `nl` and the admin filled it in;
/// otherwise the default text.
String localizedContent(String value, String? nl, [String? languageCode]) {
  final language = languageCode ?? ContentLanguage.code;
  if (language == 'nl' && nl != null && nl.trim().isNotEmpty) return nl;
  return value;
}

/// An optional text field of a Firestore document; anything else reads as null.
String? optionalString(Object? value) => value is String ? value : null;
