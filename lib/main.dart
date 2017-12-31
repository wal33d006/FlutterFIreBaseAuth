import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

String UserNameLabel = "";
String userEmail = "";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Google sign in'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

Future _testWithFacebookSignIn() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final FirebaseUser user =
      await _auth.signInWithFacebook(accessToken: googleAuth.accessToken);
  UserNameLabel = user.displayName;
}

class _MyHomePageState extends State<MyHomePage> {
  String _userNameLabel = "";
  String _userEmail = "";
  bool _isLoading = false;

  int _counter = 0;

  Future<String> _testSignInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    UserNameLabel = googleUser.displayName;
    userEmail = googleUser.email;

    print("Hello $user");

    return 'signInWithGoogle succeeded: $user';
  }

  Future _incrementCounter() async {
    await _testSignInWithGoogle();
    setState(() {
      _isLoading = false;
      _counter++;
      _userNameLabel = UserNameLabel;
      _userEmail = userEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Card(
              elevation: 8.0,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    padding: new EdgeInsets.all(16.0),
                    child: _isLoading
                        ? new Center(
                            child: const CircularProgressIndicator(),
                          )
                        : new ListTile(
                            leading: new Icon(
                              Icons.verified_user,
                              color: _userEmail.isEmpty
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                            subtitle: _userNameLabel.isEmpty
                                ? new Text("Click the FAB to sign in",
                                    style: Theme.of(context).textTheme.body1)
                                : new Text("$_userEmail",
                                    style: Theme.of(context).textTheme.body1),
                            trailing: new Icon(
                              Icons.contact_mail,
                              color: _userNameLabel.isEmpty
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                            dense: true,
                            title: _userNameLabel.isEmpty
                                ? new Text("No user signed in",
                                    style: Theme.of(context).textTheme.headline)
                                : new Text("$_userNameLabel",
                                    style:
                                        Theme.of(context).textTheme.headline),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.input),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
