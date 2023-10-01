class Language {
  final int id;
  final String name;
  final String languageCode;


  Language(this.id, this.name, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1,  "Englisch", "en"),
      Language(2,  "Deutsch", "de"),
    ];
  }
  @override
  bool operator ==(dynamic other) =>
      other != null && other is Language && name == other.name;


  @override
  int get hashCode => super.hashCode;
}