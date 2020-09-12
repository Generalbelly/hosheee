import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/products_view_model.dart';

class RecentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // HomeViewModelから呼ばれてるから
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    final body = productsViewModel.products.length > 0
        ? GridView.count(
          controller: productsViewModel.scrollController,
          crossAxisCount: 2,
          children: productsViewModel.products.map((product) => Center(child: Text(product.name, style: Theme.of(context).textTheme.headline5))).toList())
        : SizedBox.shrink();
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
      body: body);
  }
}

