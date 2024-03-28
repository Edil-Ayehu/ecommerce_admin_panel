import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot customer;

  const CustomerDetailsPage({Key? key, required this.customer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final addressesCollection = customer.reference.collection('Addresses');

    return Scaffold(
      appBar: AppBar(
        // title: Text("${customer['Username']}"),
        title: Text("Addresses of ${customer['Username']}"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: addressesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final addresses = snapshot.data!.docs;
          if (addresses.isNotEmpty) {
            return ListView.builder(
              itemCount: addresses.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final address = addresses[index];
                final addressData = address.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    //title: Text('Address: ${addressData['Street']}, ${addressData['City']}, ${addressData['State']}, ${addressData['Country']}'),
                    leading: const Text("Address"),
                    title: Column(
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.person),
                            Text("${addressData['Name']}"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.call),
                            Text("${addressData['PhoneNumber']}"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.public),
                            Text("${addressData['Country']}"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.apartment),
                            Text("${addressData['City']}"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.map),
                            Text("${addressData['Street']}"),
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                    trailing: addressData['SelectedAddress']
                        ? const Text("Selected")
                        : const Text("Not Selected"),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No Addresses Provided!"));
          }
        },
      ),
    );
  }
}
