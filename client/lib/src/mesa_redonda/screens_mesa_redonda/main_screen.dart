import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/add.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/home.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/label.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/screens_mesa_redonda/profile.dart';

import 'notifications.dart';

class MesaRedondaMainScreen extends StatefulWidget {
  const MesaRedondaMainScreen({super.key});

  @override
  MesaRedondaMainScreenState createState() => MesaRedondaMainScreenState();
}

class MesaRedondaMainScreenState extends State<MesaRedondaMainScreen> {
  late PageController _pageController;
  int _page = 0;

  List icons = [
    Icons.home,
    Icons.label,
    Icons.add,
    Icons.notifications,
    Icons.person,
  ];

  List pages = [
    const Home(),
    const Label(
      key: Key('label'),
    ),
    const Add(
      key: Key("23423423"),
    ),
    const Notifications(
      key: Key('nofnotifications'),
    ),
    const Profile(
      key: Key('dfgdfgd'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: List.generate(5, (index) => pages[index]),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // SizedBox(width: 7),
            buildTabIcon(0),
            buildTabIcon(1),
            buildTabIcon(3),
            buildTabIcon(4),
            // SizedBox(width: 7),
          ],
        ),
        color: Theme.of(context).primaryColor,
        shape: const CircularNotchedRectangle(),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        child: const Icon(
          Icons.add,
        ),
        onPressed: () => _pageController.jumpToPage(2),
      ),
    );
  }

  // void navigationTapped(int page) {
  //    _pageController.jumpToPage(page);
  //  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  buildTabIcon(int index) {
    return Container(
      margin:
          EdgeInsets.fromLTRB(index == 3 ? 30 : 0, 0, index == 1 ? 30 : 0, 0),
      child: IconButton(
        icon: Icon(
          icons[index],
          size: 24.0,
        ),
        color: _page == index
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).textTheme.bodySmall?.color,
        onPressed: () => _pageController.jumpToPage(index),
      ),
    );
  }
}
