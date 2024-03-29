import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BannerData {
  final String imageUrl;
  final String targetScreen;
  final bool active;

  BannerData({
    required this.imageUrl,
    required this.targetScreen,
    required this.active,
  });
}

class BannersPage extends StatefulWidget {
  const BannersPage({Key? key}) : super(key: key);

  @override
  _BannersPageState createState() => _BannersPageState();
}

class _BannersPageState extends State<BannersPage> {
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _targetScreenController = TextEditingController();
  bool _active = false;

  void _saveNewBannerToFirestore(
      String imageUrl, String targetScreen, bool active, BuildContext context) {
    try {
      // Get an instance of FirebaseFirestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference the "Banners" collection
      CollectionReference banners = firestore.collection('Banners');

      // Add a new document to the "Banners" collection
      banners.add({
        'ImageUrl': imageUrl,
        'TargetScreen': targetScreen,
        'Active': active,
      }).then((value) {
        // If the document is added successfully
        print('New banner added with ID: ${value.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New banner added successfully')),
        );
      }).catchError((error) {
        // If an error occurs while adding the document
        print('Error adding banner: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add new banner: $error')),
        );
      });
    } catch (error) {
      print('Error saving banner data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving banner data: $error')),
      );
    }
  }

  bool _isValidUrl(String url) {
    // Use a regular expression to check if the URL format is valid
    // This is a basic example, you may need to adjust it based on your specific requirements
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banners'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Banners').snapshots(),
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
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No data found.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot banner = snapshot.data!.docs[index];
              BannerData bannerData = BannerData(
                imageUrl: banner['ImageUrl'],
                targetScreen: banner['TargetScreen'],
                active: banner['Active'],
              );
              return ListTile(
                title: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: bannerData.imageUrl,
                    errorWidget: (context, url, error) {
                      // Check if the URL is null or empty
                      if (bannerData.imageUrl == null ||
                          bannerData.imageUrl.isEmpty) {
                        // If the URL is empty or null, display a custom message
                        return const Text('Empty URL');
                      } else if (_isValidUrl(bannerData.imageUrl)) {
                        // If the URL is valid, display a default error icon
                        return const Icon(Icons.error);
                      } else {
                        // If the URL is invalid, display a custom error message
                        return const Text('Invalid URL');
                      }
                    },
                    fit: BoxFit.cover,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Screen: ${bannerData.targetScreen}'),
                    Text('Active: ${bannerData.active}'),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBannerDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Banner'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _targetScreenController,
                      decoration:
                          const InputDecoration(labelText: 'Target Screen'),
                    ),
                    CheckboxListTile(
                      title: const Text('Active'),
                      value: _active,
                      onChanged: (bool? value) {
                        setState(() {
                          _active = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _saveNewBannerToFirestore(
                      _imageUrlController.text.trim(),
                      _targetScreenController.text.trim(),
                      _active,
                      context,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
