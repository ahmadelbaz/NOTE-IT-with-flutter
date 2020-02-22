import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Provider class to control Authentication and Mode(light & dark) in the whole app

class AuthProvider with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expireDate;
  Timer _timer;

//  var isDark = false;

  bool get isAuth {
    return isValidToken != null;
  }

  String get isValidToken {
    if (_token != null &&
        _expireDate != null &&
        _expireDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get isValidUser {
    return _userId;
  }

  void showError(String title, String content, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future<bool> authUser(String emailAddress, String password, String urlSegmant,
      BuildContext context) async {
    var response;
    final url =
        'ADD_YOUR_API';
    try {
      response = await http.post(
        url,
        body: json.encode(
          {
            'email': emailAddress,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      if (json.decode(response.body).toString().contains('EMAIL_EXISTS')) {
        showError('EMAIL EXISTS',
            'The email address is already in use by another account.', context);
        return false;
      } else if (json
          .decode(response.body)
          .toString()
          .contains('EMAIL_NOT_FOUND')) {
        showError(
            'EMAIL NOT FOUND',
            'There is no user record corresponding to this identifier. The user may have been deleted.',
            context);
        return false;
      } else if (json
          .decode(response.body)
          .toString()
          .contains('INVALID_PASSWORD')) {
        showError(
            'INVALID PASSWORD',
            'The password is invalid or the user does not have a password.',
            context);
        return false;
      } else if (json
          .decode(response.body)
          .toString()
          .contains('WEAK_PASSWORD')) {
        showError('WEAK PASSWORD', 'The password is too weak.', context);
        return false;
      } else if (json
          .decode(response.body)
          .toString()
          .contains('INVALID_EMAIL')) {
        showError('INVALID_EMAIL', 'The is not a valid email adress.', context);
        return false;
      }
      _token = json.decode(response.body)['idToken'];
      _userId = json.decode(response.body)['localId'];
      _expireDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            json.decode(response.body)['expiresIn'],
          ),
        ),
      );
      _autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expireDate': _expireDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> signUpWithEmail(
      String emailAdress, String password, BuildContext context) async {
    try {
      authUser(emailAdress, password, 'signUp', context);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> signInWithEmail(
      String emailAdress, String password, BuildContext context) async {
    try {
      authUser(emailAdress, password, 'signInWithPassword', context);
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> tryLogging() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final userData = json.decode(
      prefs.getString('userData'),
    ) as Map<String, Object>;
    final expiryDate = DateTime.parse(userData['expireDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData['token'];
    _userId = userData['userId'];
    _expireDate = expiryDate;
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    notifyListeners();
  }

  void _autoLogOut() {
    if (_timer != null) {
      _timer.cancel();
    }
    final timeToExpire = _expireDate.difference(DateTime.now()).inSeconds;
    _timer = Timer(Duration(seconds: timeToExpire), logOut);
  }
}
