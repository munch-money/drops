import 'dart:convert';
import 'package:http/http.dart';

class MoneyConverter {
  static Future<double?> convert(String from, String to) async {
    final String postsURL =
        'https://v6.exchangerate-api.com/v6/c9842d0872efe585d0feee42/pair/$from/$to';
    try {
      if (from.isEmpty || to.isEmpty) {
        print("type or amount is missing");
        return null;
      }
      Response res = await get(Uri.parse(postsURL));
      print(res.body);
      if (res.statusCode == 200) {
        String data = res.body;
        double unitValue = jsonDecode(data)['conversion_rate'];
        print(unitValue);
        return unitValue;
      }
    } catch (err) {
      print("convert err $err");
      return 0.0;
    }
  }
}
