import 'dart:async';
import 'dart:convert';
// import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'Currency.dart';
import 'Controller.dart';

class MoneyConverter {
  // static const MethodChannel _channel = const MethodChannel('money_converter');

  static Future<double?> convert(Currency from, Currency to) async {
    try {
      if (from.type.isEmpty || to.type.isEmpty) {
        print("type or amount is missing");
        return null;
      }

      if (from.amount == null) {
        from.amount = 1.0;
      }
      String url =
          "${Controller.ENDPOINT}q=${from.type}_${to.type}&${Controller.API_KEY}&${Controller.COMPACT}";

      Response resp = (await Controller.getMoney(url))!;
      print(resp.body);

      double unitValue = jsonDecode(resp.body)['${from.type}_${to.type}'];

      double value = from.amount! * unitValue;

      return value;
    } catch (err) {
      print("convert err $err");
      return 0.0;
    }
  }
}
