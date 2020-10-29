import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/pages/splash_screen.dart';
import 'package:diplomatiki/providers/auth_provider.dart';
import 'package:diplomatiki/widgets/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var user;
  var _isLoading = true;
  var _isInit = false;

  @override
  void initState() {
    super.initState();
    user = Provider.of<Auth>(context, listen: false);
    if (user.userId == null) user.fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit)
      _isLoading = false;
    else
      _isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? SplashScreen()
        : Scaffold(
            appBar: AppBar(
              title: Text("Feed"),
              centerTitle: true,
            ),
            endDrawer: Drawer(
              child: ListView(
                children: [
                  Container(
                    height: 175.0,
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Hero(
                            tag: 'photo',
                            child: Material(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/my_profile');
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    user.userPhoto,
                                  ),
                                  radius: 35,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              borderRadius: BorderRadius.all(
                                Radius.circular(65.0),
                              ),
                            ),
                          ),
                          Text(
                            user.userName,
                            style:
                                TextStyle(color: Colors.white, fontSize: 24.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FlatButton(
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Profile',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/my_profile');
                    },
                  ),
                  FlatButton(
                    child: ListTile(
                      leading: Icon(
                        Icons.chat,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Coversations',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/all_chats');
                    },
                  ),
                  FlatButton(
                    child: ListTile(
                      leading: Icon(
                        Icons.collections_bookmark,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Bookmarks',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/bookmarks');
                    },
                  ),
                  FlatButton(
                    child: ListTile(
                      leading: Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    onPressed: () {
                      Provider.of<Auth>(context, listen: false).signout();
                    },
                  ),
                ],
              ),
            ),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy(
                      'createdAt',
                      descending: true,
                    )
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final postDocs = postSnapshot.data.docs;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return PostCard(postDocs[index]);
                    },
                    itemCount: postDocs.length,
                  );
                }),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 15.0,
              child: Icon(
                Icons.add,
                size: 30.0,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/create_post',
                );
              },
            ),
          );
  }
}
