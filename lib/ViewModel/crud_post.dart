import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUDPost {

  void create(String postText, ) async {
    //generate and unique Post ID
    Random random = Random();
    String postID = '';
    const String chars = "0123456789abcdefghijklmnopqrstuvwxyz";
    for (int i = 0; i < 20; i++) {
      postID += chars[random.nextInt(chars.length)];
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
      'upCount': 0,
      'comments': FieldValue.arrayUnion([]),
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

}