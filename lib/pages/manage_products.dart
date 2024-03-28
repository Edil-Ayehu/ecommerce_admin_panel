// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_admin_panel/pages/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({Key? key}) : super(key: key);

  @override
  _ManageProductsState createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  bool _isSaving = false; // Track whether saving is in progress

  void _showDeleteConfirmationDialog(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(productId); // Delete the product
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $error')),
      );
    }
  }

  Future<void> _editProduct(
      String productId, Map<String, dynamic> productData) async {
    final titleController = TextEditingController(text: productData['Title']);
    final descriptionController =
        TextEditingController(text: productData['Description']);
    final categoryIdController =
        TextEditingController(text: productData['CategoryId']);
    final priceController =
        TextEditingController(text: productData['Price'].toString());
    final salePriceController =
        TextEditingController(text: productData['SalePrice'].toString());
    final stockController =
        TextEditingController(text: productData['Stock'].toString());
    final thumbnailController =
        TextEditingController(text: productData['Thumbnail']);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: categoryIdController,
                      decoration:
                          const InputDecoration(labelText: 'Category Id'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: salePriceController,
                      decoration:
                          const InputDecoration(labelText: 'Sale Price'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: stockController,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: thumbnailController,
                      decoration: const InputDecoration(labelText: 'Thumbnail'),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      setState(() {
                        _isSaving = true; // Set saving state to true
                      });
                      try {
                        await FirebaseFirestore.instance
                            .collection('Products')
                            .doc(productId)
                            .update({
                          'Title': titleController.text,
                          'Description': descriptionController.text,
                          'CategoryId': categoryIdController.text,
                          'Price': double.parse(priceController.text),
                          'SalePrice': double.parse(salePriceController.text),
                          'Stock': int.parse(stockController.text),
                          'Thumbnail': thumbnailController.text,
                        });
                        Get.snackbar("Success", "Product updated successfully",
                            backgroundColor: Colors.lightBlueAccent,
                            snackPosition: SnackPosition.BOTTOM,
                            titleText: const Text(
                              'Success',
                              style: TextStyle(color: Colors.white),
                            ),
                            messageText: const Text(
                              'Product updated successfully!',
                              style: TextStyle(color: Colors.white),
                            ));
                        Navigator.of(context).pop(); // Close the dialog
                      } catch (error) {
                        Get.snackbar(
                            "Error", "Failed to update product: $error",
                            backgroundColor: Colors.lightBlueAccent,
                            snackPosition: SnackPosition.BOTTOM,
                            titleText: const Text(
                              'Error',
                              style: TextStyle(color: Colors.white),
                            ),
                            messageText: Text(
                              'Failed to update product: $error',
                              style: const TextStyle(color: Colors.white),
                            ));
                      } finally {
                        setState(() {
                          _isSaving = false; // Set saving state to false
                        });
                      }
                    },
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToProductDetailsPage(Map<String, dynamic> productData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(productData: productData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Products').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  _navigateToProductDetailsPage(data);
                },
                child: ListTile(
                  title: Text(data['Title'],
                      style: Theme.of(context).textTheme.headlineSmall),
                  subtitle: Text('Price: \$${data['Price']}'),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CachedNetworkImage(
                        imageUrl: data['Thumbnail'],
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // leading: CachedNetworkImage(imageUrl: '${data["Thumbnail"]}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editProduct(document.id, data);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(document.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
