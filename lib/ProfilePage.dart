import 'package:flutter/material.dart';

import 'utils/BottomWaveClipper.dart';
import 'utils/RoundedRectButton.dart';
class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {},
        )
      ],
    );
    return Scaffold(

      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: topAppBar,
      body: new Container(
        child: new Column(
          children: <Widget>[
            new Stack(
              children: <Widget>[
                new ClipPath(
                  clipper: BottomWaveClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: BottomWaveClipper.orangeGradients,
                          begin: Alignment.topLeft,
                          end: Alignment.center),
                    ),
                    height: MediaQuery.of(context).size.height / 2.3,
                  ),
                ),//ClipPath
                new Card(
                    elevation: 10.0,
                    margin:EdgeInsets.only(top: 65.0,left: 30.0,right: 10.0),
                    child: new Container(
                      width: 350.0,
                      height: 330.0,
                      padding: new EdgeInsets.all(14.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            width: 100.0,
                            height: 100.0,
                            margin: EdgeInsets.only(top: 10.0),
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: new ExactAssetImage('assets/images/profile.jpg')
                              ),
                            ),
                          ),//Image Container
                          new Container(
                              padding:EdgeInsets.only(top: 10.0),
                              child: new Text(
                                "John Wick",
                                style: new TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              )
                          ),//Text Container
                          new Container(
                              padding:EdgeInsets.only(top: 5.0),
                              child: new Text(
                                "the man boogie man, babayega!!!",
                                style: new TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.start,
                              )
                          ),//Text Container

                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                      padding:EdgeInsets.only(top: 15.0),
                                      child: new Text(
                                        "SHOTS",
                                        style: new TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.start,
                                      )
                                  ),//Text Container
                                  SizedBox(
                                    width: 50.0,
                                    height: 3.0,
                                    child: const DecoratedBox(
                                      decoration: const BoxDecoration(
                                          color: Colors.orange
                                      ),
                                    ),
                                  ),//sized widget
                                  new Container(
                                      padding:EdgeInsets.only(top: 5.0,left: 5.0),
                                      child: new Text(
                                        "500",
                                        style: new TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                  ),//Text Container
                                ],
                              ),//Column
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                      padding:EdgeInsets.only(top: 15.0,left: 15.0),
                                      child: new Text(
                                        "BOTTLES",
                                        style: new TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                  ),//Text Container
                                  SizedBox(
                                    width: 63.0,
                                    height: 3.0,
                                    child: const DecoratedBox(
                                      decoration: const BoxDecoration(
                                          color: Colors.orange
                                      ),
                                    ),
                                  ),//sized widget
                                  new Container(
                                      padding:EdgeInsets.only(top: 5.0,left: 15.0),
                                      child: new Text(
                                        "3",
                                        style: new TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                  ),//Text Container
                                ],
                              ),//Column
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Container(
                                      padding:EdgeInsets.only(top: 15.0),
                                      child: new Text(
                                        "CHECK IN",
                                        style: new TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.start,
                                      )
                                  ),//Text Container
                                  SizedBox(
                                    width: 70.0,
                                    height: 3.0,
                                    child: const DecoratedBox(
                                      decoration: const BoxDecoration(
                                          color: Colors.orange
                                      ),
                                    ),
                                  ),//sized widget
                                  new Container(
                                      padding:EdgeInsets.only(top: 5.0,left: 15.0),
                                      child: new Text(
                                        "20",
                                        style: new TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                  ),//Text Container
                                ],
                              ),//Column

                            ],
                          ),
                          new Container(
                            margin: EdgeInsets.only(top: 20.0),
                             child: RoundedRectButton.roundedRectButton("Edit Profile", RoundedRectButton.signInGradients, false),
                          ),//Container

                        ],
                      ),
                    )), //Card
              ],
            ),//Stack
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[

                  ],
                ),
              ),
            ),
            new Card(

            )


          ],
        ),
      ) ,

    );
  }
}