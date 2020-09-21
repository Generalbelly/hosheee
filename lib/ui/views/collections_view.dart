import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/collections_view_model.dart';
import 'package:wish_list/ui/views/collection_view.dart';

class CollectionsView extends StatelessWidget {

  _showSnackBar(BuildContext context, String message, Function cb) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () => cb(context),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final collectionsViewModel = Provider.of<CollectionsViewModel>(context);
    if (collectionsViewModel.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(context, collectionsViewModel.message, (ctx) {
          Scaffold.of(ctx).hideCurrentSnackBar();
        });
        collectionsViewModel.message = null;
      });
    }

    final body = collectionsViewModel.collections.length > 0
        ?
    CustomScrollView(
      controller: collectionsViewModel.scrollController,
      slivers: <Widget>[
        SliverGrid(
          delegate: SliverChildBuilderDelegate((c, i) {
            final collection = collectionsViewModel.collections[i];
            return GestureDetector(
              child: collection.imageUrl != null
                  ?
              Image.network(
                collection.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace) {
                  return Icon(Icons.error_outline);
                },
                // loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                //   WidgetsBinding.instance.addPostFrameCallback((_) {
                //     if (loadingProgress == null) {
                //       collectionsViewModel.imageLoadingDone(collection.imageUrl);
                //     }
                //   });
                //   return child;
                // },
              )
                  :
              Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    collection.name,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionView(collection)));
              },
            );
          },
            childCount: collectionsViewModel.collections.length,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
        ),
        SliverToBoxAdapter(
            child: collectionsViewModel.requestStatusManager.isLoading()
                ?
            Container(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator()),
                  ),
                )
            )
                :
            SizedBox.shrink()
        ),
      ],
    )
        :
    Container(
      child: Center(
          child: collectionsViewModel.requestStatusManager.isLoading()
              ?
          SizedBox(width: 32, height: 32, child: CircularProgressIndicator())
              :
          Text("No collection saved yet.")
      ),
    );
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
        body: body);
  }
}

