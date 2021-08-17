class Credentials{
  String userName,password,userKey;
  Credentials({this.userName,this.password,this.userKey});
  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
    'userKey': userKey
  };
}