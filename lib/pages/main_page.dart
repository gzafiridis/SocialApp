import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  void initState() {
    super.initState();
    final user = Provider.of<Auth>(context, listen: false);
    if (user.userId == null) user.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed"),
        centerTitle: true,
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            FlatButton(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                //trailing: Icon(Icons.exit_to_app),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/my_profile');
              },
            ),
            FlatButton(
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                //trailing: Icon(Icons.exit_to_app),
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
