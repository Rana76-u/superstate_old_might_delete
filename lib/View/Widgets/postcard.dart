import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:superstate/View/Widgets/profile_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'error.dart';
import 'loading.dart';

Widget postCard(
    int commentCount,
    Timestamp creationTime,
    List<dynamic> fileLinks,
    String postText,
    String uid,
    int upCount,) {
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      topPart(uid, creationTime),

      postTextWidget(postText),

      const Divider(),

    ],
  );
}

Widget topPart(String uid, Timestamp creationTime) {
  DateTime dateTime = creationTime.toDate();
  Duration difference = dateTime.difference(DateTime.now());

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.abs().toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

    if(duration.inHours.toInt() == 0){
      return '$twoDigitMinutes minutes ago';
    }
    else{
      return '${duration.abs().inHours} hour $twoDigitMinutes minutes ago';
    }
  }

  return FutureBuilder(
      future: FirebaseFirestore.instance.collection('userData').doc(uid).get(), 
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: profileImage(snapshot.data!.get('imageURL')),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.data!.get('name'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    formatDuration(difference),
                    style: TextStyle(
                        color: Colors.grey.shade700,
                      fontSize: 10.5
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        else if(snapshot.connectionState == ConnectionState.waiting){
          return Loading().centralDefault(context, 'linear');
        }
        else {
          return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.35),
              child: ShowErrorMessage().central(context, 'No New Post')
          );
        }
      },
  );
}

Widget postTextWidget(String postText) {
  return Padding(
    padding: const EdgeInsets.only(left: 55, right: 10),
    child: SelectableLinkify(
      onOpen: (link) async {
        if (!await launchUrl(Uri.parse(link.url))) {
          throw Exception('Could not launch ${link.url}');
        }
      },
      text: postText,
      style: const TextStyle(color: Colors.black),
      linkStyle: const TextStyle(color: Colors.blue),

    ),
  );
}

