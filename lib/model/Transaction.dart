class Transaction{
  String key,orderKey,transactionID,status,taxReference;
  Transaction({this.key,this.orderKey,this.transactionID,this.status,this.taxReference});
  Map<String, dynamic> toJson() => {
    'key': key,
    'orderKey': orderKey,
    'transactionID': transactionID,
    'status': status,
    'taxReference': taxReference
  };
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      key: json['key'],
      orderKey: json['orderKey'],
      transactionID: json['transactionID'],
      status: json['status'],
      taxReference: json['taxReference'],
    );
  }
}