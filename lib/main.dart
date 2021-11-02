import 'package:flutter/material.dart';
import 'package:money_converter/money_converter.dart';
import 'package:money_converter/Currency.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Currency Converter'),
    );
  }
}

class Backend {
  Future<double?> conversion(String currency, int amt, String pmtplat) async {
    double? rate = await MoneyConverter.convert(
        Currency(currency), Currency(Currency.INR));
    //   return convert(rate, amt, pmtplat, currency);
    // }

    // double convert(var rate, var amt, String pmtplat, var curr) {
    double convertedAmt = rate! * amt;
    print(convertedAmt);
    // prcChg(pmtplat, curr, convertedAmt);
    return convertedAmt;
    // return prcChg(pmtplat, curr, convertedAmt);
  }

  int prcChg(String pmtPlatform, String currency, double? finAmt) {
    var charge;
    if (pmtPlatform == 'Paypal') {
      charge = 0.044;
    } else if (pmtPlatform == 'Stripe' && currency == 'USD') {
      charge = 0.029;
    } else if (pmtPlatform == 'Stripe' &&
        (currency == 'EUR' || currency == 'GBP')) {
      charge = 0.034;
    } else if (pmtPlatform == 'Wise (Transferwise)') {
      charge = 0.0004;
    } else if (pmtPlatform == 'Razorpay') {
      charge = 0.03;
    } else if (pmtPlatform == 'Payoneer') {
      charge = 0.03;
    } else if (pmtPlatform == 'Direct Bank Deposit') {
      charge = 0.02;
    }
    print(charge);
    int fee = charge * finAmt;
    print(fee);
    return fee;
  }

  double finalAmt(var convertedAmt, var processingFee) {
    var finAmt = convertedAmt - processingFee;
    print(finAmt);
    return finAmt;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final backend = Backend();
  double? convertedValue;
  String cvalue = 'USD';
  String pvalue = 'Paypal';
  var amtController = TextEditingController();
  String? pmtPlatform;
  String? currency;
  int? charge;

  late int amt;

  var currencies = [
    'USD',
    'EUR',
    'GBP',
    'SGD',
  ];
  var paymentProcessors = [
    'Paypal',
    'Payoneer',
    'Stripe',
    'Wise (Transferwise)',
    'Direct Bank Transfer'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButton<String>(
                  value: cvalue,
                  items: currencies
                      .map((String items) =>
                          DropdownMenuItem(value: items, child: Text(items)))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      cvalue = newValue!;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: pvalue,
                  items: paymentProcessors
                      .map((String items) =>
                          DropdownMenuItem(value: items, child: Text(items)))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      pvalue = newValue!;
                    });
                  },
                ),
                Container(
                  constraints: BoxConstraints(minWidth: 280, maxWidth: 480),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: amtController,
                    decoration: const InputDecoration(
                      hintText: 'How much money are you receiving?',
                      labelText: 'Amount',
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () async {
                      amt = int.parse(amtController.text);
                      print(amt);
                      // pvalue = pmtPlatform;
                      backend.conversion(cvalue, amt, pvalue).then((value) {
                        setState(() {
                          convertedValue = value;
                          charge = backend.prcChg(pvalue, cvalue, convertedValue);
                        });
                      });
                    },
                    child: Text('Go')),
                if (convertedValue != null)
                  Text('Initial amount: $convertedValue'),
                Text('Processing charge : $charge'),
              ],
            )),
      ),
    );
  }
}
