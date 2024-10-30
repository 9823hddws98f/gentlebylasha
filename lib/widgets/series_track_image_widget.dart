import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';

class SeriesTrackListImageWidget extends StatelessWidget {
  final AudioTrack audioTrack;
  final bool favorite;
  final Function() tap;
  final Function() favoriteTap;

  const SeriesTrackListImageWidget(
      {super.key,
      required this.audioTrack,
      required this.tap,
      required this.favoriteTap,
      required this.favorite});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: GestureDetector(
            onTap: tap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 72,
                  width: 72,
                  child: CachedNetworkImage(
                    imageUrl: audioTrack.thumbnail,
                    imageBuilder: (context, imageProvider) => ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          audioTrack.categories[0].categoryName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerLeft,
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
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          audioTrack.length,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: IconButton(
                    onPressed: favoriteTap,
                    icon: favorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                )
              ],
            )));
  }
}
