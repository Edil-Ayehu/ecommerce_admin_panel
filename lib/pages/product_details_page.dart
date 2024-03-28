import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsPage({Key? key, required this.productData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productData['Title']),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: '${productData["Thumbnail"]}',
              placeholder: (context, url) => const CircularProgressIndicator(
                  color: Colors.lightBlueAccent),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${productData['Description']}'),
                  Text('Price: \$${productData['Price']}'),
                  Text('Sale Price: \$${productData['SalePrice']}'),
                  Text('Stock: ${productData['Stock']}'),
                  Text('Brand: ${productData['Brand']['Name']}'),
                  Text('Category Id: ${productData['CategoryId']}'),
                  Text('Product Type: ${productData['ProductType']}'),
                ],
              ),
            ),

            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
