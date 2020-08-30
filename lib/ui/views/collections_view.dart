import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/collection_view_model.dart';

class CollectionsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final collectionViewModel = Provider.of<CollectionViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/collections/create');
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: collectionViewModel.collections.map((collection) => Center(
          child: Text(
            collection.name,
            style: Theme.of(context).textTheme.headline5,
          )
        )).toList(),
      ),
    );
  }
}

