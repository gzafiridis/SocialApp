import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  PostCard(this.post);

  final post;
  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked;
  bool _isSaved;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<Auth>(context, listen: false);
    if (widget.post.data()['likedBy'].contains(user.userId))
      _isLiked = true;
    else
      _isLiked = false;

    if (widget.post.data()['bookmarked'].contains(user.userId))
      _isSaved = true;
    else
      _isSaved = false;
  }

  void _bookmark() async {
    final user = Provider.of<Auth>(context, listen: false);
    if (_isSaved)
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'bookmarked': FieldValue.arrayUnion([user.userId])
      });
    else
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'bookmarked': FieldValue.arrayRemove([user.userId])
      });
  }

  void _setLike() async {
    final user = Provider.of<Auth>(context, listen: false);
    if (_isLiked)
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'likedBy': FieldValue.arrayUnion([user.userId])
      });
    else
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'likedBy': FieldValue.arrayRemove([user.userId])
      });
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.post.data()['createdAt'].toDate();
    final dateformat = DateFormat.yMd().add_jm().format(date);
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Card(
            child: Column(
            children: [
              widget.post.data()['role'] == 'doctor'
                  ? ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.post.data()['photo'],
                        ),
                        radius: 30,
                      ),
                      title: Row(
                        children: [
                          Text(widget.post.data()['username']),
                          Container(width: 20,),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text('Doctor', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: Text(dateformat),
                      ),
                      onTap: () => {
                        Navigator.of(context).pushNamed('/other_profile',
                            arguments: [
                              widget.post.data()['userId'],
                              'doctors'
                            ])
                      },
                    )
                  : ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.post.data()['photo'],
                        ),
                        radius: 30,
                      ),
                      title: Text(widget.post.data()['username']),
                      subtitle: Text(dateformat),
                      onTap: () => {
                        Navigator.of(context).pushNamed('/other_profile',
                            arguments: [
                              widget.post.data()['userId'],
                              'patients'
                            ])
                      },
                    ),
              if (widget.post.data()['title'] != '')
                Text(
                  widget.post.data()['title'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.post.data()['main_text'],
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Text(widget.post.data()['likedBy'].length.toString()),
                      FlatButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                          _setLike();
                        },
                        icon: Icon(
                          Icons.thumb_up,
                          color: _isLiked
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        label: Text(
                          'Like ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(widget.post.data()['comment_count'].toString()),
                      FlatButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(
                            '/post_comments',
                            arguments: widget.post.id),
                        icon: Icon(
                          Icons.comment,
                          color: Theme.of(context).primaryColor,
                        ),
                        label: Text(
                          'Comments',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  FlatButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSaved = !_isSaved;
                      });
                      _bookmark();
                    },
                    icon: _isSaved
                        ? Icon(
                            Icons.bookmark,
                            color: Theme.of(context).primaryColor,
                          )
                        : Icon(
                            Icons.bookmark_border,
                            color: Colors.grey,
                          ),
                    label: Text(
                      'Bookmark',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              )
            ],
          ));
  }
}
