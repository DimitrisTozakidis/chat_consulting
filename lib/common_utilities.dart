
import 'package:flutter/material.dart';


class CommonUtilities{



  static void openDeleteDialog(BuildContext context, Function()  onPressed) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 600,
          color: Colors.grey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 20,
                width: 20,
                child: TextField(
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Search ...'),
                  onChanged: (query) {
                  },
                ),
              ),
              const Text(
                  'Are you sure that you want to delete this article?'),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text('Nope'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}