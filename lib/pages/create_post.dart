import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _title = new TextEditingController();
  final _body = new TextEditingController();
  var _post = '';
  var _isLoading = false;

  Future<bool> _confirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to make this post?'),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: Text('Yes'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Write a new post')),
      body: Container(
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(),
        child: Column(
          children: [
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Title (optional)'),
            ),
            Expanded(
              child: TextField(
                controller: _body,
                maxLines: null,
                expands: true,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                    labelText: 'Ask or share something with others'),
                onChanged: (value) {
                  setState(() {
                    _post = value;
                  });
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 15.0),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : FlatButton(
                      color: Theme.of(context).primaryColor,
                      child: Text('Submit', style: TextStyle(fontSize: 20.0)),
                      onPressed: _post.trim().isEmpty
                          ? () {
                              FocusScope.of(context).unfocus();
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text(
                                      'Oops, looks like you forgot to write your post. Write something you want to share with others!'),
                                  actions: [
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                      },
                                      child: Text('Ok'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          : () async {
                              FocusScope.of(context).unfocus();
                              final bool confirm =
                                  await _confirmDialog(context);
                              if (confirm) {
                                setState(() {
                                  _isLoading = true;
                                });
                                final user =
                                    Provider.of<Auth>(context, listen: false);
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .add({
                                  'title': _title.text.trim(),
                                  'main_text': _body.text,
                                  'createdAt': Timestamp.now(),
                                  'userId': user.userId,
                                  'username': user.userName,
                                  'role': user.userRole,
                                  'photo': user.userPhoto,
                                  'likedBy': FieldValue.arrayUnion([]),
                                  'comment_count': 0,
                                });
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.of(context).pop();
                              }
                            },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
