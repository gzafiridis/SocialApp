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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'photo',
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        user.userPhoto,
                      ),
                      radius: 40,
                    ),
                  ),
                  Container(height: 30),
                  Text(
                    user.userName,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  Container(height: 7),
                  Text(
                    user.userEmail,
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  ),
                  Container(height: 10),
                  if (user.userRole == 'doctor')
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
                  Container(height: 25),
                  Text(
                    'My Story',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                      initialValue: user.userStory,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          hintText: 'Write your personal story here',
                          hintStyle: TextStyle(fontSize: 17)),
                      style: TextStyle(fontSize: 19),
                      onChanged: (value) {
                        story = value.trim();
                        setState(() {
                          flag = true;
                        });
                      }),
                  if (flag) Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () async {
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
