import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplomatiki/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherProfile extends StatefulWidget {
  @override
  _OtherProfileState createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
  var user;
  var _isinit = true;
  var args;
  var _isLoading = true;

  Future<DocumentSnapshot> _getUser(id, role) async {
    var user =
        await FirebaseFirestore.instance.collection(args[1]).doc(args[0]).get();
    print(user);
    return user;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context).settings.arguments as List;
    if (_isinit)
      _getUser(args[0], args[1]).then((value) {
        user = value;
        setState(() {
          _isLoading = false;
        });
      });
    _isinit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          user.data()['photo'],
                        ),
                        radius: 40,
                      ),
                      Text(user.data()['username']),
                      Text(user.data()['email']),
                      Text(user.data()['role']),
                      Text('My Story'),
                      Text(user.data()['story']),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                            '/chat',
                            arguments: [user.id, user.data()['role']]),
                        child: Text('Send a message'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
