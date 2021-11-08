import 'package:currency_converter/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:money_converter/money_converter.dart';
import 'package:money_converter/Currency.dart';
import 'package:share_everywhere/share_everywhere.dart';
import 'package:share_plus/share_plus.dart';

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
  double foreignCharge = 0;
  double initialAmt = 0;
  double domesticAfterConversion = 0;
  double foreignAfterfee = 0;
  String paymentGateway = 'Paypal';
  double rate = 0;
  double moneyReceived = 0;

  Future<void> conversion(String currency, double amt) async {
    rate = await MoneyConverter.convert(
            Currency(currency), Currency(Currency.INR)) ??
        0;
    domesticAfterConversion = rate * amt;
    initialAmt = amt;
    print(domesticAfterConversion);
  }

  void prcChg(String currency) {
    var pmtPlatform = paymentGateway;
    var finAmt = domesticAfterConversion;
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
    } else if (pmtPlatform == 'Direct Bank Transfer') {
      charge = 0.02;
    }
    print(charge);
    processingFee = charge * finAmt;
    foreignCharge = initialAmt * charge;
    foreignAfterfee = initialAmt - foreignCharge;
    print(processingFee);
    finalAmtReceived();
  }

  void finalAmtReceived() {
    moneyReceived = domesticAfterConversion - processingFee;
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
  var paymentProcessors = [
    'Paypal',
    'Payoneer',
    'Stripe',
    'Wise (Transferwise)',
    'Direct Bank Transfer'
  ];

  @override
  Widget build(BuildContext context) {
    print(cvalue);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 600,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                      child: Align(
                          alignment: Alignment.center,
                          child: Assets.munchLogo.svg()),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('What currency are you getting paid in?'),
                          DropdownButton<String>(
                            value: cvalue,
                            items: currencies
                                .map((String items) => DropdownMenuItem(
                                    value: items, child: Text(items)))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                cvalue = newValue!;
                              });

                              if (amtController.text.isNotEmpty) {
                                var amt = double.parse(amtController.text);
                                backend.update(cvalue, amt);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Which payment provider are you using?'),
                          DropdownButton<String>(
                            value: backend.paymentGateway,
                            items: paymentProcessors
                                .map((String items) => DropdownMenuItem(
                                    value: items, child: Text(items)))
                                .toList(),
                            onChanged: (newValue) {
                              setState(() {
                                backend.paymentGateway = newValue!;
                              });
                              if (amtController.text.isNotEmpty) {
                                var amt = double.parse(amtController.text);
                                backend.update(cvalue, amt);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How much are you making?'),
                          Container(
                            constraints:
                                BoxConstraints(minWidth: 280, maxWidth: 480),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: amtController,
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment:MainAxisAlignment.center,
                    // children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                      child: TextButton(
                        onPressed: () {
                          var amt = double.parse(amtController.text);
                          print(amt);
                          backend.update(cvalue, amt).then((value) {
                            setState(() {});
                          });
                        },
                        child: Text('Go'),
                      ),
                    ),
                    // ],
                    // ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                      child: Container(
                        child: Text(
                          'By using ${backend.paymentGateway}, you\'ll be paying ${(backend.charge * 100).toStringAsFixed(2)}%, approx $cvalue ${backend.foreignCharge.toStringAsFixed(2)} as payment fees. \n\nAfter charges, you will receive approx $cvalue ${backend.foreignAfterfee} which translates to INR ${backend.domesticAfterConversion.toStringAsFixed(2)} as per current exchange rates',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  color: backend.charge != 0
                                      ? Colors.black
                                      : Colors.grey),
                        ),
                      ),
                    ),
                    //   Container(
                    //     child:
                    //         Text('Initial amount (in INR) : ${backend.domesticAfterConversion.toStringAsFixed(2)}'),
                    //   ),
                    //   // Text('Initial amount (in INR) : ${backend.domesticAfterConversion.toStringAsFixed(2)}'),
                    //   SizedBox(
                    //     height: 10,
                    //   ),
                    //   Text('Processing fee (in INR) : ${backend.processingFee.toStringAsFixed(2)} (${(backend.charge*100).toStringAsFixed(2)}%)'),
                    //   SizedBox(
                    //     height: 10,
                    //   ),
                    //   Text('Final amount (in INR) : ${backend.moneyReceived.toStringAsFixed(2)}'),
                    // ],
                    SizedBox(
                      height: 80,
                    ),
                    TextButton(
                      onPressed: () {
                        Share.share('Share this page https://example.com');
                      },
                      child: Text('Share this page'),
                    ),
                    ShareButton(shareController, 'https://app.munch.money')
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

ShareController shareController = ShareController(
    title: "Share on:",
    elevatedButtonText: Text("Share"),
    networks: [
      // SocialConfig(type: "facebook", appId: "your-facebook-app-id"),
      SocialConfig(type: "linkedin"),
      SocialConfig(type: "twitter"),
    ],
  );
