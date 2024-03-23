import 'package:ecommerce_admin_panel/pages/add_product_to_db.dart';
import 'package:ecommerce_admin_panel/pages/manage_products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 60.0, bottom: 40),
              child: Icon(Icons.shopping_cart_outlined, size: 100),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Product"),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const AddProductToDB());
              },
            ),
             ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Manage Products"),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const ManageProducts());
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text("Home", style: Theme.of(context).textTheme.headlineLarge,)),
    );
  }
}
