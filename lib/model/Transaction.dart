class Transaction{
  String key,orderKey,message,status,taxReference;
  Transaction({this.key,this.orderKey,this.message,this.status,this.taxReference});
  Map<String, dynamic> toJson() => {
    'key': key,
    'orderKey': orderKey,
    'message': message,
    'status': status,
    'taxReference': taxReference
  };
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      key: json['key'],
      orderKey: json['orderKey'],
      message: json['message'],
      status: json['status'],
      taxReference: json['taxReference'],
    );
  }
}