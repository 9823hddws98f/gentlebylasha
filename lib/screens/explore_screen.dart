import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '/screens/tabs_subcategory_screen.dart';
import '/utils/firestore_helper.dart';
import '/widgets/search_list_item.dart';
import '../domain/models/audiofile_model.dart';
import '../domain/models/category_block.dart';
import '../utils/colors.dart';
import '../utils/global_functions.dart';
import '../widgets/custom_tab_button.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  bool _showSearchList = false;
  late TabController tabController;
  final TextEditingController _controller = TextEditingController();
  String searchText = "";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final list = ['Happiness', 'Anxiety', 'Rain', 'Soundscapes', 'Sleep', 'Meditations'];
  List<CategoryBlock> categories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColorOne,
              gradientColorTwo,
            ],
            stops: [0.0926, 1.0],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              "Explore",
              style: TextStyle(fontSize: 20),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 30, 16, 5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Title, narrator, genre',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white54,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _showSearchList = true;
                          });
                        },
                        controller: _controller,
                        onChanged: (value) {
                          setState(() {
                            _showSearchList = value.isNotEmpty;
                            searchText = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showSearchList) ...[
              if (searchText.isEmpty) ...[
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
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(list[index], style: TextStyle(color: Colors.white)),
                        onTap: () {
                          setState(() {
                            _controller.text = list[index];
                            searchText = list[index];
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
              if (searchText.isNotEmpty)
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: searchTracksNew(searchText),
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
                    } else if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data == null) {
                      return Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text(
                          "Couldn't find $searchText",
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
                            AudioTrack track = AudioTrack.fromFirestore(document);
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
                          "Couldn't find $searchText",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                )
            ],
            if (!_showSearchList)
              if (categories.isNotEmpty) ...[
                SizedBox(
                  height: 50, // adjust the height as needed
                  child: TabBar(
                    padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.all(5),
                    indicatorColor: Colors.transparent,
                    controller: tabController,
                    isScrollable: true,
                    tabs: List<Widget>.generate(
                      categories.length > 8 ? 8 : categories.length,
                      (int index) {
                        return CustomTabButton(
                          title: categories[index].name,
                          onPress: () {
                            tabController.animateTo(index);
                            setState(() {});
                          },
                          color: tabController.index == index
                              ? tabSelectedColor
                              : tabUnselectedColor,
                          textColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: List<Widget>.generate(
                      categories.length > 8 ? 8 : categories.length,
                      (int index) {
                        return TabsSubCategoryScreen(categories[index], () {
                          // TODO:      widget.panelFunction,
                        });
                      },
                    ),
                  ),
                ),
              ]
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCategoriesList();
    tabController = TabController(length: 0, vsync: this);

    // Add a listener to indexNotifier
    indexNotifier.addListener(() {
      int newIndex = indexNotifier.value;

      tabController.animateTo(newIndex);
    });
  }

  void _updateTabControllerLength(int newLength) {
    setState(() {
      tabController = TabController(length: newLength, vsync: this);
    });
    tabController.addListener(() {
      setState(() {});
    });
  }

  void getCategoriesList() async {
    categories = await getCategoryBlocks();
    if (categories.isNotEmpty) {
      _updateTabControllerLength(categories.length);
    }
    setState(() {});
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // Stream<QuerySnapshot> searchTracks(String query) {
  //   return firestore
  //       .collection('Tracks')
  //       .where('categories', arrayContains: query)
  //       .snapshots();
  // }

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
    if (categories.isNotEmpty) {
      final matchedCategory = categories.firstWhereOrNull(
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
