class Product {
  String categoryId = '';
  String description = '';
  String productType = '';
  String sku = '';
  String thumbnail = '';
  String title = '';
  double price = 0.0;
  double salePrice = 0.0;
  int stock = 0;
  bool isFeatured = false;
  List<String> images = [];
  Map<String, dynamic> brand = {};
  List<Map<String, dynamic>> productAttributes = [];
  List<Map<String, dynamic>> productVariations = [];

  // Convert Product object to Map
  Map<String, dynamic> toMap() {
    return {
      'CategoryId': categoryId,
      'Description': description,
      'ProductType': productType,
      'SKU': sku,
      'Thumbnail': thumbnail,
      'Title': title,
      'Price': price,
      'SalePrice': salePrice,
      'Stock': stock,
      'IsFeatured': isFeatured,
      'Images': images,
      'Brand': brand,
      'ProductAttributes': productAttributes,
      'ProductVariations': productVariations.map((variation) {
        variation['AttributeValues'] ??= {};
        return variation;
      }).toList(),
    };
  }
  
}