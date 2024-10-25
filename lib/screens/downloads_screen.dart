import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sleeptales/constants/assets.dart';

import '/widgets/topbar_widget.dart';

class DownloadsScreen extends StatefulWidget {
  final String? email;
  const DownloadsScreen({super.key, this.email});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreen();
}

class _DownloadsScreen extends State<DownloadsScreen> {
  final mp3Files = <String>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TopBar(
                          heading: "Downloads",
                          onPress: () {
                            Navigator.pop(context);
                          }),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        leading: Icon(Icons.dark_mode, color: Colors.white),
                        title: Text('Delete sleep stories'),
                        trailing: Text(
                          "Zero KB",
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: SvgPicture.asset(Assets.spaBlack),
                        title: Text('Delete guided meditations'),
                        trailing: Text(
                          "Zero KB",
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.music_note, color: Colors.white),
                        title: Text('Delete music'),
                        trailing: Text(
                          "Zero KB",
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ))),
        ),
      ),
    );
  }

  Future<List<String>> getDownloadedMP3Files() async {
    final directory = await getApplicationDocumentsDirectory();

    try {
      final directoryList = directory.listSync(recursive: true);
      for (var file in directoryList) {
        if (file is File && file.path.endsWith('.mp3')) {
          mp3Files.add(file.path);
        }
      }
    } catch (e) {
      debugPrint('Error retrieving MP3 files: $e');
    }

    setState(() {});
    return mp3Files;
  }

  @override
  void initState() {
    super.initState();
    //getDownloadedMP3Files();
  }
}

class DownloadedTrack {
  final String trackName;
  final String trackFilePath;

  DownloadedTrack({required this.trackName, required this.trackFilePath});
}
