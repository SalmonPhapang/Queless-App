import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/DetailsPage.dart';
import 'package:flutter_app/OrderClientListPage.dart';
import 'package:flutter_app/menu/Menu.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_app/model/Feed.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_app/service/ClientService.dart';
import 'package:flutter_app/service/FeedService.dart';
import 'package:flutter_app/widgets/video_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:video_player/video_player.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'utils/BottomWaveClipper.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Feed> postList = [];
  List<Client> clients = [];
  VideoPlayerController _controller;
  ChewieController _chewieController;
  Future<void> _futureController;
  FeedService _feedService = new FeedService();
  ClientService _clientService = new ClientService();
  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1,
      gradient: LinearGradient(colors: [Colors.cyan,Colors.indigo]),
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: Image.asset('assets/images/take-away.png'),
          iconSize: 5.0,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage(title: "Catalogue")),);
          },
        )
      ],
    );//AppBar
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: topAppBar,
      body:Center(child: FutureBuilder(
        future: getPosts(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return InViewNotifierList(
              scrollDirection: Axis.vertical,
              initialInViewIds: ['0'],
              isInViewPortCondition:
                  (double deltaTop, double deltaBottom, double viewPortDimension) {
                return deltaTop < (0.5 * viewPortDimension) &&
                    deltaBottom > (0.5 * viewPortDimension);
              },
              itemCount: postList.length,
              builder: (BuildContext context, int index) {
                return InViewNotifierWidget(id: '$index', builder: (BuildContext context, bool isInView, Widget child){
                  return Container(
                      alignment: Alignment.center,
                      child: PostsUI(isInView,index,postList[index].clientKey,postList[index].title, postList[index].summary, postList[index].client.address.city, postList[index].client.address.suburb, postList[index].image,postList[index].image,postList[index].date,postList[index].video,Map())
                  );
                });
              },
            );
          }else if(snapshot.hasError){
            return Text("${snapshot.error}");
          }else{
            return SpinKitCubeGrid(color: Color(0xffff5722));
          }
        },
      )
      ),
    );//Scarfold

  }

  Future<Client> findClientByFeed(Feed feed) async {
    Client client = await _clientService.fetchByKey(feed.clientKey);
  }
  Future<List> getPosts() async{
    postList = await _feedService.fetchAll();
    return postList;
  }

  Widget PostsUI(bool inView,int index,String clientKey,String name,String bio,String city,String suburb,String profileUrl,String image,String date,bool isVideo,Map menu){
    return new Card(
      elevation: 15.0,
      child: new Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10.0,),
            isVideo != true ?  Stack(
              children: <Widget>[
                //Center(child: Image.asset('assets/loader2.gif',height:60.0,fit: BoxFit.fitWidth,)),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(title: "Details",uniqueKey: clientKey,)),);
                  },
                  child:new Image(
                    height: 350,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(image),
                  ),
                    ),

              ],
            ) : new Container(
                height: 300,
                width: double.infinity,
                child: VideoWidget(play:inView,url: image)
            ),
            new Column(
              crossAxisAlignment:CrossAxisAlignment.start ,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(title: "Details",uniqueKey: clientKey,)),);
                        },
                        child : Container(
                          width: 65.0,
                          height: 65.0,
                          margin: EdgeInsets.all(8.0),
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.contain,
                              image: CachedNetworkImageProvider(profileUrl),
                            ),
                          ),
                        )),
                    new Container(
                        child: new Text(
                          name,
                          style: new TextStyle(
                              fontSize: 17.0,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.start,
                        )
                    ),
                    new Container(
                        margin: EdgeInsets.all(8.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.ltr,
                          children: <Widget>[
                            new Text(
                              suburb,
                              style: new TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.start,
                            ),
                            new Text(
                              city,
                              style: new TextStyle(
                                  fontSize: 10.0,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold
                              ),
                              textAlign: TextAlign.start,
                            )
                          ],
                        )
                    ),
                  ],
                ),//Row
              ],
            ),

            SizedBox(height: 10.0,),
        new Container(
          margin: EdgeInsets.all(8.0),
        child:  new Text(
            bio,
          style: new TextStyle(
              fontSize: 10.0,
              color: Colors.grey,
              fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.justify,
        ))


          ],//[Widget]
        ),//Column
      ),//Container
    );//Cards ,
  }
  @override
  void dispose() {
    super.dispose();
//    _controller.dispose();
//    _chewieController.dispose();
  }
 Widget playVideo(String imageUrl) {
   _controller = VideoPlayerController.network(
       imageUrl)
     ..initialize().then((_) {
       // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
       setState(() {});
     });
   _futureController = _controller.initialize();
   return new Stack(
     children: <Widget>[
       FutureBuilder(
         future: _futureController,
         builder: (context,snapshot){
           if(snapshot.connectionState == ConnectionState.done){
             return new Center(
                 child: _controller.value.isInitialized
                     ? AspectRatio(
                   aspectRatio: _controller.value.aspectRatio,
                   child: VideoPlayer(_controller),
                 ) : Container()
             );
           }
         },
       ),
       new Center(
         child: RaisedButton(onPressed: (){
           setState(() {
             if(_controller.value.isPlaying){
               _controller.pause();
             } else
               _controller.play();
           });
         },
         child: Icon(_controller.value.isPlaying ? Icons.pause:Icons.play_arrow),),
       )
     ],
   );
 }
  Widget playChewieVideo(String imageUrl) {
    _controller = VideoPlayerController.network(imageUrl);
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 3 / 2,
      placeholder: Image.asset('assets/loader2.gif',fit: BoxFit.cover,),
      autoPlay: false,
      looping: false,
      showControls: true,
      autoInitialize: true,
    );

    final playerWidget = Chewie(
      controller: _chewieController,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => print("Container pressed"), // handle your onTap here
        child: playerWidget,
      ),
    );
  }

}