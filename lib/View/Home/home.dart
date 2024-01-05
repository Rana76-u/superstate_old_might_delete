import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superstate/Blocs/React%20Bloc/react_bloc.dart';
import 'package:superstate/Blocs/React%20Bloc/react_events.dart';
import 'package:superstate/Blocs/React%20Bloc/react_states.dart';
import 'package:superstate/View/Home/home_appbar.dart';
import 'package:superstate/View/Home/home_floating.dart';
import 'package:superstate/View/Widgets/error.dart';
import 'package:superstate/View/Widgets/loading.dart';
import 'package:superstate/View/Widgets/postcard.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReactBloc, ReactState>(
      listener: (context, state) {},
      builder: (context, state) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: const HomeAppBar(),
            floatingActionButton: const HomeFloatingActionButton(),
            body: SingleChildScrollView(
              child: postsWidget(state),
            ),
          ),
        );
      },
    );
  }
  
  Widget postsWidget(ReactState state) {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').get(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {

                final provider = BlocProvider.of<ReactBloc>(context);

                return FutureBuilder(
                    future: FirebaseFirestore
                        .instance
                        .collection('posts')
                        .doc(snapshot.data!.docs[index].id)
                        .collection('reacts')
                        .doc(FirebaseAuth.instance.currentUser!.uid).get(),
                    builder: (context, reactSnapshot) {

                      int reaction = 0;

                      if (reactSnapshot.connectionState == ConnectionState.done) {
                        // Check if data has been loaded
                        if (reactSnapshot.hasData) {
                          reaction = reactSnapshot.data!.get('react');
                        }

                        if (reaction == 1) {
                          provider.add(LikeEvent(index: index));
                          print('LikeEvent');
                        } else if (reaction == 0) {
                          provider.add(NeutralEvent(index: index));
                        } else if (reaction == -1) {
                          provider.add(DislikeEvent(index: index));
                        }
                      } else {
                        // Data is still loading
                        // You can choose to show a loading indicator or do nothing during loading
                      }

                      /*print(index);
                      print(snapshot.data!.docs[index].id);
                      print(snapshot.data!.docs[index].get('commentCount'));
                      print(snapshot.data!.docs[index].get('creationTime'));
                      print(snapshot.data!.docs[index].get('fileLinks'));
                      print(snapshot.data!.docs[index].get('postText'));
                      print(snapshot.data!.docs[index].get('uid'));
                      print(snapshot.data!.docs[index].get('reactCount'));*/
                      return postCard(
                          snapshot.data!.docs[index].id,
                          snapshot.data!.docs[index].get('commentCount'),
                          snapshot.data!.docs[index].get('creationTime'),
                          snapshot.data!.docs[index].get('fileLinks'),
                          snapshot.data!.docs[index].get('postText'),
                          snapshot.data!.docs[index].get('uid'),
                          snapshot.data!.docs[index].get('reactCount'),
                          state.reactList[index],
                          context,
                          state,
                          index
                      );

                    },
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
