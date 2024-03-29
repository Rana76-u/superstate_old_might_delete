import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkify/linkify.dart';

class CRUDPost {

  void create(String postText) async {
    //generate and unique Post ID
    Random random = Random();
    String postID = '';
    const String chars = "0123456789abcdefghijklmnopqrstuvwxyz";
    for (int i = 0; i < 20; i++) {
      postID += chars[random.nextInt(chars.length)];
    }

    //check if the text is there or not
    //if not then add " "
    List texts = [];
    List<LinkifyElement> linkifyItems = linkify(postText);
    for (int i = 1; i < linkifyItems.length; i = i + 2) {
      if (linkifyItems[i] is TextElement) {
        TextElement textElement = linkifyItems[i] as TextElement;
        texts.add(textElement.text);
      }
    }

    if(texts.isEmpty){
      postText = " $postText";
    }

    //Save Post items into PostID
    await FirebaseFirestore
        .instance
        .collection('posts')
        .doc(postID)
        .set({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'creationTime': DateTime.now(),
      'postText': postText,
      'reactCount': 0,
      'comments': FieldValue.arrayUnion([]),
      'commentCount': 0,
      'fileLinks': FieldValue.arrayUnion([]),
    });

    //Save PostID at users Profile
    await FirebaseFirestore
        .instance
        .collection('userData')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'posts': FieldValue.arrayUnion([postID])
    });
  }

  void addReact(String postDocID, int react) {

    FirebaseFirestore
        .instance
        .collection('posts')
        .doc(postDocID)
        .collection('reacts')
        .doc(FirebaseAuth.instance.currentUser!.uid).set({
      'react': react
    });
  }

}