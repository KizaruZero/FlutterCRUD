import 'package:flutter/material.dart';

class ProductNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const ProductNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Product List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add Product',
        ),
      ],
    );
  }
}
