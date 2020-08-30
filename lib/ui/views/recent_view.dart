import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/product_view_model.dart';

class RecentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/products/create');
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: productViewModel.products.map((product) => Center(
          child: Text(
            product.name,
            style: Theme.of(context).textTheme.headline5,
          )
        )).toList(),
      ),
    );
  }
}

