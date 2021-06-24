class Location {
  String latitude,longitude;

  Location({this.latitude,this.longitude});
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}