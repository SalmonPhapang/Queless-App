import 'dart:collection';

import 'package:flutter_app/model/Client.dart';

class Feed{
  String key,title,summary,date,image,shots,clientKey;
  bool video,status;
  Client client;

  Feed({this.key,this.clientKey,this.title,this.summary,this.date,this.image,this.shots,this.status,this.video,this.client});
  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      key:json['key'] ,
      clientKey: json['clientKey'],
      title: json['title'],
      summary: json['summary'],
      date: json['date'],
      image: json['image'],
      shots: json['shots'],
      status: json['status'],
      video: json['video'],
      client: Client.fromJson(json['client']),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'clientKey': clientKey,
    'title': title,
    'summary': summary,
    'date': date,
    'image': image,
    'shots': shots,
    'status': status,
    'video': video,
    'client': client,
  };
}