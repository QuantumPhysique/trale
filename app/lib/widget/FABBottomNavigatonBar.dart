// This module is heavily copied and inspired from bizz84
// https://medium.com/coding-with-flutter/flutter-bottomappbar-navigation-with-fab-8b962bb55013
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Item for FABBottomAppBar
class FABBottomAppBarItem {
  /// constructor
  FABBottomAppBarItem({required this.iconData, required this.text});
  /// icon Data
  IconData iconData;
  /// string below Icon when active
  String text;
}

/// BottomAppBar with FloatingActionButton support
class FABBottomAppBar extends StatefulWidget {
  /// constructor
  FABBottomAppBar({
    required this.items,
    required this.onTabSelected,
    this.selectedIndex = 0,
  });
  /// items
  final List<FABBottomAppBarItem> items;
  /// selected tab
  final ValueChanged<int> onTabSelected;
  /// selected Index
  int selectedIndex;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

/// Define State
class FABBottomAppBarState extends State<FABBottomAppBar> {

  void _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      widget.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    Widget _buildTabItem({
      required FABBottomAppBarItem item,
      required int index,
      required ValueChanged<int> onPressed,
    }) {
      final bool isActive = widget.selectedIndex == index;
      final Color color = isActive
          ? Colors.amber
          : Colors.black38; //todo change colors!!!
      return Expanded(
        child: SizedBox(
          height: 80.0,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => onPressed(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(item.iconData, color: color),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 18,
                    child: Text(item.text),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    final List<Widget> items = List<Widget>.generate(
        widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });

    return BottomAppBar(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            0.0,
            0.0,
            MediaQuery.of(context).size.width / 3,
            0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items,
        ),
      ),
    );
  }

}
