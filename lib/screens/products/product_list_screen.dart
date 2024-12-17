import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';
import '../../services/product_service.dart';
import 'product_crud_screen.dart';
import '../../widgets/product_card.dart'; // Updated import for the new card design

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _products;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _products = ProductService().getProducts();
  }

  Future<void> _deleteProduct(int productId) async {
    try {
      await ProductService().deleteProduct(productId);
      final updatedProducts = await ProductService().getProducts();
      setState(() {
        _products = Future.value(updatedProducts);
      });
      _showSnackBar('Product deleted successfully', isError: false);
    } catch (e) {
      print('Detailed error deleting product: $e');
      if (e is http.Response) {
        print('Status code: ${e.statusCode}');
        print('Response body: ${e.body}');
      }
      _showSnackBar('Failed to delete product', isError: true);
    }
  }

  Future<void> _refreshProducts() async {
    try {
      setState(() {
        _products = ProductService().getProducts();
      });
      await _products; // Wait for the products to load
    } catch (e) {
      print('Error refreshing products: $e');
      _showSnackBar('Failed to refresh products', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int productId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteProduct(productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KizaruShop',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.orange[700],
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductCrudScreen()),
                ).then((result) {
                  if (result == true) {
                    // Explicitly check for true to ensure product was created/updated
                    _refreshProducts();
                  }
                });
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _refreshProducts, // Use the new method
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive Grid Calculation
            int crossAxisCount;
            if (constraints.maxWidth >= 1200) {
              // Desktop: 3 cards per row
              crossAxisCount = 3;
            } else if (constraints.maxWidth >= 600) {
              // Tablet/Medium: 2 cards per row
              crossAxisCount = 2;
            } else {
              // Mobile: 1 card per row
              crossAxisCount = 1;
            }
            return FutureBuilder<List<Product>>(
              future: _products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load products',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final products = snapshot.data!;

                  // Empty State Handling
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.grey[400],
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a new product to get started',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _products = ProductService().getProducts();
                      });
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio:
                            0.65, // Adjust for better card proportions
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductCrudScreen(product: product),
                              ),
                            ).then((_) {
                              setState(() {
                                _products = ProductService().getProducts();
                              });
                            });
                          },
                          onDelete: () => _confirmDelete(product.id),
                          isLoading: _isLoading,
                        );
                      },
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
