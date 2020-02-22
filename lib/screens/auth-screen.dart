import 'dart:math';

import 'package:flutter/material.dart';
import 'package:note/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// enum to change from sign in to sign up
enum AuthMode { SignUp, Login }

class AuthScreen extends StatelessWidget {
  // route key to navigate to this screen suing it
  static const routeKey = '/auth';

  @override
  Widget build(BuildContext context) {
    // device size from mediaQuery to set all dimensions to it with a ratio
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
//       resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: deviceSize.height * 0.04),
                      padding: EdgeInsets.symmetric(
                          vertical: deviceSize.height * 0.014,
                          horizontal: deviceSize.width * 0.25),
                      transform: Matrix4.rotationZ(-4 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.pink,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: FittedBox(
                        child: Text(
                          'NOTE IT',
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: deviceSize.height * 0.1,
                            fontFamily: 'Anton',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _passwordFocusNode.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.Login) {
      // Log user in
      if (await Provider.of<AuthProvider>(context, listen: false).authUser(
          _authData['email'].trim(),
          _authData['password'].trim(),
          'signInWithPassword',
          context)) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } else {
      // Sign user up
      if (await Provider.of<AuthProvider>(context, listen: false).authUser(
          _authData['email'], _authData['password'], 'signUp', context)) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.SignUp
            ? deviceSize.height
            : deviceSize.height * 0.44,
        // deviceSize.height * .7,
        constraints: BoxConstraints(
            minHeight: _authMode == AuthMode.SignUp
                ? deviceSize.height
                : deviceSize.height * 0.44),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(deviceSize.height * 0.025),

        // we use form here with TextFormField and validation etc.
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  // validator to make sure that field in not empty and the email is valid
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  // validator to make sure that field in not empty and the password is valid
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                // This third TextFormField is for sign up
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    enabled: _authMode == AuthMode.SignUp,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    // validator to make sure that field in not empty and passwords match
                    validator: _authMode == AuthMode.SignUp
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                SizedBox(
                  height: deviceSize.height * 0.03,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: deviceSize.height * 0.05,
                        vertical: deviceSize.height * 0.015),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),

                // button to switch from sign in to sign up
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _isLoading ? null : _switchAuthMode,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
