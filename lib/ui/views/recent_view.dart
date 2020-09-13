import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/products_view_model.dart';
import 'package:wish_list/ui/views/product_view.dart';

class RecentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsViewModel = Provider.of<ProductsViewModel>(context);
    final body = productsViewModel.products.length > 0
        ? GridView.count(
          controller: productsViewModel.scrollController,
          crossAxisCount: 3,
          children: productsViewModel.products.map((product) => GestureDetector(
            child: product.imageUrl != null ?
              Image.network(product.imageUrl, fit: BoxFit.cover) :
              Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    product.name,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
              ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductView(product)));
            },
          )).toList())
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

