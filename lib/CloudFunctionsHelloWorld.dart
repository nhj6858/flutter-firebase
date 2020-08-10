import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

CloudFunctionsHelloWorldState pageState;

class CloudFunctionsHelloWorld extends StatefulWidget {
  @override
  CloudFunctionsHelloWorldState createState() {
    pageState = CloudFunctionsHelloWorldState();
    return pageState;
  }
}

class CloudFunctionsHelloWorldState extends State<CloudFunctionsHelloWorld> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final HttpsCallable helloWorld = CloudFunctions.instance
  .getHttpsCallable(functionName: 'helloWorld')
  ..timeout = const Duration(seconds: 30);

  final HttpsCallable addCount = CloudFunctions.instance
  .getHttpsCallable(functionName: 'addCount')
  ..timeout = const Duration(seconds: 30);

  final HttpsCallable removeCount = CloudFunctions.instance.getHttpsCallable(functionName: 'removeCount')
  ..timeout = const Duration(seconds: 30);

  String resp = "";
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Cloud Functions HelloWorld")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(10),
              color: Colors.deepOrangeAccent,
              child: Text(
                resp,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            // URL로 helloWorld 에 접근
            RaisedButton(
              child: Text("http.get helloWorld"),
              onPressed: () async {
                clearResponse();
                String url =
                    "https://us-central1-flutter-firebase-e93d9.cloudfunctions.net/helloWorld";
                showProgressSnackBar();
                var response = await http.get(url);
                hideProgressSnackBar();
                setState(() {
                  resp = response.body;
                });
              },
            ),
            // Cloud Functions 으로 호출
            RaisedButton(
              child: Text("Call Cloud Function helloWorld"),
              onPressed: () async {
                try {
                  clearResponse();
                  showProgressSnackBar();
                  final HttpsCallableResult result = await helloWorld.call();
                  setState(() {
                    resp = result.data;
                  });
                } on CloudFunctionsException catch (e) {
                  print('caught firebase functions exception');
                  print('code: ${e.code}');
                  print('message: ${e.message}');
                  print('details: ${e.details}');
                } catch (e) {
                  print('caught generic exception');
                  print(e);
                }
                hideProgressSnackBar();
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: null,
                    child: Icon(Icons.remove),
                    onPressed: () async {
                      final HttpsCallableResult result = await removeCount.call(<String, dynamic>{'count': count});
                      print(result.data);
                      setState(() {
                        count = result.data;
                      });
                    },
                  ),
                  FloatingActionButton(
                    heroTag: null,
                    child: Icon(Icons.add),
                    onPressed: () async {
                      final HttpsCallableResult result = await addCount.call(<String, dynamic>{'count': count});
                      print(result.data);
                      setState(() {
                        count = result.data;
                      });
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  clearResponse() {
    setState(() {
      resp = "";
    });
  }

  showProgressSnackBar() {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: 10),
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Text("   Calling Firebase Cloud Functions...")
            ],
          ),
        ),
      );
  }

  hideProgressSnackBar() {
    _scaffoldKey.currentState..hideCurrentSnackBar();
  }

  showErrorSnackBar(String msg) {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[400],
          duration: Duration(seconds: 10),
          content: Text(msg),
          action: SnackBarAction(
            label: "Done",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }
}