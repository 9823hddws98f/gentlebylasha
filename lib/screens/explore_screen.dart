import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/models/audiofile_model.dart';
import 'package:sleeptales/models/category_block.dart';
import 'package:sleeptales/screens/music_player_screen.dart';
import 'package:sleeptales/screens/tabs_subcategory_screen.dart';
import 'package:sleeptales/utils/firestore_helper.dart';
import 'package:sleeptales/widgets/search_list_item.dart';
import '../utils/colors.dart';
import '../utils/global_functions.dart';
import '../widgets/custom_tab_button.dart';

class ExploreScreen extends StatefulWidget {
  final Function panelFunction;

  const ExploreScreen(this.panelFunction,{super.key});
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  bool _showSearchList = false;
  late TabController tabController;
  final TextEditingController _controller = TextEditingController();
  String searchText = "";
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final list = ['Happiness', 'Anxiety', 'Rain','Soundscapes','Sleep','Meditations'];
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
            SizedBox(height: 50.h,),
            Text("Explore",style: TextStyle(fontSize: 20.sp),),
            Container(
              padding: EdgeInsets.fromLTRB(16.w,30.h,16.w,5.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8.h),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Title, narrator, genre',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search,color: Colors.white54,),
                        ),
                        onTap: (){
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
            if (_showSearchList)...[
              if(searchText.isEmpty)...[
             Align(
               alignment: Alignment.centerLeft,
               child: Padding(
                 padding: EdgeInsets.fromLTRB(16.w, 10.h, 0, 0),
               child:Text("Popular",textAlign: TextAlign.start,style: TextStyle(fontSize: 22.sp),) ,
           ),
             ),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${list[index]}'),
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

              if(searchText.isNotEmpty)
              StreamBuilder<QuerySnapshot>(
                stream: searchTracksNew(searchText),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(padding: EdgeInsets.all(16.h),
                    child:CircularProgressIndicator(color: Colors.white,),
                    );
                  }else if(snapshot.connectionState == ConnectionState.done && snapshot.data == null){
                    return Padding(padding: EdgeInsets.only(top: 30.h),
                    child: Text("Couldn't found $searchText",style: TextStyle(color: Colors.white),
                    ));
                  }


                  if(snapshot.data != null) {
                    return Expanded(child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(16.w,16.w,16.w,165.h),
                      children: snapshot.data!.docs.map((
                          DocumentSnapshot document) {
                        AudioTrack track = AudioTrack.fromFirestore(document);
                        return SearchListItem(
                            imageUrl: track.thumbnail ?? '',
                            mp3Name: track.title ?? '',
                            mp3Category:track.categories[0].categoryName ?? '',
                            mp3Duration: track.length ?? '',
                            speaker: track.speaker,
                            onPress: (){
                              playTrack(track);
                              widget.panelFunction(false);
                             // Navigator.of(context).push( SlideFromBottomPageRoute(page: MusicPlayerScreen(playList: false,)));
                            });


                      }).toList(),
                   ),

                    );
                  }else{
                    return Padding(padding: EdgeInsets.only(top: 30.h),
                        child: Text("Couldn't found $searchText",style: TextStyle(color: Colors.white),
                        ));
                  }
                },
              )

              ],
            if (!_showSearchList)
              if(categories.isNotEmpty)...[
              SizedBox(
                height: 50.h, // adjust the height as needed
                child: TabBar(
                  padding: EdgeInsets.zero,
                  indicatorPadding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.all(5.w),
                  indicatorColor: Colors.transparent,
                  controller: tabController,
                  isScrollable: true,
                  tabs: List<Widget>.generate(
                    categories.length>8?8:categories.length,
                        (int index) {
                      return CustomTabButton(
                        title: categories[index].name,
                        onPress: () {
                          tabController.animateTo(index);
                          setState(() {
                          });
                        },
                        color: tabController.index == index ? tabSelectedColor : tabUnselectedColor,
                        textColor: Colors.white,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                controller: tabController,
                  children:
                    List<Widget>.generate(
                      categories.length>8?8:categories.length,
                          (int index) {
                          return TabsSubCategoryScreen(categories[index],widget.panelFunction);
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
      setState(() {

      });
    });
  }

  void getCategoriesList() async{
      categories = await getCategoryBlocks();
      if(categories.isNotEmpty){
        _updateTabControllerLength(categories.length);
      }
      setState(() {
       });

  }



  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> searchTracks(String query) {
    return
      firestore
        .collection('Tracks')
        .where('categories', arrayContains: query)
        .snapshots();}


  Stream<QuerySnapshot> searchTracksNew(String query) {

    final CollectionReference tracksCollection = firestore.collection('Tracks');
    Stream<QuerySnapshot> categorySnapshot;
    if(categories.isNotEmpty){
      String? objectId;
      for (var category in categories) {
        if (category.name.toLowerCase().contains(query.toLowerCase())) {
          objectId = category.id;
          break;
        }
      }

      if(objectId != null){
        // Search by categories field
        categorySnapshot = tracksCollection
            .where('categories', arrayContains: objectId)
            .snapshots();
      }else{
        categorySnapshot = tracksCollection
            .where('categories', arrayContains: query)
            .snapshots();
      }

    }else{
      categorySnapshot = tracksCollection
          .where('categories', arrayContains: query)
          .snapshots();
    }



    // Check if the category snapshot is empty
    final Stream<QuerySnapshot> emptySnapshot = categorySnapshot.asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        final QuerySnapshot titleSnapshot = await tracksCollection
            .where('title', isGreaterThanOrEqualTo: query, isLessThan: query + 'z',isLessThanOrEqualTo: query + '\uf8ff')
            .get();

        if (titleSnapshot.docs.isEmpty) {
          return await tracksCollection
              .where('speaker',  isGreaterThanOrEqualTo: query, isLessThan: query + 'z',isLessThanOrEqualTo: query + '\uf8ff')
              .get();
        }

        return titleSnapshot;
      }

      return snapshot;
    });

    return emptySnapshot;
  }}
