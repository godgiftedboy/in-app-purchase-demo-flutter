import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class MyPaymentPage extends StatefulWidget {
  const MyPaymentPage({super.key});

  @override
  State<MyPaymentPage> createState() => _MyPaymentPageState();
}

class _MyPaymentPageState extends State<MyPaymentPage> {
  List<ProductDetails> products = [];
  @override
  void initState() {
    fetchProducts();
    super.initState();
  }

  void fetchProducts() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // cannot connect with stores. Update the UI accordingly.
    } else {
      final productsIds = <String>{
        'premium',
        'myfirstproduct',
        'myproduct',
      };
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(productsIds);
      if (response.notFoundIDs.isNotEmpty) {
        print(response.notFoundIDs);
        // Handle the error.
      }
      print(response.productDetails);
      setState(() {
        products = response.productDetails;
      });
    }
  }

  Future<void> purchaseItem(ProductDetails productDetails) async {
    PurchaseParam purchaseParam;

    purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: '',
    );

// For non-consumable e.g products/subscription
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);

// For consumable e.g game life
// await InAppPurchase.byConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: products.isEmpty
          ? const Center(
              child: Text("No Products"),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(products[index].title),
                  trailing: IconButton(
                      onPressed: () {
                        purchaseItem(products[index]);
                      },
                      icon: const Icon(Icons.shop)),
                );
              }),
    );
  }
}
