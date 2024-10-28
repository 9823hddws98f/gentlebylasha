import 'package:flutter/material.dart';

import '/domain/models/block.dart';
import '/domain/models/category_block.dart';
import '/utils/firestore_helper.dart';
import '/utils/tx_loader.dart';
import 'home/track_block_loader.dart';

class TabsSubCategoryScreen extends StatefulWidget {
  const TabsSubCategoryScreen(this.category, {super.key});

  final CategoryBlock category;

  @override
  State<TabsSubCategoryScreen> createState() => _TabsSubCategoryScreen();
}

class _TabsSubCategoryScreen extends State<TabsSubCategoryScreen> {
  final _txLoader = TxLoader();

  List<Block> _blockList = [];

  @override
  void initState() {
    super.initState();
    _getPageBlocks();
  }

  @override
  Widget build(BuildContext context) => _txLoader.loading
      ? ListView.builder(
          key: ValueKey('shimmer'),
          itemCount: 3,
          itemBuilder: (context, index) => TrackBlockLoader.shimmer(),
        )
      : ListView.builder(
          itemCount: _blockList.length,
          padding: EdgeInsets.only(bottom: 150),
          itemBuilder: (context, index) => TrackBlockLoader(_blockList[index]),
        );

  Future<void> _getPageBlocks() async {
    _txLoader.load(
      () => getBlockOfCategory(widget.category.id),
      ensure: () => mounted,
      onSuccess: (blocks) => setState(() => _blockList = blocks),
    );
  }
}
