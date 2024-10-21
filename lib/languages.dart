class Language {
  final int id;
  final String name;
  final String languageCode;

  Language(this.id, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, "Englisch", "en"),
      Language(2, "Deutsch", "de"),
    ];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ languageCode.hashCode;
}
