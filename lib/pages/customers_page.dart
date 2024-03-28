import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_admin_panel/pages/customer_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final customers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              final data = customer.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: ()=> Get.to(()=> CustomerDetailsPage(customer: customer)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: data['ProfilePicture'] != null && data['ProfilePicture'] != ''
                        ? CachedNetworkImageProvider(data['ProfilePicture'])
                        : const AssetImage('assets/avatar.jpg') as ImageProvider,
                  ),
                  title: Text('${data['FirstName']} ${data['LastName']}'),
                  subtitle: Text('${data['Username']} - ${data['Email']}'),
                  trailing: Text('${data['PhoneNumber']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


