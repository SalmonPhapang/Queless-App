class Location {
  String latitude,longitude;

  Location({this.latitude,this.longitude});
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json != null ? json['latitude'] : '0.0.0.0',
      longitude: json != null ? json['longitude']:  '0.0.0.0'
    );
  }
  Map<String, dynamic> toJson() => {
  'latitude': latitude,
  'longitude': longitude
};

}