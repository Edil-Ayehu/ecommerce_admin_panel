import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_admin_panel/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class Product {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int stock;
  final String categoryId;

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.categoryId,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['Title'] ?? '',
      imageUrl: data['Thumbnail'] ?? '',
      price: (data['Price'] ?? 0.0).toDouble(),
      stock: data['Stock'] ?? 0,
      categoryId: data['CategoryId'] ?? '',
    );
  }
}

class CategoryProductScreen extends StatelessWidget {
  const CategoryProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Categories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Categories').snapshots(),
        builder: (context, categorySnapshot) {
          if (!categorySnapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<Category> categories = [];
            for (var doc in categorySnapshot.data!.docs) {
              categories.add(Category.fromFirestore(doc));
            }

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  // title: Text(category.id),
                  title: Text(category.name),
                  // subtitle: Text(category.parentId),
                  // leading: Image.asset('assets/avatar.jpg'),
                  trailing: category.isFeatured
                      ? Icon(Icons.star, color: Colors.yellow)
                      : null,
                  onTap: () {
                    Get.to(() => ProductsForCategoryScreen(
                          categoryId: category.id,
                          categoryName: category.name,
                        ));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ProductsForCategoryScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const ProductsForCategoryScreen(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Products')
            .where('CategoryId', isEqualTo: categoryId)
            .snapshots(),
        builder: (context, productSnapshot) {
          if (!productSnapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<Product> products = [];
            for (var doc in productSnapshot.data!.docs) {
              products.add(Product.fromFirestore(doc));
            }

            return products.isNotEmpty
                ? ListView.builder(
                    itemCount: products.length,
                    padding: EdgeInsets.only(left: 10, right: 10,top: 8),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        color: Colors.white,
                        child: ListTile(contentPadding: EdgeInsets.all(10),
                          leading: Image(
                              image:
                                  CachedNetworkImageProvider(product.imageUrl)),
                          title: Text(product.title),
                          subtitle: Text('\$${product.price.toString()}'),
                          trailing: Text('${product.stock} remain'),
                        ),
                      );
                    },
                  )
                : Center(child: Text("Empty"));
          }
        },
      ),
    );
  }
}
