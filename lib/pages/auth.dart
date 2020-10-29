import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

enum AuthMode { Signup, Login }

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  String _role = 'patient';
  String _username = '';
  var _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
            _authData['email'], _authData['password'], _role, _username);
      }
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
      String errorMessage = 'There was an error:\n' + error.toString();
      _showErrorDialog(errorMessage);
    }

    // setState(() {
    //   _isLoading = false;
    // });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _authMode == AuthMode.Login ? Text('Login') : Text('Sign Up'),
      ),
      body: Align(
        child: Container(
          width: deviceSize.width * 0.9,
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    if (_authMode == AuthMode.Signup)
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Username'),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.length < 3) {
                            return 'Your name should be at least 3 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _username = value;
                        },
                      ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (String value) {
                        if (value.isEmpty) return 'Email Address is Required.';
                        if (!RegExp(
                                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                            .hasMatch(value)) {
                          return 'Please Enter a valid Email.';
                        }
                      },
                      onSaved: (String value) {
                        _authData['email'] = value.trim();
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      validator: (String value) {
                        if (value.isEmpty || value.trim().length < 6) {
                          return 'Password must be at least 6 characters long.';
                        }
                      },
                      onSaved: (String value) {
                        _authData['password'] = value.trim();
                      },
                    ),
                    if (_authMode == AuthMode.Signup)
                      TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    if (_authMode == AuthMode.Signup)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: CheckboxListTile(
                          title: Text('I am a doctor'),
                          value: _role == 'doctor',
                          onChanged: (bool value) {
                            setState(() {
                              if (value)
                                _role = 'doctor';
                              else
                                _role = 'patient';
                            });
                          },
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.05),
                      child: ButtonTheme(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        child: RaisedButton(
                          textColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          color: Theme.of(context).primaryColor,
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : _authMode == AuthMode.Login
                                    ? Text(
                                        'LOGIN',
                                        style: TextStyle(fontSize: 16.0),
                                      )
                                    : Text(
                                        'SIGNUP',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                          ),
                          onPressed: () => _submitForm(),
                        ),
                      ),
                    ),
                    if (!_isLoading)
                      FlatButton(
                        textColor: Theme.of(context).primaryColor,
                        child: Text(_authMode == AuthMode.Login
                            ? 'Create new account'
                            : 'I already have an account'),
                        onPressed: () {
                          _switchAuthMode();
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
