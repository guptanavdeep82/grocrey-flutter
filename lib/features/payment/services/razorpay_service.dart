import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class RazorpayService {
  late Razorpay _razorpay;
  final Function(String paymentId, String orderId, String signature) onSuccess;
  final Function(String message) onFailure;

  RazorpayService({required this.onSuccess, required this.onFailure}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  void startPayment({
    required String key,
    required int amount,
    required String contact,
    required String email,
    required String description,
    required String orderId,
    required String name,
    String? paymentRequestId,
  }) {
    String digits = contact.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 12 && digits.startsWith('91')) {
      digits = digits.substring(digits.length - 10);
    }
    String? validContact = RegExp(r'^[6-9][0-9]{9}$').hasMatch(digits) ? digits : null;

    var options = {
      'key': key,
      'amount': amount,
      'currency': 'INR',
      'name': 'SAB Grocery',
      'description': description,
      'order_id': orderId,
      'prefill': {
        if (validContact != null) 'contact': validContact,
        if (email.contains('@')) 'email': email,
        'name': name
      },
      'notes': {
        'payment_request_id': paymentRequestId,
      },
      'theme': {
        'color': '#A6284D'
      }
    };

    try {
      debugPrint('Razorpay options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay catch error: $e');
      onFailure(e.toString());
    }

  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success!');
    debugPrint('Payment ID: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');

    onSuccess(
      response.paymentId ?? '',
      response.orderId ?? '',
      response.signature ?? '',
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String message = "Payment Failed";
    if(response.code == Razorpay.PAYMENT_CANCELLED) {
      message = "Payment Cancelled";
    } else if(response.code == Razorpay.NETWORK_ERROR) {
      message = "Network Error";
    } else {
      message = "Payment Error: ${response.message}";
    }
    onFailure(message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onFailure("External Wallet Selected: ${response.walletName}");
  }
}
