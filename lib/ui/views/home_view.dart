import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hosheee/ui/view_models/home_view_model.dart';

class HomeView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    if (!homeViewModel.isInitial() && homeViewModel.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/sign-in');
      });
    }
    return Scaffold(
      body: Center(
        child: homeViewModel.contents.elementAt(homeViewModel.selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            title: Text('Recent'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            title: Text('Collections'),
          ),
        ],
        currentIndex: homeViewModel.selectedIndex,
        //selectedItemColor: Colors.amber[800],
        onTap: (index) => { homeViewModel.selectedIndex = index },
      ),
    );
  }
}
