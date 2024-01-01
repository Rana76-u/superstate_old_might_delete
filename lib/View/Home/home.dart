import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superstate/View/Home/home_appbar.dart';
import 'package:superstate/View/Home/home_floating.dart';
import 'package:superstate/View/Widgets/error.dart';
import 'package:superstate/View/Widgets/loading.dart';
import 'package:superstate/View/Widgets/navigator.dart';
import 'package:superstate/View/Widgets/postcard.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const HomeAppBar(),
        floatingActionButton: const HomeFloatingActionButton(),
        body: SingleChildScrollView(
          child: postsWidget(),
        ),
      ),
    );
  }
  
  Widget postsWidget() {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').get(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return postCard(
                  snapshot.data!.docs[index].get('commentCount'),
                  snapshot.data!.docs[index].get('creationTime'),
                  snapshot.data!.docs[index].get('fileLinks'),
                  snapshot.data!.docs[index].get('postText'),
                  snapshot.data!.docs[index].get('uid'),
                  snapshot.data!.docs[index].get('upCount'),
                );
              },
            );
          }
          else if(snapshot.connectionState == ConnectionState.waiting){
            return Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.35),
                child: Loading().centralLinearSized(context, 0.4)
            );
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


}
