import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:linkify/linkify.dart';
import 'package:superstate/Blocs/React%20Bloc/react_bloc.dart';
import 'package:superstate/Blocs/React%20Bloc/react_events.dart';
import 'package:superstate/Blocs/React%20Bloc/react_states.dart';
import 'package:superstate/View/Widgets/profile_image.dart';
import 'package:superstate/ViewModel/crud_post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'error.dart';
import 'loading.dart';

Widget postCard(
    String postDocID,
    int commentCount,
    Timestamp creationTime,
    List<dynamic> fileLinks,
    String postText,
    String uid,
    int reactCount,
    int reaction,
    BuildContext context,
    ReactState state,
    int index) {

  List links = [];

  List<LinkifyElement> linkifyItems = linkify(postText);
  for (int i = 1; i < linkifyItems.length; i = i + 2) {
    if (linkifyItems[i] is UrlElement) {
      UrlElement urlElement = linkifyItems[i] as UrlElement;
      links.add(urlElement.url);
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      topPart(uid, creationTime),

      postTextWidget(postText),

      thumbnailWidget(links),

      bottomPart(postDocID, reaction, context, state, index),

      Divider(thickness: 1, color: Colors.grey.shade200,),

    ],
  );
}

Widget topPart(String uid, Timestamp creationTime) {
  DateTime dateTime = creationTime.toDate();
  Duration difference = DateTime.now().difference(dateTime);

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.abs().toString().padLeft(2, '0');
    int inHours = duration.inHours;

    if (inHours < 1) {
      int inMinutes = duration.inMinutes.remainder(60);
      return '$inMinutes minute${inMinutes == 1 ? '' : 's'} ago';
    } else if (inHours < 24) {
      int inMinutes = duration.inMinutes.remainder(60);
      return '$inHours hour${inHours == 1 ? '' : 's'} $twoDigits(inMinutes) minute${inMinutes == 1 ? '' : 's'} ago';
    } else if (inHours < 24 * 7) {
      int inDays = duration.inDays;
      return '$inDays day${inDays == 1 ? '' : 's'} ago';
    } else if (inHours < 24 * 7 * 3) {
      int inWeeks = (duration.inDays / 7).floor();
      return '$inWeeks week${inWeeks == 1 ? '' : 's'} ago';
    } else {
      // If it's over 3 weeks, show the post's original datetime
      // Adjust the format according to your needs
      return 'Posted on ${dateTime.year}-${twoDigits(dateTime.month)}-${twoDigits(dateTime.day)} ${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
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
      style: const TextStyle(
          color: Colors.black,
        fontSize: 12.5
      ),
      linkStyle: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 12.5,
        decoration: TextDecoration.none, // Remove underline
      ),
    ),
  );
}

Widget thumbnailWidget(List links){
  if(links.isEmpty){
    return const SizedBox();
  }
  else{
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: links.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
          future: AnyLinkPreview.getMetadata(link: links[index]),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return Padding(
                padding: const EdgeInsets.only(left: 55, right: 20, top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //link
                              Text(
                                links[index],
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              //title
                              Text(
                                snapshot.data!.title ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),

                              //desc
                              Text(
                                snapshot.data!.desc ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade700
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      CachedNetworkImage(
                        width: double.infinity,
                          imageUrl: snapshot.data!.image ?? '',
                        fit: BoxFit.cover,
                      ),

                    ],
                  ),
                ),
              );
            }
            else if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            else{
              return const SizedBox();
            }
          },
        );
      },
    );
  }
}

Widget bottomPart(String postDocID,int reaction, BuildContext context, ReactState state, int index) {
  final provider = BlocProvider.of<ReactBloc>(context);
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        //comment
        const Padding(
            padding: EdgeInsets.only(left: 55 ,right: 10),
            child: Icon(MingCute.chat_1_line)),

        //like
        GestureDetector(
          onTap: () {
            CRUDPost().addReact(postDocID, 1);
            
            provider.add(LikeEvent(index: index));
          },
          child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: reaction == 1 ? const Icon(MingCute.thumb_up_2_fill) : const Icon(MingCute.thumb_up_2_line) //state.reactList[index]
          ),
        ),

        //dislike
        GestureDetector(
          onTap: () {
            CRUDPost().addReact(postDocID, -1);

            provider.add(DislikeEvent(index: index));
          },
            child: reaction == -1 ? const Icon(MingCute.thumb_down_2_fill) : const Icon(MingCute.thumb_down_2_line)
        ),
      ],
    ),
  );
}

