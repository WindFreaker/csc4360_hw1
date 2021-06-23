import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:csc4360_hw1/data/post_data.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // testing streaming stuff
  late StreamController streamController = StreamController();

  // list of all posts that have been made
  List<PostData> _postList = [];

  // collections needed from Firestore for this assignment (homework #1)
  CollectionReference usersRef = FirebaseFirestore.instance.collection('hw1-users');
  CollectionReference postsRef = FirebaseFirestore.instance.collection('hw1-posts');

  // variable needed for making the admin mode work
  bool _adminMode = false;

  void createPost() {
    String postText = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Write a post',
            textAlign: TextAlign.center,
          ),
          content: TextField(
            onChanged: (String? value) {
              postText = (value == null) ? '' : value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Post it!'),
              onPressed: () async {
                await postsRef.add({
                  'content': postText,
                  'createdAt': Timestamp.now(),
                });
                Navigator.of(context).pop();
                loadPosts();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loadPosts() async {

    Timestamp latest;
    if (_postList.length != 0) {
      latest = _postList[0].timestamp;
    } else {
      latest = Timestamp.fromMillisecondsSinceEpoch(0);
    }

    await postsRef.where(
      'createdAt',
      isGreaterThan: latest,
    ).get().then((QuerySnapshot value) {
      value.docs.forEach((doc) {
        _postList.add(PostData(
          content: doc['content'],
          timestamp: (doc['createdAt'] as Timestamp)),
        );
      });
    });

    _postList.sort((a, b) {
      return b.timestamp.compareTo(a.timestamp);
    });

    // this is not proper usage of a StreamController
    // I am only doing this because it seemingly works perfectly
    // ...and I really want this project done with
    streamController.add('done');

  }

  Future<void> checkAdminMode() async {
    await usersRef.doc(FirebaseAuth.instance.currentUser!.uid).get().then((DocumentSnapshot document) {
      if (document.exists) {
        _adminMode = (document['role'] == 'ADMIN');
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    loadPosts();
    checkAdminMode();
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: (!_adminMode) ? null : FloatingActionButton(
        onPressed: createPost,
        child: Icon(Icons.post_add),
      ),
      appBar: AppBar(
        title: Text('The Feed'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Are you sure you\nwant to logout?',
                      textAlign: TextAlign.center,
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Logout'),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(context, '/new_user', (route) => false);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPosts,
          child: StreamBuilder(
            stream: streamController.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: _postList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: Colors.grey[200],
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              _postList[index].content,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              DateFormat('HH:mm MMMM dd, yyyy').format(_postList[index].timestamp.toDate()),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Center(
                  child: SpinKitPumpingHeart(
                    color: Colors.lightBlue,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}