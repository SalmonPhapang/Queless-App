class NotificationDTO {
   String userKey;
   String title;
   String message;
   String topic;
   String userType;
   bool isTopic;
   NotificationDTO({this.userKey,this.title,this.message,this.isTopic,this.userType});
   Map<String, dynamic> toJson() => {
     'userKey': userKey,
     'title': title,
     'message': message,
     'userType': userType,
     'isTopic': isTopic,
   };
}