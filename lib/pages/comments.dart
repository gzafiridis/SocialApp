import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentPage extends StatefulWidget {
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _controller = new TextEditingController();
  var _enteredComment = '';
  var post;
  var _isLoading = false;
  var _isinit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isinit) {
      post = ModalRoute.of(context).settings.arguments as String;
    }
    _isinit = false;
  }

  Future<bool> _confirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to add this comment?'),
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
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(post)
                    .collection('comments')
                    .orderBy(
                      'createdAt',
                    )
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> commentSnapshot) {
                  if (commentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final commentDocs = commentSnapshot.data.docs;
                  if (commentDocs.isEmpty)
                    return Center(child: Text('There are no comments yet.'));
                  else
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        final comment = commentDocs[index];
                        final date = comment.data()['createdAt'].toDate();
                        final dateformat =
                            DateFormat.yMd().add_jm().format(date);
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      comment.data()['photo'],
                                    ),
                                    radius: 20,
                                  ),
                                  title: Row(
                                    children: [
                                      Text(comment.data()['username']),
                                      Container(
                                        width: 10,
                                      ),
                                      if (comment.data()['role'] == 'doctor')
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              'Doctor',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Text(dateformat),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(50.0, 0, 10, 0),
                                  child: Text(
                                    comment.data()['text'],
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: commentDocs.length,
                    );
                }),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: InputDecoration(labelText: 'Add a comment'),
                    onChanged: (value) {
                      _enteredComment = value;
                    },
                  ),
                ),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : FlatButton(
                        color: Theme.of(context).primaryColor,
                        child: Text('Add'),
                        onPressed: _enteredComment.trim().isEmpty
                            ? () {
                                FocusScope.of(context).unfocus();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Error'),
                                    content: Text(
                                        'You cannot add an empty comment. Write something first!'),
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
                                      .doc(post)
                                      .collection('comments')
                                      .add({
                                    'text': _enteredComment.trim(),
                                    'createdAt': Timestamp.now(),
                                    'userId': user.userId,
                                    'username': user.userName,
                                    'role': user.userRole,
                                    'photo': user.userPhoto,
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(post)
                                      .update({
                                    'comment_count': FieldValue.increment(1)
                                  });
                                  _controller.clear();
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
