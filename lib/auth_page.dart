
import 'package:flutter/cupertino.dart';
import 'package:flutter_firebase/firebase_provider.dart';
import 'package:flutter_firebase/signedin_page.dart';
import 'package:flutter_firebase/signin_page.dart';
import 'package:provider/provider.dart';



AuthPageState pageState;

class AuthPage extends StatefulWidget {
  @override
  AuthPageState createState() {
    pageState = AuthPageState();
    return pageState;
  }
}

class AuthPageState extends State<AuthPage> {
  FirebaseProvider fp;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    logger.d("user: ${fp.getUser()}");
    if (fp.getUser() != null && fp.getUser().isEmailVerified == true) {
      return SignedInPage();
    } else {
      return SignInPage();
    }
  }
}
