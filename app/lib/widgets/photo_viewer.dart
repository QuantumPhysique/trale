import 'dart:io';
import 'package:flutter/material.dart';

class PhotoViewer extends StatefulWidget {

  const PhotoViewer({
    Key? key,
    required this.photoPaths,
    this.initialIndex = 0,
    this.onDelete,
  }) : super(key: key);
  final List<String> photoPaths;
  final int initialIndex;
  final Function(int)? onDelete;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onDelete?.call(_currentIndex);
              Navigator.pop(context); // Close viewer
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.photoPaths.length}'),
        actions: <Widget>[
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() => _currentIndex = index);
        },
        itemCount: widget.photoPaths.length,
        itemBuilder: (BuildContext context, int index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                File(widget.photoPaths[index]),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
