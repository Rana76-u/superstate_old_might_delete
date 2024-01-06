import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superstate/Blocs/Bottom%20Navigation%20Bloc/bottom_navigation_bloc.dart';
import 'package:superstate/Blocs/React%20Bloc/react_bloc.dart';
import 'package:superstate/View/Widgets/bottom_nav_bar.dart';
import 'package:superstate/View/login.dart';
import 'Blocs/Youtube Video Player Bloc/youtube_player_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => BottomBarBloc(),),
          BlocProvider(create: (context) => ReactBloc(),),
          BlocProvider(create: (context) => YoutubePlayerBloc(),),
        ],
        child: MaterialApp(
          title: 'SuperState',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: 'Urbanist',
          ),
          home: screenNavigator(),
          debugShowCheckedModeBanner: false,
        )
    );
  }

  Widget screenNavigator() {
    if(FirebaseAuth.instance.currentUser != null) {
      return const BottomBar();
    }
    else{
      return const LoginPage();
    }
  }
}
