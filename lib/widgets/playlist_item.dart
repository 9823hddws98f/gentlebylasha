import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/block.dart';

class PlaylistItem extends StatelessWidget {
  final Block block;
  final Function() tap;
  final Function() favoriteTap;

  const PlaylistItem({
    super.key,
    required this.block,
    required this.tap,
    required this.favoriteTap,
  });

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
                    imageUrl: block.thumbnail,
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
                        alignment: Alignment.centerLeft,
                        child: Text(
                          block.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          block.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      //Spacer(),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          block.author,
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
                  child: IconButton(onPressed: favoriteTap, icon: Icon(Icons.favorite)),
                )
              ],
            )));
  }
}
