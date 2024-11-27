class AppPageConfig {
  final bool showItemDurations;

  AppPageConfig({required this.showItemDurations});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showItemDurations': showItemDurations,
    };
  }

  factory AppPageConfig.fromMap(Map<String, dynamic> map) {
    return AppPageConfig(
      showItemDurations: map['showItemDurations'] as bool,
    );
  }
}
