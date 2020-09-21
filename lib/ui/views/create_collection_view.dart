import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wish_list/ui/view_models/collection_view_model.dart';
import 'package:wish_list/ui/views/collection_view.dart';

class CreateCollectionView extends StatelessWidget {

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
    final collectionViewModel = Provider.of<CollectionViewModel>(context);
    final nextButtonColor = collectionViewModel.errors['name'] == null && collectionViewModel.collection.name != null ? Colors.lightBlue : null;
    return Scaffold(
      appBar: AppBar(
        title: Text('New Collection'),
        actions: <Widget>[
          // FlatButton(
          //   child: Text('Next'),
          //   onPressed: () {
          //     if (collectionViewModel.errors['name'] != null) {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => CollectionView(collectionViewModel.collection),
          //         ),
          //       );
          //     }
          //   },
          // ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        if (collectionViewModel.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(context, collectionViewModel.message, (ctx) {
              Scaffold.of(ctx).hideCurrentSnackBar();
            });
            collectionViewModel.message = null;
          });
        }
        return Center(
          child: Container(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Name',
                    errorText: collectionViewModel.errors['name'],
                  ),
                  onChanged: (value) => collectionViewModel.setName(value),
                ),
                SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: double.infinity,
                  child: FlatButton(
                    color: nextButtonColor,
                    child: Text('Next'),
                    onPressed:  () async {
                      if (collectionViewModel.errors['name'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollectionView(collectionViewModel.collection),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

