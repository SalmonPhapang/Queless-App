import 'package:flutter_app/model/Feed.dart';

class CheckIn{
   String key;
   String userKey;
   String feedKey;
   String date;
   Feed feed;

  CheckIn({this.key,this.userKey,this.date,this.feedKey});
   CheckIn.from({this.userKey,this.date,this.feedKey});

   factory CheckIn.fromJson(Map<String, dynamic> json) {
     return CheckIn(
       key: json['key'],
       userKey: json['userKey'],
       feedKey: json['feedKey'],
       date: json['date'],
     );
   }
   Map<String, dynamic> toJson() => {
     'userKey': userKey,
     'feedKey': feedKey,
     'date': date,
   };
}