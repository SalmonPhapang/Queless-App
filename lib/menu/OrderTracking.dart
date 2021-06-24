import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/Avatar.dart';
import 'package:flutter_app/widgets/ProgressBar.dart';

class OrderTracker extends StatefulWidget {
  @override
  _OrderTrackerState createState() => _OrderTrackerState();
}

class _OrderTrackerState extends State<OrderTracker> with TickerProviderStateMixin {
  // final timerDuration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.black,
            size: 40,
          ),
          onPressed: () {},
        ),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'CANCEL',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50),
              child: Text(
                'Order#568',
                style:
                TextStyle(color: Color.fromRGBO(0, 0, 0, 0.2), fontSize: 12),
              ),
            ),
           // Timer(),
            ProgressBar(),
            SizedBox(height: 50),
            AvatarAndText(),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}