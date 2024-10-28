import 'dart:async';

import 'package:animations/animations.dart';
import 'package:carbon_icons/carbon_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/models/category_block.dart';
import '/screens/home/category_list.dart';
import '/screens/tabs_subcategory_screen.dart';
import '/utils/app_theme.dart';
import '/utils/global_functions.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/search_list_item.dart';
import '/widgets/shared_axis_switcher.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final firestore = FirebaseFirestore.instance;

  static const _searchSuggestions = [
    'Happiness',
    'Anxiety',
    'Rain',
    'Soundscapes',
    'Sleep',
    'Meditations'
  ];

  final _searchFocusNode = FocusNode();
  final _controller = TextEditingController();

  int? _selectedTabIndex;

  late TabController _tabController;

  List<CategoryBlock> _categories = [];

  String get _searchText => _controller.text;

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(() {
      setState(() {});
    });

    // Add a listener to indexNotifier
    indexNotifier.addListener(() {
      int newIndex = indexNotifier.value;

      _tabController.animateTo(newIndex);
    });
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: false,
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: 'Explore',
        ),
        bodyPadding: EdgeInsets.zero,
        body: (context, isMobile) {
          final colors = Theme.of(context).colorScheme;
          return NestedScrollView(
              headerSliverBuilder: (context, value) => [
                    _buildSearchbar(colors.outline),
                    _buildCategoriesList(),
                  ],
              body: SharedAxisSwitcher(
                disableFillColor: true,
                transitionType: SharedAxisTransitionType.scaled,
                child: _searchFocusNode.hasFocus
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (_searchText.isEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
                                child: Text(
                                  "Popular",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: 5,
                                itemBuilder: (context, index) => ListTile(
                                  title: Text(_searchSuggestions[index]),
                                  onTap: () =>
                                      _controller.text = _searchSuggestions[index],
                                ),
                              ),
                            ),
                          ],
                          if (_searchText.isNotEmpty)
                            StreamBuilder<List<DocumentSnapshot>>(
                              stream: searchTracksNew(_searchText),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(color: Colors.white),
                                  );
                                } else if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.data == null) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Text(
                                      "Couldn't find $_searchText",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }

                                if (snapshot.data != null) {
                                  return Expanded(
                                    child: ListView(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.fromLTRB(16, 16, 16, 165),
                                      children: snapshot.data!.map((document) {
                                        AudioTrack track =
                                            AudioTrack.fromFirestore(document);
                                        return SearchListItem(
                                          imageUrl: track.thumbnail,
                                          mp3Name: track.title,
                                          mp3Category: track.categories.isNotEmpty
                                              ? track.categories[0].categoryName
                                              : '',
                                          mp3Duration: track.length,
                                          speaker: track.speaker,
                                          onPress: () {
                                            playTrack(track);
                                            // TODO: widget.panelFunction(false);
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Text(
                                      "Couldn't find $_searchText",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }
                              },
                            )
                        ],
                      )
                    : _categories.isEmpty
                        ? Placeholder()
                        : TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: _tabController,
                            children: _categories
                                .map((category) => TabsSubCategoryScreen(
                                      category,
                                      key: ValueKey(category.id),
                                    ))
                                .toList(),
                          ),
              ));
        },
      );

  Widget _buildCategoriesList() => SliverAppBar(
        pinned: true,
        toolbarHeight: 72,
        title: Column(
          children: [
            CategoryList(
              selectedTabIndex: _selectedTabIndex,
              onLoad: (items) => setState(() {
                _tabController = TabController(length: items.length, vsync: this);
                _categories = items;
              }),
              onTap: (categoryBlock) {
                _tabController.animateTo(_categories.indexOf(categoryBlock));
                setState(() {
                  _selectedTabIndex = _categories.indexOf(categoryBlock);
                });
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      );

  Widget _buildSearchbar(Color outlineColor) => SliverAppBar(
        floating: true,
        toolbarHeight: 72,
        titleSpacing: AppTheme.sidePadding,
        title: TextFormField(
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            prefixIcon: Icon(CarbonIcons.search),
            hintText: 'Search',
            border: OutlineInputBorder(borderRadius: AppTheme.smallBorderRadius),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.smallBorderRadius,
              borderSide: BorderSide(color: outlineColor),
            ),
          ),
          controller: _controller,
        ),
      );

  Stream<List<DocumentSnapshot>> searchTracksNew(String query) {
    final CollectionReference tracksCollection =
        FirebaseFirestore.instance.collection('Tracks');
    final normalizedQuery = query.toLowerCase();

    final StreamController<List<DocumentSnapshot>> controller =
        StreamController<List<DocumentSnapshot>>();

    void processQuerySnapshot(Stream<QuerySnapshot> queryStream) {
      queryStream.listen((snapshot) async {
        debugPrint('Query returned ${snapshot.docs.length} documents');

        // Filter documents locally for case-insensitive matching
        final filteredDocs = snapshot.docs.where((doc) {
          final title =
              (doc.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ??
                  '';
          return title.contains(normalizedQuery);
        }).toList();

        if (filteredDocs.isNotEmpty) {
          // Emit the filtered documents
          controller.add(filteredDocs);
        } else {
          // If no title matches, perform the speaker query
          final speakerSnapshot = await tracksCollection
              .where('speaker',
                  isGreaterThanOrEqualTo: query.substring(0, 1).toUpperCase())
              .where('speaker',
                  isLessThanOrEqualTo: '${query.substring(0, 1).toUpperCase()}\uf8ff')
              .get();

          debugPrint('Speaker query returned ${speakerSnapshot.docs.length} documents');

          // Emit speaker query results
          controller.add(speakerSnapshot.docs);
        }
      });
    }

    // Check for categories and handle category-based queries
    if (_categories.isNotEmpty) {
      final matchedCategory = _categories.firstWhereOrNull(
        (category) => category.name.toLowerCase().contains(normalizedQuery),
      );

      if (matchedCategory != null) {
        final categoryStream = tracksCollection
            .where('categories', arrayContains: matchedCategory.id)
            .snapshots();
        return categoryStream.map((snapshot) => snapshot.docs);
      }
    }

    // Perform the query on the title field and handle results
    final titleStream = tracksCollection
        .where('title', isGreaterThanOrEqualTo: query.substring(0, 1).toUpperCase())
        .where('title',
            isLessThanOrEqualTo: '${query.substring(0, 1).toUpperCase()}\uf8ff')
        .snapshots();

    processQuerySnapshot(titleStream);

    return controller.stream;
  }
}
