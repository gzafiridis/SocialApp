import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/providers/auth_provider.dart';
import 'package:diplomatiki/widgets/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Bookmarks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context, listen: false);
    if (user.userRole == 'patient')
      final tag = 'patients';
    else
      final tag = 'doctors';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('bookmarked', arrayContains: user.userId)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> bookmarkSnapshot) {
          if (bookmarkSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (bookmarkSnapshot.data.size == 0) {
            return Center(
                child:
                    Text('You have not added any post to your bookmarks yet!'));
          }
          final bookmarkDocs = bookmarkSnapshot.data.docs;
          return ListView.builder(
            itemCount: bookmarkDocs.length,
            itemBuilder: (ctx, index) => PostCard(bookmarkDocs[index]),
          );
        },
      ),
    );
  }
}
