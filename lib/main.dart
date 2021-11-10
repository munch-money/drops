import 'package:currency_converter/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'viewmodel.dart';
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
                                      backend.paymentGateway = newValue!;

                                      if (amtController.text.isNotEmpty) {
                                        var amt =
                                            double.parse(amtController.text);
                                        backend
                                            .update(cvalue, amt)
                                            .then((value) => setState(() {}));
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
                                                ' INR ${backend.moneyReceived.toStringAsFixed(2)}',
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
                                ShareButton(
                                    shareController, 'https://app.munch.money'),
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
