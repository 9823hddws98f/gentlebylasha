import 'package:bloc/bloc.dart';

import '/domain/models/app_page/app_page.dart';
import '/domain/models/block/block.dart';
import '/domain/services/blocks_service.dart';
import '/domain/services/pages_service.dart';

part 'pages_state.dart';

class PagesCubit extends Cubit<PagesState> {
  final _pagesService = PagesService();
  final _blocksService = BlocksService();

  PagesCubit._() : super(PagesInitial());

  static final PagesCubit instance = PagesCubit._();

  Future<void> init() async {
    final pages = await _pagesService.getAll()
      ..sort((a, b) => a.order.compareTo(b.order));
    final blockSkeletons = await _blocksService.getAll();

    emit(state.copyWith(pages: {
      for (final page in pages)
        page: blockSkeletons.where((block) => block.pageId == page.id).toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence)),
    }));
  }
}
