import 'package:flutter/material.dart';

class ProgressModal extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  ProgressModal({
    Key key,
    @required this.isLoading,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      print("come");
      return child;
    }
    print("called");
    return new Stack(
      alignment: Alignment.center,
      children: [
        child,
        Opacity(
          child: ModalBarrier(color: Colors.black),
          opacity: 0.3,
        ),
        CircularProgressIndicator(),
      ],
    );
  }
}