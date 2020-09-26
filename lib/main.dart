import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with 'flutter run'. You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // 'hot reload' (press 'r' in the console where you ran 'flutter run',
        // or simply save your changes to 'hot reload' in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth test'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Current user: ${FirebaseAuth.instance.currentUser}'),
            RaisedButton(
              child: Text('Sign out'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
            RaisedButton(
              child: Text('Anonymous sign in'),
              onPressed: () async {
                await FirebaseAuth.instance.signInAnonymously();
              },
            ),
            RaisedButton(
              child: Text('Google sign in'),
              onPressed: () async {
                var account =
                await (await googleSignIn.signIn()).authentication;
                var credential = GoogleAuthProvider.credential(
                    idToken: account.idToken, accessToken: account.accessToken);
                await FirebaseAuth.instance.signInWithCredential(credential);
              },
            ),
            RaisedButton(
                child: Text('Guided steps to reproduce'),
                onPressed: () =>
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GuidedTour())))
          ],
        ),
      ),
    );
  }
}

class GuidedTour extends StatefulWidget {
  @override
  _GuidedTourState createState() => _GuidedTourState();
}

class _GuidedTourState extends State<GuidedTour> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Auth test'),
        ),
        body: Center(
          child: Column(
            children: buildTour(context),
          ),
        ));
  }

  List<Widget> buildTour(BuildContext context) {
    var step = determineStep();
    switch (step) {
      case Step.one:
        return buildGoogleSignIn();
        break;
      case Step.two:
        return buildAnonymousSignIn();
        break;
      case Step.three:
        return buildRestart();
        break;
      case Step.four:
        return buildEnd();
        break;
    }
    throw 'I am throwing!';
  }

  List<Widget> buildGoogleSignIn() {
    return [
      Text('Current user: ${FirebaseAuth.instance.currentUser}'),
      Text('Step 1: Sign in with Google'),
      RaisedButton(
        child: Text('Google sign in'),
        onPressed: () async {
          var account = await (await googleSignIn.signIn()).authentication;
          var credential = GoogleAuthProvider.credential(
              idToken: account.idToken, accessToken: account.accessToken);
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
      )
    ];
  }

  List<Widget> buildAnonymousSignIn() {
    return [
      Text('Current user: ${FirebaseAuth.instance.currentUser}'),
      Text('Step 2: Sign in anonymously'),
      RaisedButton(
        child: Text('Anonymous sign in'),
        onPressed: () async => await FirebaseAuth.instance.signInAnonymously(),
      )
    ];
  }

  List<Widget> buildRestart() {
    return [
      Text('Current user: ${FirebaseAuth.instance.currentUser}'),
      Text('Step 3: (hot)restart the app')
    ];
  }

  List<Widget> buildEnd() {
    return [
      Text('Current user: ${FirebaseAuth.instance.currentUser}'),
      Text('See user above')
    ];
  }
}

enum Step { one, two, three, four }

Step determineStep() {
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Step.one;
  } else if (!user.isAnonymous && user.email?.isNotEmpty == true) {
    return Step.two;
  } else if (user.isAnonymous) {
    return Step.three;
  } else {
    return Step.four;
  }
}
