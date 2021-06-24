import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

class Apis {
  static const String user = '/user/{uniqueRef}';
  static const String feed = '/feed/{uniqueRef}';
  static const String orders = '/user/{uniqueRef}';
}
@RestApi(baseUrl: "http://localhost:8080/")
abstract class ApiClient {

}