import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/audiofile_model.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import '../utils/global_functions.dart';
import 'mp3_card_list_item_height.dart';


class TrackListHorizontal extends StatelessWidget {
  final List<AudioTrack> audiList;
  final Function() tap;
  Function panelFunction;
  bool musicList;

  TrackListHorizontal({
    Key? key,
    required this.audiList,
    required this.tap,
    required this.musicList,
    required this.panelFunction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
          SizedBox(
            height: 231.h,
            child: ListView.separated(
              padding: EdgeInsets.only(left:16.w),
              scrollDirection: Axis.horizontal,
              itemCount: audiList.length,
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(width: 16.w);
              },
              itemBuilder: (BuildContext context, int index) {
                return Mp3Item(
                  imageUrl: audiList[index].thumbnail,
                  mp3Name: audiList[index].title,
                  mp3Category: audiList[index].categories.isEmpty?"":audiList[index].categories[0].categoryName,
                  mp3Duration: audiList[index].length,
                  tap:(){
                    if(musicList){
                      //getIt<PageManager>().init();
                      getIt<PageManager>().loadPlaylist(audiList,index);
                      panelFunction(false);
                      //Navigator.of(context).push( SlideFromBottomPageRoute(page: MusicPlayerScreen( audioFile: audiList[index],playList: true,)));
                    }else{
                      playTrack(audiList[index]);
                      panelFunction(false);
                      //Navigator.of(context).push( SlideFromBottomPageRoute(page: MusicPlayerScreen( audioFile: audiList[index],playList: false,)));
                    }

                  }
                );
              },
            ),
    );
  }
}
