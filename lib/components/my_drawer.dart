import 'package:ecommerce_admin_panel/pages/banners_page.dart';
import 'package:ecommerce_admin_panel/pages/customers_page.dart';
import 'package:ecommerce_admin_panel/pages/manage_products.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 60.0, bottom: 40),
            child: Icon(Icons.shopping_cart_outlined, size: 100),
          ),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text("Dashboard"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.announcement),
                title: const Text("Banners"),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const BannersPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text("Categories"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text("Brands"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text("Orders"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text("Customers"),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const CustomersPage());
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.add),
              //   title: const Text("Add Product"),
              //   onTap: () {
              //     Navigator.pop(context);
              //     Get.to(() => const AddProductToDB());
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.manage_history),
                title: const Text("Manage Products"),
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const ManageProducts());
                },
              ),
            ],
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const ManageProducts());
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
