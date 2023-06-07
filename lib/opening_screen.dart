import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:untitled3/type_of_connection.dart';
import 'login_register_screen.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({Key? key}) : super(key: key);

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  final ScrollController scrollController = ScrollController();
  final List<int> tagSelected = [];

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TypeOfConnection _typeOfConnection;

    // 1
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                height: 156,
              ),
              Container(
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
                  child: SvgPicture.asset(
                    color: Colors.orange,
                    "assets/chatcommunication.svg",
                    height: 180,
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONS',
                    style: TextStyle(color: Colors.orange, fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    "CHAT",
                    style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w800),
                  )
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Color(0xff2a3547)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to ConsChat App',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Proceed with:',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _typeOfConnection = TypeOfConnection.login;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginRegisterScreen(
                                    typeOfConnection: _typeOfConnection.label,
                                  )),
                        );
                      },
                      child: Container(
                        height: 60,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.orange,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign in',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        _typeOfConnection = TypeOfConnection.register;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginRegisterScreen(
                                    typeOfConnection: _typeOfConnection.label,
                                  )),
                        );
                      },
                      child: Container(
                        height: 60,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.pink,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign up',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
