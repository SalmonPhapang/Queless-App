class Category {
  String categoryKey,name,details,date,image;

  Category(this.categoryKey,this.name,this.details,this.date,this.image);
  Map<String, dynamic> toJson() => {
    'categoryKey': categoryKey,
    'name': name,
    'details': details,
    'date': date,
    'image':image
  };
}