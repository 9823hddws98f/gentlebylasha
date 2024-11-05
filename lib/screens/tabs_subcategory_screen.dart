import 'package:flutter/material.dart';

import '/domain/models/app_page.dart';
import '/domain/models/block/block.dart';
import '/utils/tx_loader.dart';
import 'home/track_block_loader.dart';

class TabsCategoryScreen extends StatefulWidget {
  const TabsCategoryScreen(this.category, {super.key});

  final AppPage category;

  @override
  State<TabsCategoryScreen> createState() => _TabsCategoryScreen();
}

class _TabsCategoryScreen extends State<TabsCategoryScreen> {
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
          itemBuilder: (context, index) => TrackBlockLoader.shimmer(BlockType.normal),
        )
      : ListView.builder(
          itemCount: _blockList.length,
          padding: EdgeInsets.only(bottom: 150),
          itemBuilder: (context, index) => TrackBlockLoader(_blockList[index]),
        );

  Future<void> _getPageBlocks() async {
    // _txLoader.load(
    //   () => getBlocksOfCategory(widget.category.id),
    //   ensure: () => mounted,
    //   onSuccess: (blocks) => setState(() => _blockList = blocks),
    // );
  }
}
