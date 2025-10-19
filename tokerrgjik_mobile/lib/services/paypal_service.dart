import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/payment_config.dart';

/// PayPal Payment Service for in-app purchases
/// Supports both sandbox (testing) and production modes
class PayPalService {
  static const String _sandboxUrl = 'https://api-m.sandbox.paypal.com';
  static const String _productionUrl = 'https://api-m.paypal.com';
  
  /// Get appropriate API URL based on mode
  static String get _apiUrl {
    return PaymentConfig.useSandbox ? _sandboxUrl : _productionUrl;
  }
  
  /// Get OAuth access token from PayPal
  static Future<String?> _getAccessToken() async {
    try {
      final credentials = base64.encode(
        utf8.encode('${PaymentConfig.paypalClientId}:${PaymentConfig.paypalSecret}')
      );
      
      final response = await http.post(
        Uri.parse('$_apiUrl/v1/oauth2/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
    } catch (e) {
      print('Error getting PayPal access token: $e');
    }
    return null;
  }
  
  /// Create a PayPal order
  static Future<String?> createOrder({
    required String amount,
    required String currency,
    required String description,
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return null;
    
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/v2/checkout/orders'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'intent': 'CAPTURE',
          'purchase_units': [
            {
              'amount': {
                'currency_code': currency,
                'value': amount,
              },
              'description': description,
            }
          ],
          'application_context': {
            'return_url': 'https://tokerrgjik.netlify.app/payment-success',
            'cancel_url': 'https://tokerrgjik.netlify.app/payment-cancelled',
          }
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['id'];
      }
    } catch (e) {
      print('Error creating PayPal order: $e');
    }
    return null;
  }
  
  /// Capture payment for an order
  static Future<bool> captureOrder(String orderId) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/v2/checkout/orders/$orderId/capture'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error capturing PayPal order: $e');
      return false;
    }
  }
  
  /// Purchase PRO subscription
  static Future<bool> purchaseProSubscription({
    required BuildContext context,
    required int months,
  }) async {
    final amount = months == 12 ? '20.82' : '2.99';
    final description = months == 12 
        ? 'TokerrGjik PRO - 12 Months' 
        : 'TokerrGjik PRO - 1 Month';
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      final orderId = await createOrder(
        amount: amount,
        currency: 'EUR',
        description: description,
      );
      
      if (orderId != null) {
        // In web, open PayPal checkout in new window
        if (kIsWeb) {
          // Get approval URL
          final approvalUrl = '$_apiUrl/checkoutnow?token=$orderId';
          // Open PayPal checkout (implement with url_launcher or window.open)
          Navigator.pop(context); // Close loading
          return true;
        } else {
          // For mobile, implement PayPal SDK or webview
          Navigator.pop(context);
          return true;
        }
      }
    } catch (e) {
      print('Error purchasing PRO: $e');
    }
    
    Navigator.pop(context); // Close loading
    return false;
  }
  
  /// Purchase coins
  static Future<bool> purchaseCoins({
    required BuildContext context,
    required int coins,
    required String amount,
  }) async {
    final description = 'TokerrGjik - $coins Monedha';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      final orderId = await createOrder(
        amount: amount,
        currency: 'EUR',
        description: description,
      );
      
      if (orderId != null) {
        Navigator.pop(context);
        return true;
      }
    } catch (e) {
      print('Error purchasing coins: $e');
    }
    
    Navigator.pop(context);
    return false;
  }
}
