import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/ui/view_models/product_view_model.dart';
import 'package:hosheee/ui/views/product_view.dart';
import 'package:hosheee/ui/views/progress_modal.dart';

class CreateProductView extends StatelessWidget {

  static const routeName = 'fetch-url-metadata';

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
    final productViewModel = Provider.of<ProductViewModel>(context);
    final nextButtonColor = productViewModel.errors['websiteUrl'] == null && productViewModel.product.websiteUrl != null ? Colors.lightBlue : null;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44.0),
        child: AppBar(
          title: Text('New Item'),
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        if (productViewModel.message != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(context, productViewModel.message, (ctx) {
              Scaffold.of(ctx).hideCurrentSnackBar();
            });
            productViewModel.message = null;
          });
        }
        if (productViewModel.webViewShouldOpen) {
          return Stack(
            children: [
              WebView(
                initialUrl: productViewModel.product.websiteUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  productViewModel.webViewController = webViewController;
                },
                javascriptChannels: <JavascriptChannel>[
                  JavascriptChannel(
                    name: 'Hosheee',
                    onMessageReceived: (JavascriptMessage message) async {
                      await productViewModel.fillWithMetadata(message.message);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductView(),
                        ),
                      );
                    }),
                ].toSet(),
                onPageFinished: (String url) async {
                  productViewModel.webViewController.evaluateJavascript(
                    'setTimeout(function() {Hosheee.postMessage(document.documentElement.outerHTML); return;}, 1000);'
                  );
                },
              ),
              Opacity(
                child: ModalBarrier(color: Colors.black),
                opacity: 0.3,
              ),
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        return ProgressModal(
          isLoading: productViewModel.requestStatusManager.isLoading(),
          child: Center(
              child: Container(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Website URL',
                        hintText: 'Website URL',
                        errorText: productViewModel.errors['websiteUrl'],
                      ),
                      initialValue: productViewModel.product.websiteUrl,
                      onChanged: (value) => productViewModel.setWebsiteUrl(value),
                      onEditingComplete: () async {
                        productViewModel.webViewShouldOpen = true;
                        // if (await productViewModel.fillWithMetadata()) {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => ProductView(),
                        //     ),
                        //   );
                        // }
                      },
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
                          productViewModel.webViewShouldOpen = true;
                          // if (await productViewModel.fillWithMetadata()) {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => ProductView(),
                          //     ),
                          //   );
                          // }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        );
      }),
    );
  }

}

