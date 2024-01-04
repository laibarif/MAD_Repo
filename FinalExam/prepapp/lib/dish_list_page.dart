// dish_list_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DishListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dish List'),
      ),
      body: _buildDishList(),
    );
  }

  Widget _buildDishList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('dishes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var dishes = snapshot.data!.docs;

        List<Widget> dishWidgets = [];
        for (var dish in dishes) {
          var dishData = dish.data() as Map<String, dynamic>;

          // Adjust the widget layout based on your UI requirements
          var dishWidget = ListTile(
            title: Text(dishData['dishName']),
            subtitle: Text('Price: \$${dishData['dishPrice']}'),
            leading: Image.asset('images/img2.png', height: 40.0, width: 40.0),
            // Add other details as needed
          );

          dishWidgets.add(dishWidget);
        }

        return ListView(
          children: dishWidgets,
        );
      },
    );
  }
}
