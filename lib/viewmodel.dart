// import 'converter/money_converter.dart';
// import 'converter/Controller.dart';
// import 'converter/Currency.dart';
import 'package:conversion_fee/exchange_api_class.dart';
// import 'package:conversion_fee/exchange_api_model.dart';

class Backend {
  double processingFee = 0;
  double percentCharge = 0;
  double fixedCharge = 0;
  double foreignCharge = 0;
  double initialAmt = 0;
  double domesticAfterConversion = 0;
  double foreignAfterfee = 0;
  String paymentGateway = 'Paypal';
  double rate = 0;
  double moneyReceived = 0;

  Future<void> conversion(String currency, double amt) async {
    rate = await MoneyConverter.convert(currency, 'INR') ?? 0;
    domesticAfterConversion = rate * amt;
    initialAmt = amt;
    // print(domesticAfterConversion);
  }

  void prcChg(String currency) {
    // This function holds all charges for different platforms
    var pmtPlatform = paymentGateway;
    var finAmt = domesticAfterConversion;
    if (pmtPlatform == 'Paypal') {
      percentCharge = 0.044;
    } else if (pmtPlatform == 'Stripe' && currency == 'USD') {
      percentCharge = 0.029;
    } else if (pmtPlatform == 'Stripe' &&
        (currency == 'EUR' || currency == 'GBP')) {
      percentCharge = 0.034;
    } else if (pmtPlatform == 'Wise (Transferwise)') {
      percentCharge = 0.0053;
      fixedCharge = 4.78;
    } else if (pmtPlatform == 'Razorpay') {
      percentCharge = 0.03;
    } else if (pmtPlatform == 'Payoneer') {
      percentCharge = 0.03;
    } else if (pmtPlatform == 'Direct Bank Transfer') {
      percentCharge = 0.02;
    }
    // print(charge);
    processingFee = (percentCharge *
        finAmt) + fixedCharge; // This is the processing fee the user pays in the foreign currency
    foreignCharge = (initialAmt *
        percentCharge) + fixedCharge; // This is the initial amount the user would get after converting
    foreignAfterfee = initialAmt - foreignCharge; // This is the final amount the user gets after conversion and platform fee deductions
    // print(processingFee);
    finalAmtReceived();
  }

  void finalAmtReceived() {
    moneyReceived = domesticAfterConversion - processingFee;
  }

  Future<void> update(String currency, String amt) async {
    if (amt.isEmpty) return;
    var amtd = double.parse(amt);
    await conversion(currency, amtd).then((value) {
      prcChg(currency);
    });
  }
}
