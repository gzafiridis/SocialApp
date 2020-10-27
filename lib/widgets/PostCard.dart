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
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<Auth>(context, listen: false);
    if (widget.post.data()['likedBy'].contains(user.userId))
      _isLiked = true;
    else
      _isLiked = false;

    setState(() {
      _isLoading = true;
    });
    initializeSaved();
  }

  void initializeSaved() async {
    final user = Provider.of<Auth>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    if (user.userRole == 'patient') {
      final response = await FirebaseFirestore.instance
          .collection('patients')
          .doc(user.userId)
          .collection('bookmarks')
          .doc(widget.post.id)
          .get();
      if (response.data() == null)
        _isSaved = false;
      else
        _isSaved = true;
    } else {
      final response = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.userId)
          .collection('bookmarks')
          .doc(widget.post.id)
          .get();
      if (response.data() == null)
        _isSaved = false;
      else
        _isSaved = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void bookmark() async {
    final user = Provider.of<Auth>(context, listen: false);
    if (_isSaved) {
      if (user.userRole == 'patient') {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(user.userId)
            .collection('bookmarks')
            .doc(widget.post.id)
            .set(widget.post.data());
      } else {
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(user.userId)
            .collection('bookmarks')
            .doc(widget.post.id)
            .set(widget.post.data());
      }
    } else {
      if (user.userRole == 'patient') {
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(user.userId)
            .collection('bookmarks')
            .doc(widget.post.id)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(user.userId)
            .collection('bookmarks')
            .doc(widget.post.id)
            .delete();
      }
    }
  }

  void setLike() async {
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
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Doctor: ' + widget.post.data()['username']),
                      subtitle: Text(dateformat),
                      onTap: () => {
                        Navigator.of(context).pushNamed('/other_profile',
                            arguments: [widget.post.data()['userId'], 'doctors'])
                      },
                    )
                  : ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
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
                ),
              Text(
                widget.post.data()['main_text'],
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
                          setLike();
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
                          'Comment',
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
                      bookmark();
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
