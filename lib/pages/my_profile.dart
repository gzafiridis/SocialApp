import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  var user;
  var key = GlobalKey();
  var _isinit = true;
  String story;
  var flag = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isinit) user = Provider.of<Auth>(context, listen: false);
    _isinit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    user.userPhoto,
                  ),
                  radius: 40,
                ),
                Text(user.userName),
                Text(user.userEmail),
                Text(user.userRole),
                Text('My Story'),
                TextFormField(
                    initialValue: user.userStory,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText: 'Write your personal story here'),
                    onChanged: (value) {
                      story = value.trim();
                      setState(() {
                        flag = true;
                      });
                    }),
                RaisedButton(
                  onPressed: !flag
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          if (user.userRole == 'patient') {
                            await FirebaseFirestore.instance
                                .collection('patients')
                                .doc(user.userId)
                                .update({'story': story});
                          } else {
                            await FirebaseFirestore.instance
                                .collection('doctors')
                                .doc(user.userId)
                                .update({'story': story});
                          }
                          user.setStory(story);
                          Navigator.of(context).pop();
                        },
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
