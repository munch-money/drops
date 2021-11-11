import 'converter/money_converter.dart';
// import 'converter/Controller.dart';
import 'converter/Currency.dart';

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

  Future<void> update(String currency, String amt) async {
    if (amt.isEmpty) return;
    var amtd = double.parse(amt);
    await conversion(currency, amtd).then((value) {
      prcChg(currency);
    });
  }
}
