
import 'package:flutter/material.dart';

import '../models/article.dart';

class CommonUtilities{



  static void openDeleteDialog(BuildContext context, Article element, Function()  onPressed) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.grey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                    'Are you sure that you want to delete this article?'),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: onPressed,
                      child: const Text('Yes'),
                    ),
                    ElevatedButton(
                      child: const Text('Nope'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}