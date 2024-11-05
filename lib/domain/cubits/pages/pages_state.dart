part of 'pages_cubit.dart';

class PagesState {
  final Map<AppPage, List<Block>> pages;

  Map<AppPage, List<Block>> get explorePages => Map.fromEntries(pages.entries.skip(1));

  const PagesState({required this.pages});

  PagesState copyWith({
    Map<AppPage, List<Block>>? pages,
  }) =>
      PagesState(pages: pages ?? this.pages);
}

final class PagesInitial extends PagesState {
  PagesInitial() : super(pages: {});
}
