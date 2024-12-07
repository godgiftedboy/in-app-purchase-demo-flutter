import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:demo_purchase/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.navKey});
  final GlobalKey<NavigatorState> navKey;

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    super.initState();
  }

  @override
  void dispose() {
    // Always cancel on Dispose
    _subscription.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    // ignore: avoid_function_literals_in_foreach_calls
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        log("Payment pendigng");
        // _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print(purchaseDetails.error);

          // _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await verifyPurchase(purchaseDetails);
          if (valid) {
            // _deliverProduct(purchaseDetails);
          } else {
            // _handleInvalidPurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {
    //! Backend logic to verify purchase here

    final data = purchaseDetails.verificationData.serverVerificationData;
    log("verification token here $data");

    final source = purchaseDetails.verificationData.source;
    final local = purchaseDetails.verificationData.localVerificationData;
    final localobject =
        jsonDecode(purchaseDetails.verificationData.localVerificationData);

    final productId = localobject['productId'];
    final packageName = localobject['packageName'];

    log("source here $source");
    log("local here $local");
    log("productId here $productId");
    log("pakagename here $packageName");

    //package verification in backend required orderId, productId, packageName and purchaseToken

    // if (Platform.isAndroid) {
    //   final localDataVerification = json.decode(purchaseDetails.verificationData.localVerificationData) as Map<String, dynamic>;
    //   final orderId = localDataVerification['orderId'] as String;
    //   final productId = localDataVerification['productId'] as String;
    //   final packageName = localDataVerification['packageName'] as String;
    //   final token = localDataVerification['purchaseToken'] as String;
    // } else if (Platform.isIOS) {
    //   final appStorePurchaseDetails = purchaseDetails as AppStorePurchaseDetails;

    // //You’ll need to import in_app_purchase_storekit/in_app_purchase_storekit.dart to be able to use AppStorePurchaseDetails since it access IOS platform specific purchase properties

    //   final paymentToken = appStorePurchaseDetails.verificationData.localVerificationData;
    //   final transitionId = appStorePurchaseDetails.skPaymentTransaction.originalTransaction?.transactionIdentifier;
    //   final storeId = purchaseDetails.productID;
    // }

    return Future<bool>.value(true);
  }

  @override
  Widget build(BuildContext context) {
    // Lock the app's orientation to portrait only
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //Unfocus the keyboard when click outside the form field
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        navigatorKey: widget.navKey,
        home: const MyPaymentPage(),
      ),
    );
  }
}
