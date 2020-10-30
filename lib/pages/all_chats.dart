import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllChats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context, listen: false);
    var tag;
    if (user.userRole == 'patient')
      tag = 'patients';
    else
      tag = 'doctors';

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(tag)
            .doc(user.userId)
            .collection('chats')
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatsSnapshot) {
          if (chatsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (chatsSnapshot.data.size == 0) {
            return Center(
                child: Text('You do not have any conversations yet!'));
          }
          final chatsDocs = chatsSnapshot.data.docs;
          return ListView.builder(
            itemCount: chatsDocs.length,
            itemBuilder: (ctx, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      chatsDocs[index].data()['photo'],
                    ),
                    radius: 20,
                  ),
                  trailing: Icon(Icons.navigate_next),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chatsDocs[index].data()['username'],
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(width: 6),
                      if (chatsDocs[index].data()['role'] == 'doctor')
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              'Doctor',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).primaryColor),
                        ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).pushNamed('/chat',
                      arguments: [
                        chatsDocs[index].id,
                        chatsDocs[index].data()['role']
                      ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
