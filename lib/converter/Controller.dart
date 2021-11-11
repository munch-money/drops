import 'package:http/http.dart' as http;

class Controller {
  // url
  static const String ENDPOINT = "https://free.currconv.com/api/v7/convert?";
  static const String COMPACT = "compact=ultra";
  // secret key
  static const String API_KEY = "apiKey=c4305511a1247bc45721";

// get money function used for call api and return value
  static Future<http.Response?> getMoney(url) async {
    try {
      print(url);
//cal api
      final response = await http.get(Uri.parse(url));
// get response
      return response;
    } catch (e) {
// catch er
      print("fetch get err $e");
    }
  }
}
