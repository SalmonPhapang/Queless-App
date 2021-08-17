import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/DetailsPage.dart';
import 'package:flutter_app/OrderClientListPage.dart';
import 'package:flutter_app/menu/Menu.dart';
import 'package:flutter_app/model/Client.dart';
import 'package:flutter_app/model/Feed.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_app/service/AddressService.dart';
import 'package:flutter_app/service/ClientService.dart';
import 'package:flutter_app/service/FeedService.dart';
import 'package:flutter_app/widgets/video_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:localstorage/localstorage.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
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
  var _scrollController = ScrollController();
  FeedService _feedService = new FeedService();
  ClientService _clientService = new ClientService();
  AddressService _addressService = new AddressService();
  final storage = new LocalStorage('Posts.json');
  DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
  //DateFormat get _dateFormat => DateFormat('EEE, d MMM yyyy HH:mm:ss', 'en_US');
  int pageSize = 20;
  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Perform your task
        // getPostsPaginated(postList.first.key, pageSize);
        // setState(() {});
      }
    });
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
      backgroundColor: Colors.grey[100],
      appBar: topAppBar,
      body:Center(
          child: FutureBuilder(
        future: getPosts(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return InViewNotifierList(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
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
                      child: PostsUI(isInView,index,postList.elementAt(index).clientKey,postList.elementAt(index).title, postList.elementAt(index).summary, postList.elementAt(index).client.address.city, postList.elementAt(index).client.address.suburb, postList.elementAt(index).client.profileUrl,postList.elementAt(index).image,postList.elementAt(index).date,postList.elementAt(index).video,Map())
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

  // Future<Set> fetchFromCache() async {
  //   await storage.ready;
  //   storage.clear();
  //   List<dynamic> cache = storage.getItem("feed");
  //   if(cache == null){
  //      return getPostsPaginatedLimit(pageSize);
  //   }else{
  //     for(var individualKey in cache){
  //       postList.add(individualKey);
  //     }
  //   return getPostsPaginated(postList.first.key, pageSize);
  //   }
  // }
  Future<List> getPosts() async{
    postList = await _feedService.fetchAll();
    for(var post in postList){
      post.client.address = await _addressService.fetchByClientKey(post.client.key);
    }
    postList.sort((a,b) => format.parse(b.date).compareTo(format.parse(a.date)));
    await storage.ready;
    storage.setItem("feed", postList);
    return postList;
  }
  // Future<Set> getPostsPaginatedLimit(int pageSize) async{
  //   List<Feed> data = await _feedService.fetchPaginateLimit(pageSize);
  //   for(var post in data){
  //     post.client.address = await _addressService.fetchByClientKey(post.client.key);
  //   }
  //   postList.addAll(data.toSet());
  //   await storage.ready;
  //   storage.setItem("feed", postList);
  //   return postList;
  // }

  // Future<Set> getPostsPaginated(String startAt,int pageSize) async{
  //   List<Feed> data = await _feedService.fetchPaginate(startAt,pageSize);
  //   for(var post in data){
  //     post.client.address = await _addressService.fetchByClientKey(post.client.key);
  //   }
  //   postList.addAll(data.toSet());
  //   await storage.ready;
  //   storage.setItem("feed", postList);
  //   return postList;
  // }

  Widget PostsUI(bool inView,int index,String clientKey,String name,String bio,String city,String suburb,String profileUrl,String image,String date,bool isVideo,Map menu){
    return new Card(
      elevation: 5.0,
      shadowColor: Colors.grey[100],
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
                              fit: BoxFit.cover,
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
        new Container(
          margin: EdgeInsets.all(10.0),
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
    _scrollController.dispose();
    super.dispose();
  }
  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 3), curve: Curves.linear);
  }
 Widget playVideo(String imageUrl) {
   _controller = VideoPlayerController.network(
       imageUrl)
     ..initialize().then((_) {
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