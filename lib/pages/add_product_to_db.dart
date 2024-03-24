import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../models/product_model.dart';

class AddProductToDB extends StatefulWidget {
  const AddProductToDB({Key? key}) : super(key: key);

  @override
  _AddProductToDBState createState() => _AddProductToDBState();
}

class _AddProductToDBState extends State<AddProductToDB> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Product product = Product();

  final _categoryIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productTypeController = TextEditingController();
  final _skuController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _isFeaturedController = TextEditingController();
  final _imagesController = TextEditingController();

  final _brandIdController = TextEditingController();
  final _brandImageController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _brandIsFeaturedController = TextEditingController();
  final _productsCountController = TextEditingController();

  List<Map<String, dynamic>> _attributes = [];
  List<Map<String, dynamic>> _variations = [];

  bool _showSpinner = false; // Variable to control progress indicator

  void _submitForm() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();

      setState(() {
        _showSpinner = true; // Show progress indicator
      });

      product.categoryId = _categoryIdController.text;
      product.description = _descriptionController.text;
      product.productType = _productTypeController.text;
      product.sku = _skuController.text;
      product.thumbnail = _thumbnailController.text;
      product.title = _titleController.text;
      product.price = double.tryParse(_priceController.text) ?? 0.0;
      product.salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
      product.stock = int.tryParse(_stockController.text) ?? 0;
      product.isFeatured = _isFeaturedController.text.toLowerCase() == 'true';
      product.images = _imagesController.text.split(',');
      product.brand = {
        'Id': _brandIdController.text,
        'Image': _brandImageController.text,
        'Name': _brandNameController.text,
        'IsFeatured': _brandIsFeaturedController.text.toLowerCase() == 'true',
        'ProductsCount': int.tryParse(_productsCountController.text) ?? 0,
      };
      product.productAttributes = _attributes;
      product.productVariations = _variations;

      bool success = await _insertProduct(product);

      // Show modal bottom sheet indicating success or failure
      _showResultModal(success);

      setState(() {
        _showSpinner = false; // Hide progress indicator
      });

      // Clear input fields
      _clearInputFields();
    }
  }

  Future<bool> _insertProduct(Product product) async {
    try {
      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Add product to 'Products' collection
      DocumentReference productRef =
          await firestore.collection('Products').add(product.toMap());
      String productId =
          productRef.id; // Get the document ID of the newly added product

      // Add categoryId and productId to 'ProductCategory' collection
      await firestore.collection('ProductCategory').add({
        'categoryId': product.categoryId,
        'productId': productId,
      });

      // Add brandId and categoryId to 'BrandCategory' collection
      await firestore.collection('BrandCategory').add({
        'brandId': product.brand['Id'],
        'categoryId': product.categoryId,
      });

      debugPrint('Product inserted successfully!');
      return true; // Return true for success
    } catch (error) {
      debugPrint('Error inserting product: $error');
      return false; // Return false for failure
    }
  }

  void _showResultModal(bool success) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(36.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                  size: 36.0,
                ),
                const SizedBox(height: 12.0),
                Text(
                  success
                      ? 'Product inserted successfully!'
                      : 'Failed to insert product!',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: success ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearInputFields() {
    _categoryIdController.clear();
    _descriptionController.clear();
    _productTypeController.clear();
    _skuController.clear();
    _thumbnailController.clear();
    _titleController.clear();
    _priceController.clear();
    _salePriceController.clear();
    _stockController.clear();
    _isFeaturedController.clear();
    _imagesController.clear();
    _brandIdController.clear();
    _brandImageController.clear();
    _brandNameController.clear();
    _brandIsFeaturedController.clear();
    _productsCountController.clear();
    _attributes = [];
    _variations.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _categoryIdController,
                  decoration: const InputDecoration(labelText: 'Category ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter category ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _productTypeController.text.isNotEmpty
                      ? _productTypeController.text
                      : null,
                  decoration: const InputDecoration(labelText: 'Product Type'),
                  items: ['ProductType.single', 'ProductType.variable']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _productTypeController.text = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(labelText: 'SKU'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _thumbnailController,
                  decoration: const InputDecoration(labelText: 'Thumbnail'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _salePriceController,
                  decoration: const InputDecoration(labelText: 'Sale Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _isFeaturedController.text.isNotEmpty
                      ? _isFeaturedController.text
                      : null,
                  decoration: const InputDecoration(labelText: 'Is Featured'),
                  items: ['true', 'false'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _isFeaturedController.text = newValue!;
                    });
                  },
                ),

                const SizedBox(height: 10),
                TextFormField(
                  controller: _imagesController,
                  decoration: const InputDecoration(
                      labelText: 'Images (comma-separated)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _brandIdController,
                  decoration: const InputDecoration(labelText: 'Brand ID'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _brandImageController,
                  decoration: const InputDecoration(labelText: 'Brand Image'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _brandNameController,
                  decoration: const InputDecoration(labelText: 'Brand Name'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _brandIsFeaturedController.text.isNotEmpty
                      ? _brandIsFeaturedController.text
                      : null,
                  decoration: const InputDecoration(labelText: 'Brand IsFeatured'),
                  items: ['true', 'false'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _brandIsFeaturedController.text = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _productsCountController,
                  decoration:
                      const InputDecoration(labelText: 'Products Count'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _buildAttributesInput(),
                _buildVariationsInput(),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Insert Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttributesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Attributes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _attributes.length + 1,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == _attributes.length) {
              return OutlinedButton(
                onPressed: () {
                  setState(() {
                    _attributes.add({});
                  });
                },
                child: const Text('Add Attribute'),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    _attributes[index]['Name'] = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Values (comma-separated)'),
                  onChanged: (value) {
                    _attributes[index]['Values'] = value.split(',');
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVariationsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Variations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _variations.length + 1,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == _variations.length) {
              return OutlinedButton(
                onPressed: () {
                  setState(() {
                    _variations.add({});
                  });
                },
                child: const Text('Add Variation'),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Color'),
                  onChanged: (value) {
                    _variations[index]['AttributeValues'] ??= {};
                    _variations[index]['AttributeValues']['Color'] = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Size'),
                  onChanged: (value) {
                    _variations[index]['AttributeValues'] ??= {};
                    _variations[index]['AttributeValues']['Size'] = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    _variations[index]['Description'] = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Id'),
                  onChanged: (value) {
                    _variations[index]['Id'] = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Image'),
                  onChanged: (value) {
                    _variations[index]['Image'] = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'SKU'),
                  onChanged: (value) {
                    _variations[index]['SKU'] = value;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _variations[index]['Price'] = double.tryParse(value) ?? 0.0;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Sale Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _variations[index]['SalePrice'] =
                        double.tryParse(value) ?? 0.0;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _variations[index]['Stock'] = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
