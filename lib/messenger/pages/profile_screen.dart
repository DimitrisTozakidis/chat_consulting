import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../utilities/snack_bar.dart';

class ProfileScreenLocal extends StatefulWidget {
  const ProfileScreenLocal({Key? key}) : super(key: key);

  @override
  State<ProfileScreenLocal> createState() => _ProfileScreenLocalState();
}

class _ProfileScreenLocalState extends State<ProfileScreenLocal> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> logOut() async {
    try {
      // Sign in with email and password
      await FirebaseAuth.instance.signOut();

      // Navigate to MessengerScreen on successful sign-in
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } on FirebaseAuthException {
      String message;
      message = 'Nooo you will never LEAVE Hahahah';
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: message,
        ),
      );
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Delete the user's account
      await user?.delete();

      // Navigate back after successful deletion
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred while deleting your account.';
      if (e.code == 'requires-recent-login') {
        message = 'Please reauthenticate to delete your account.';
      }
      // Show an error message using the snackbar or dialog.
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: message,
        ),
      );
    }
  }

  Stream<QuerySnapshot> getName() {
    final firestore = FirebaseFirestore.instance;
    return firestore.collection('Users').snapshots();
  }

  late String roomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Profile ',
              style: TextStyle(fontSize: 30),
            ),
            Icon(
              Icons.account_box,
              size: 30,
            )
          ],
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 120),
            StreamBuilder<QuerySnapshot>(
              stream: getName(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isNotEmpty) {
                    List<QueryDocumentSnapshot> allData = snapshot.data!.docs;
                    QueryDocumentSnapshot? data;

                    for (int i = 0; i < allData.length; i++) {
                      data = allData[i];
                      if (data['id'] == FirebaseAuth.instance.currentUser!.uid) {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(25),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.red),
                              height: 120,
                              width: 120,
                              child: Text(data['name'][0] ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 60)),
                            ),
                            SizedBox(height: 24,),
                            Text(
                              data['name'] ?? '',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }
                    }
                    // Return a default widget if no matching data is found
                    return Container();
                  } else {
                    return Center(
                      child: Text('No name found'),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }
              },
            ),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
                onPressed: () async => logOut(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )),
            SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async => deleteAccount(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete),
                  Text('Delete account'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.red[700]; // Color for the pressed state
                    }
                    return Colors.red; // Default color
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
