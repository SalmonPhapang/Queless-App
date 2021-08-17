import 'package:flutter/material.dart';
import 'package:flutter_app/HomePage.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/model/CheckIn.dart';
import 'package:flutter_app/utils/BottomWaveClipper.dart';
import 'package:flutter_app/utils/TopWaveClipper.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class ResultPage extends StatefulWidget {
  ResultPage({Key key, this.title, @required this.checkIn}) : super(key: key);

  final String title;
  final CheckIn checkIn;
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
    );//AppBar
    return new Scaffold(
      backgroundColor: Colors.transparent,
      appBar: topAppBar,
      body: new Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: BottomWaveClipper.orangeGradients,
              begin: Alignment.topLeft,
              end: Alignment.center),
        ),
        child: new Column(
          children: <Widget>[
            new Stack(
              children: <Widget>[
                new Center(
                  child: Image.asset("assets/images/img_result.png",height: 200.0,width: 200.0,),
                ),
                new Center(
                  child:new Container(
                    margin: EdgeInsets.only(top: 120.0),
                    child:Image.asset("assets/images/fireworks.png",height: 100.0,width: 100.0,) ,
                  ),
                ),
              ],
            ),
            new Card(
              elevation: 10.0,
              margin:EdgeInsets.only(top: 10.0,left: 10.0,right: 10.0),
              child:new Container(
                padding: new EdgeInsets.all(10.0),
                width:350.0,
                height: 250.0,
                child: new Column(
                  children: <Widget>[
                  Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: new Text(
                    'Congratulations',
                    style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0,bottom: 10.0),
                      child: new Text(
                        'You have earned more shots',
                        style: new TextStyle(
                          fontSize: 15.0,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Center(
                    child: new Text(
                      'Enjoy your time at the '+widget.checkIn.feed.title,
                      style: new TextStyle(
                        fontSize: 13.0,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        new Text(
                          'Earned',
                          style: new TextStyle(
                              fontSize: 12.0,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, bottom: 5.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 6.0),
                            margin: EdgeInsets.only(top: 5.0),
                            decoration: BoxDecoration(
                                gradient:LinearGradient(
                                    colors: BottomWaveClipper.orangeGradients,
                                    begin: Alignment.topLeft,
                                    end: Alignment.center),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Text(widget.checkIn.feed.shots+" shots",
                                style: TextStyle(fontSize:10.0,color: Colors.white)),
                          ),
                        )

                      ],
                    ),
                    new InkWell(
                      onTap: () =>  Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => BottomNavBar()),
                              (Route<dynamic> route) => false
                      ),
                      child: new Container(
                        width: 120.0,
                        height: 50.0,
                        margin: EdgeInsets.only(top: 10.0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        decoration: new BoxDecoration(
                          gradient:LinearGradient(
                              colors:blueInGradients ,
                              begin: Alignment.topLeft,
                              end: Alignment.center),
                          border: new Border.all(color: Colors.white, width: 2.0),
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        child: new Center(child: new Text('Sweet', style: new TextStyle(fontSize: 18.0, color: Colors.white),),),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        )
      ),
    );
  }
  static List<Color> blueInGradients = [
    Color(0xFF0EDED2),
    Color(0xFF03A0FE),
  ];
}