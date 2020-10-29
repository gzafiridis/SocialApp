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
                      Container(height: 30),
                      Text(
                        user.data()['username'],
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Container(height: 7),
                      Text(
                        user.data()['email'],
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      Container(height: 10),
                      if (user.data()['role'] == 'doctor')
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
                      Text(
                        'My Story',
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      Container(height: 10),
                      Text(
                        user.data()['story'],
                        style: TextStyle(fontSize: 19),
                      ),
                      Container(height: 25,),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                            '/chat',
                            arguments: [user.id, user.data()['role']]),
                        child: Text(
                          'Send a message',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
