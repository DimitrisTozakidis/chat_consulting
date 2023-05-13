import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:untitled3/snack_bar.dart';
import 'package:untitled3/type_of_connection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'auth.dart';
import 'models/user_custom.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key, required this.typeOfConnection});

  final int typeOfConnection;

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final CollectionReference _users = FirebaseFirestore.instance.collection(('users'));
  late final int _typeOfConnection = widget.typeOfConnection;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final User? user = Auth().currentUser;
  bool isLogin = true;
  String? errorMessage = 'erorrrr';
  final int j = 0;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Good job, your release is successful. Have a nice day',
        ),
      );
    }
  }

  Widget _errorMessage() {
    return const CustomSnackBar.error(
      message: 'Good job, your release is successful. Have a nice day',
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _typeOfConnection == 0 ? Colors.orange : Colors.pink,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: IconButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white)),
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios),
      ),
      body: StreamBuilder(
        stream: _users.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasError) {
            return (Text('Something went wrong'));
          } else if (streamSnapshot.hasData) {
            final users = streamSnapshot.data!;

            return j == 1
                ? ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(documentSnapshot['name']),
                          subtitle: Text(documentSnapshot['email'].toString()),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                // IconButton(icon: const Icon(Icons.edit), onPressed: () => _update(documentSnapshot)),
                                // IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(documentSnapshot.id)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : StreamBuilder(
                    //stream: _users.snapshots(),
                    stream: Auth().authStateChanges,
                    //builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    builder: (context, streamSnapshot) {
                      return SingleChildScrollView(
                        child: Container(
                          height: height,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 60.0, top: 96.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _typeOfConnection == 0
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => LoginRegisterScreen(
                                                    typeOfConnection: TypeOfConnection.login.label,
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Text(
                                        'Sign in',
                                        style: TextStyle(color: Colors.white, fontSize: _typeOfConnection == 0 ? 35 : 20),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16.0,
                                    ),
                                    GestureDetector(
                                      onTap: _typeOfConnection == 1
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => LoginRegisterScreen(
                                                          typeOfConnection: TypeOfConnection.register.label,
                                                        )),
                                              );
                                            },
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(color: Colors.white, fontSize: _typeOfConnection == 1 ? 35 : 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //StreamBuilder(stream: Firestore.instance.collection('users').snapshots(), builder: (BuildContext context, snapshot) {  },),

                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                    color: Colors.white),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _typeOfConnection == 1 ? 'Enter the following details to register' : 'Enter the following details to login',
                                      style: TextStyle(color: Colors.black, fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    TextField(
                                      textInputAction: TextInputAction.next,
                                      controller: _nameController,
                                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), hintText: 'Username'),
                                      onChanged: (query) {},
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    if (_typeOfConnection == 1)
                                      Column(
                                        children: [
                                          TextField(
                                            // inputFormatters: [
                                            //   FilteringTextInputFormatter.allow(RegExp(r'[0-9-,.]')),
                                            //   DecimalTextInputFormatter(),
                                            // ],
                                            textInputAction: TextInputAction.next,
                                            controller: _emailController,
                                            decoration:
                                                InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), hintText: 'Enter your Email'),
                                            onChanged: (query) {},
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                        ],
                                      ),
                                    TextField(
                                      textInputAction: TextInputAction.done,
                                      controller: _passwordController,
                                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), hintText: 'Password'),
                                      onChanged: (query) {},
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            backgroundColor: MaterialStateProperty.all<Color>(_typeOfConnection == 0 ? Colors.orange : Colors.pink)),
                                        onPressed: _typeOfConnection == 0 ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
                                        //   {
                                        //   final String name = _nameController.text;
                                        //   final String email = _emailController.text;
                                        //   final String password = _passwordController.text;
                                        //   final user = UserCustom(
                                        //     name: name,
                                        //     email: email,
                                        //     password: password,
                                        //   );
                                        //
                                        //   createUser(user: user);
                                        //   Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) => ArticleListScreen(),
                                        //     ),
                                        //   );
                                        //
                                        // },
                                        child: Text(
                                          'Enter',
                                          style: TextStyle(color: Colors.black, fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: TapBounceContainer(
                                        onTap: () {
                                          showTopSnackBar(
                                            Overlay.of(context),
                                            const CustomSnackBar.error(
                                              message: 'Good job, your release is successful. Have a nice day',
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Enter',
                                          style: TextStyle(color: Colors.black, fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Future createUser({required UserCustom user}) async {
  final docUser = FirebaseFirestore.instance.collection('users').doc();
  final json = user.toJson();

  await docUser.set(json);
}

Stream<List<UserCustom>> readUsers() =>
    FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) => snapshot.docs.map((doc) => UserCustom.fromJson(doc.data())).toList());

Widget buildUser(UserCustom user) => ListTile(
      leading: CircleAvatar(child: Text('${user.name}')),
      title: Text(user.email),
      subtitle: Text(user.password),
    );

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final TextEditingValue cleanedValue = newValue.copyWith(
      text: newValue.text.replaceAll(',', '.'), // Replace any commas with periods
    );
    final RegExp regEx = RegExp(r'^-?\d*\.?\d*');
    final String newString = regEx.stringMatch(cleanedValue.text) ?? '';
    return newString == cleanedValue.text ? cleanedValue : oldValue;
  }
}
