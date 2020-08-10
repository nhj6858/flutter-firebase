import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase/firebase_provider.dart';

FirestoreFirstDemoState pageState;

class FirestoreFirstDemo extends StatefulWidget {
  @override
  FirestoreFirstDemoState createState() {
    pageState = FirestoreFirstDemoState();
    return pageState;
  }
}

class FirestoreFirstDemoState extends State<FirestoreFirstDemo> {
  FirebaseProvider fp;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // 컬렉션명
  final String colName = "FirstDemo";

  // 필드명
  final String fnName = "name";
  final String fnDescription = "description";
  final String fnDatetime = "datetime";
  final String fnAuthor_uid = "author_uid";

  TextEditingController _newNameCon = TextEditingController();
  TextEditingController _newDescCon = TextEditingController();
  TextEditingController _undNameCon = TextEditingController();
  TextEditingController _undDescCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Firestore First Demo")),
      body: Column(
        children: <Widget>[
          Container(
            child: ListTile(
                title: Text("Auth UID"),
                subtitle: Text(
                    (fp.getUser() != null) ? fp.getUser().displayName : "")),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection(colName)
                  .orderBy(fnDatetime, descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return Text("Error: ${snapshot.error}");
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text("Loading...");
                  default:
                    return ListView(
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        Timestamp ts = document[fnDatetime];
                        String dt = timestampToStrDateTime(ts);
                        return Card(
                          elevation: 2,
                          child: InkWell(
                            // Read Document
                            onTap: () {
                              showDocument(document.documentID);
                            },
                            // Update or Delete Document
                            onLongPress: () {
                              showUpdateOrDeleteDocDialog(document);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        document[fnName],
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        dt.toString(),
                                        style:
                                        TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          document[fnDescription],
                                          style:
                                          TextStyle(color: Colors.black54),
                                        ),
                                        Text((document[fnAuthor_uid] != null)
                                            ? document[fnAuthor_uid]
                                            : "")
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                }
              },
            ),
          )
        ],
      ),
      // Create Document
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: showCreateDocDialog),
    );
  }

  /// Firestore CRUD Logic

  // 문서 생성 (Create)
  void createDoc(String name, String description) {
    Firestore.instance.collection(colName).add({
      fnName: name,
      fnDescription: description,
      fnDatetime: Timestamp.now(),
      fnAuthor_uid: (fp.getUser() != null) ? fp.getUser().uid : null
    });
  }

  // 문서 조회 (Read)
  void showDocument(String documentID) {
    Firestore.instance
        .collection(colName)
        .document(documentID)
        .get()
        .then((doc) {
      showReadDocSnackBar(doc);
    });
  }

  // 문서 갱신 (Update)
  void updateDoc(String docID, String name, String description) {
    Firestore.instance.collection(colName).document(docID).updateData({
      fnName: name,
      fnDescription: description,
    });
  }

  // 문서 삭제 (Delete)
  void deleteDoc(String docID) {
    Firestore.instance.collection(colName).document(docID).delete();
  }

  void showCreateDocDialog() {
    _newNameCon.text = (fp.getUser() != null) ? fp.getUser().displayName : "";
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Document"),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(labelText: "Name"),
                  controller: _newNameCon,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Description"),
                  controller: _newDescCon,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _newNameCon.clear();
                _newDescCon.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Create"),
              onPressed: () {
                if (_newDescCon.text.isNotEmpty &&
                    _newNameCon.text.isNotEmpty) {
                  createDoc(_newNameCon.text, _newDescCon.text);
                }
                _newNameCon.clear();
                _newDescCon.clear();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void showReadDocSnackBar(DocumentSnapshot doc) {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.deepOrangeAccent,
          duration: Duration(seconds: 5),
          content: Text(
              "$fnName: ${doc[fnName]}\n$fnDescription: ${doc[fnDescription]}"
                  "\n$fnDatetime: ${timestampToStrDateTime(doc[fnDatetime])}"),
          action: SnackBarAction(
            label: "Done",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot doc) {
    _undNameCon.text = doc[fnName];
    _undDescCon.text = doc[fnDescription];
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update/Delete Document"),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  controller: _undNameCon,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Description"),
                  controller: _undDescCon,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _undNameCon.clear();
                _undDescCon.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Update"),
              onPressed: () {
                if (_undNameCon.text.isNotEmpty &&
                    _undDescCon.text.isNotEmpty) {
                  updateDoc(doc.documentID, _undNameCon.text, _undDescCon.text);
                }
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Delete"),
              onPressed: () {
                deleteDoc(doc.documentID);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  String timestampToStrDateTime(Timestamp ts) {
    return DateTime.fromMicrosecondsSinceEpoch(ts.microsecondsSinceEpoch)
        .toString();
  }
}