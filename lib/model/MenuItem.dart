class MenuItem{
  String key,clientKey,name,description,inventoryType,categoryType,image,specialKey,date,size;
  double price;
  int quantity;
  bool archived;

  MenuItem({this.key,this.clientKey,this.name,this.description,this.date,this.size,this.image,this.inventoryType,this.categoryType,this.specialKey,this.price,this.quantity,this.archived});
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      key: json['key'],
      clientKey: json['clientKey'],
      name: json['name'],
      description: json['description'],
      date: json['date'],
      size: json['size'],
      image: json['image'],
      inventoryType: json['inventoryType'],
      categoryType: json['categoryType'],
      specialKey: json['specialKey'],
      price:json['price'],
      quantity:json['quantity'],
      archived:json['archived'],
    );
  }
}