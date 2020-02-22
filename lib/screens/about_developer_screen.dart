import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:getflutter/getflutter.dart';

class AboutDeveloper extends StatelessWidget {
  // route key to navigate to this screen suing it
  static const routeKey = '/about-developer';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal,
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Flexible(
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: DeveloperCard(),
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

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class DeveloperCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: deviceSize.height * 0.14,
          horizontal: deviceSize.width * 0.03),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: Container(
          margin: EdgeInsets.all(deviceSize.height * 0.04),
          padding: EdgeInsets.all(deviceSize.height * 0.001),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  'Ahmad El-Baz',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: deviceSize.width * .07),
                ),
                SizedBox(
                  height: deviceSize.height * 0.07,
                ),
                GFButton(
                  onPressed: () {
                    _launchURL('https://www.youtube.com/user/ahmeedelbaz/');
                  },
                  text: "YouTube",
                  shape: GFButtonShape.pills,
                  color: Colors.red,
                  fullWidthButton: true,
                ),
                SizedBox(
                  height: deviceSize.height * 0.017,
                ),
                GFButton(
                  onPressed: () {
                    _launchURL('https://www.facebook.com/ahmed.elbaz11');
                  },
                  text: "Facebook",
                  shape: GFButtonShape.pills,
                  color: Colors.blue,
                  fullWidthButton: true,
                ),
                SizedBox(
                  height: deviceSize.height * 0.017,
                ),
                GFButton(
                  onPressed: () {
                    _launchURL('https://www.linkedin.com/in/ahmadelbaz');
                  },
                  text: "LinkedIn",
                  shape: GFButtonShape.pills,
                  color: Colors.blue,
                  fullWidthButton: true,
                ),
                SizedBox(
                  height: deviceSize.height * 0.017,
                ),
                GFButton(
                  onPressed: () {
                    _launchURL('mailto:ahmeed.elbaz@gmail.com?subject=News&body=New%20plugin');
                  },
                  text: "E-mail adress",
                  shape: GFButtonShape.pills,
                  color: Colors.white,
                  textColor: Colors.pink,
                  fullWidthButton: true,
                ),
                SizedBox(
                  height: deviceSize.height * 0.017,
                ),
                GFButton(
                  onPressed: () {
                    _launchURL('tel:+201145009965');
                  },
                  text: "Phone number with WhatsApp",
                  shape: GFButtonShape.pills,
                  color: Colors.green,
                  fullWidthButton: true,
                ),
                SizedBox(
                  height: deviceSize.height * 0.017,
                ),
                GFButton(
                  onPressed: () {
                    _launchURL('tel:+201010825280');
                  },
                  text: "Phone number",
                  shape: GFButtonShape.pills,
                  color: Colors.green,
                  fullWidthButton: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
