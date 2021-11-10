import 'package:currency_converter/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:money_converter/money_converter.dart';
import 'package:money_converter/Currency.dart';
import 'package:share_everywhere/share_everywhere.dart';
import 'package:url_launcher/link.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:share_plus/share_plus.dart';

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
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Color(0xffa960ee),
            ),
          ),
        ),
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
    'Razorpay',
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Link(
                      uri: Uri.parse('https://app.munch.money/#/app'),
                      target: LinkTarget.blank,
                      builder: (context, followLink) => GestureDetector(
                        onTap: followLink,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 30.0, top: 8.0),
                            child: Align(
                                alignment: Alignment.center,
                                child: Assets.munchLogo.svg()),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 20.0, left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Which currency are you getting paid in?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
                                        var amt =
                                            double.parse(amtController.text);
                                        backend.update(cvalue, amt);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Which payment provider are you using?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
                                        var amt =
                                            double.parse(amtController.text);
                                        backend.update(cvalue, amt);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'How much are you going to receive?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                        minWidth: 280, maxWidth: 480),
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
                              padding: const EdgeInsets.only(
                                  left: 8.0, bottom: 20.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  var amt = double.parse(amtController.text);
                                  print(amt);
                                  backend.update(cvalue, amt).then((value) {
                                    setState(() {});
                                  });
                                },
                                child: Text('Calculate'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color(0xffa960ee),
                                  ),
                                ),
                              ),
                            ),
                            // ],
                            // ),
                            if (backend.charge != 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, bottom: 20.0),
                                child: Container(
                                  child: RichText(
                                    text: TextSpan(
                                      text: '${backend.paymentGateway} charges',
                                      // style: Theme.of(context)
                                      //     .textTheme
                                      //     .bodyText1!
                                      //     .copyWith(
                                      //         color: backend.charge != 0
                                      //             ? Colors.black
                                      //             : Colors.grey),
                                      children: <TextSpan>[
                                        // TextSpan(text: '${backend.paymentGateway} charges', style: TextStyle(fontWeight: FontWeight.normal)),
                                        TextSpan(
                                            text:
                                                ' ${(backend.charge * 100).toStringAsFixed(2)}%.',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text: ' You will be paying',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal)),
                                        TextSpan(
                                            text:
                                                ' $cvalue ${backend.foreignCharge.toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text:
                                                ' as payment fees. \n\nAfter charges, you will receive approx',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal)),
                                        TextSpan(
                                            text:
                                                ' $cvalue ${backend.foreignAfterfee}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text: ' which translates to',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal)),
                                        TextSpan(
                                            text:
                                                ' INR ${backend.domesticAfterConversion.toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text:
                                                '  as per current exchange rates',
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
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
                            // TextButton(
                            //   onPressed: () {
                            //     Share.share('Share this page https://example.com');
                            //   },
                            //   child: Text('Share this page'),
                            // ),
                            Row(
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 8.0),
                                // child:
                                ShareButton(shareController,
                                    'https://app.munch.money'),
                                IconButton(
                                    icon: Icon(Icons.copy),
                                    color: Colors.blue,
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text:
                                              "https://drop001-payment-x-gateway.web.app/#/"));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('Link Copied')));
                                      // ),
                                    })
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 50.0, left: 8.0),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Disclaimer:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          ' We don\'t claim these calculations to be exact but only approximations to give a rough estimate on the conservative end. These calculations may significantly vary depending on the bank account and financial platforms being used.',
                                      style: TextStyle(
                                        // fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
