import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';

class SeriesTrackListWidget extends StatelessWidget {
  final AudioTrack audioTrack;
  final Function() tap;
  final Function() onTapPlayPause;
  final Function() favoriteTap;
  final bool favorite;
  final bool currentPlaying;

  const SeriesTrackListWidget(
      {super.key,
      required this.audioTrack,
      required this.tap,
      required this.favoriteTap,
      required this.favorite,
      required this.currentPlaying,
      required this.onTapPlayPause});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: GestureDetector(
            onTap: tap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onTapPlayPause,
                  icon: Icon(
                    currentPlaying ? Icons.pause : Icons.play_arrow_outlined,
                    size: 30,
                  ),
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.only(right: 10, top: 0, bottom: 8, left: 0),
                ),

                Expanded(
                  child: Text(
                    audioTrack.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                //Spacer(),
                SizedBox(width: 15),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    audioTrack.length,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),

                SizedBox(
                  width: 12,
                ),

                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: IconButton(
                    onPressed: favoriteTap,
                    icon: favorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    constraints: BoxConstraints(),
                  ),
                )
              ],
            )));
  }
}
