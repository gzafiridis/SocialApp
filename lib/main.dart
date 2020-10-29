import 'package:diplomatiki/pages/all_chats.dart';
import 'package:diplomatiki/pages/bookmarks.dart';
import 'package:diplomatiki/pages/chat.dart';
import 'package:diplomatiki/pages/comments.dart';
import 'package:diplomatiki/pages/my_profile.dart';
import 'package:diplomatiki/pages/other_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'pages/auth.dart';
import 'pages/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'pages/main_page.dart';
import 'pages/create_post.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Auth()),
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, appSnapshot) {
          return Consumer<Auth>(
            builder: (context, auth, _) => MaterialApp(
              title: 'Diplomatiki',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: Colors.cyan[700],
                accentColor: Colors.cyan[200],
                buttonTheme: ButtonTheme.of(context).copyWith(
                  buttonColor: Colors.cyan[700],
                  textTheme: ButtonTextTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
               home: appSnapshot.connectionState != ConnectionState.done
                  ? SplashScreen()
                  : StreamBuilder(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SplashScreen();
                        }
                        if (userSnapshot.hasData) {
                          //Provider.of<Auth>(context, listen:false).fetchData();
                          return MainPage();
                        }
                        return AuthPage();
                      }), //auth.user == null ? AuthPage() : SplashScreen(),
              routes: {
                '/main_page': (context) => MainPage(),
                '/chat': (context) => ChatPage(),
                '/all_chats': (context) => AllChats(),
                '/create_post': (context) => CreatePost(),
                '/post_comments': (context) => CommentPage(),
                '/my_profile': (context) => MyProfilePage(),
                '/other_profile': (context) => OtherProfile(),
                '/bookmarks': (context) => Bookmarks(),
              },
            ),
          );
        });
  }
}
