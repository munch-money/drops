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
//
//Currency rate to INR: 
//Payment amount (After conversion to INR): X
//Gateway Name fee: Y
//With fee: z
// Money in bank: A
//

class Backend {
  double processingFee = 0;
  double charge = 0;
  double afterConversion = 0;
  String paymentGateway = 'Paypal';
  double rate = 0;
  double moneyReceived = 0;

  Future<void> conversion(String currency, double amt) async {
    rate = await MoneyConverter.convert(Currency(currency), Currency(Currency.INR)) ?? 0;
    afterConversion = rate * amt;
    print(afterConversion);
  }

  void prcChg(String currency) {
    var pmtPlatform = paymentGateway;
    var finAmt = afterConversion;
    if (pmtPlatform == 'Paypal') {
      charge = 0.044;
    } else if (pmtPlatform == 'Stripe' && currency == 'USD') {
      charge = 0.029;
    } else if (pmtPlatform == 'Stripe' && (currency == 'EUR' || currency == 'GBP')) {
      charge = 0.034;
    } else if (pmtPlatform == 'Wise (Transferwise)') {
      charge = 0.0004;
    } else if (pmtPlatform == 'Razorpay') {
      charge = 0.03;
    } else if (pmtPlatform == 'Payoneer') {
      charge = 0.03;
    } else if (pmtPlatform == 'Direct Bank Transfer') {
      charge = 0.02;
    }
    print(charge);
    processingFee = charge * finAmt;
    print(processingFee);
    finalAmtReceived();
  }

  void finalAmtReceived() {
    moneyReceived = afterConversion - processingFee;
  }

  Future<void> update(String currency, double amt) async {
    await conversion(currency, amt).then((value) {
      prcChg(currency);
    });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var backend = Backend();

  double? convertedValue;
  String cvalue = 'USD';
  var amtController = TextEditingController();

  late int amt;

  var currencies = [
    'USD',
    'EUR',
    'GBP',
    'SGD',
  ];
  var paymentProcessors = ['Paypal', 'Payoneer', 'Stripe', 'Wise (Transferwise)', 'Direct Bank Transfer'];

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
                  items: currencies.map((String items) => DropdownMenuItem(value: items, child: Text(items))).toList(),
                  onChanged: (newValue) {
                    cvalue = newValue!;
                    if (amtController.text.isNotEmpty) {
                      var amt = double.parse(amtController.text);
                      backend.update(cvalue, amt).then((value) {
                        setState(() {});
                      });
                    }
                  },
                ),
                DropdownButton<String>(
                  value: backend.paymentGateway,
                  items: paymentProcessors
                      .map((String items) => DropdownMenuItem(value: items, child: Text(items)))
                      .toList(),
                  onChanged: (newValue) {
                    backend.paymentGateway = newValue!;
                    if (amtController.text.isNotEmpty) {
                      var amt = double.parse(amtController.text);
                      backend.update(cvalue, amt).then((value) {
                        setState(() {});
                      });
                    }
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
                  onPressed: () {
                    var amt = double.parse(amtController.text);
                    print(amt);
                    backend.update(cvalue, amt).then((value) {
                      setState(() {});
                    });
                  },
                  child: Text('Go'),
                ),
                // Card(
                //   child:
                //     Text('Initial amount (in INR) : ${backend.afterConversion}'),
                //   color: Colors.blue,
                //     ),
                Text('Initial amount (in INR) : ${backend.afterConversion.toStringAsFixed(2)}'),
                SizedBox(
                  height: 10,
                ),
                Text('Processing fee : ${backend.processingFee.toStringAsFixed(2)}'),
                SizedBox(
                  height: 10,
                ),
                Text('Final amount : ${backend.moneyReceived.toStringAsFixed(2)}'),
              ],
            )),
      ),
    );
  }
}
