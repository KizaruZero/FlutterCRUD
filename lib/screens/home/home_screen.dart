import 'package:flutter/material.dart';
import '../products/product_list_screen.dart';
import '../products/product_crud_screen.dart';
import 'widgets/product_navbar.dart';

class ProductHomeScreen extends StatefulWidget {
  const ProductHomeScreen({super.key});

  @override
  _ProductHomeScreenState createState() => _ProductHomeScreenState();
}

class _ProductHomeScreenState extends State<ProductHomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    ProductListScreen(),
    ProductCrudScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ProductNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
