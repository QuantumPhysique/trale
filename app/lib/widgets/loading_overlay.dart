import 'package:flutter/material.dart';

class LoadingOverlay {
  static bool _isShowing = false;
  
  static void show(BuildContext context, {String message = 'Loading...'}) {
    if (_isShowing) return;
    _isShowing = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) => _isShowing = false);
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;
    try {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      // Ignore pop errors
    } finally {
      _isShowing = false;
    }
  }
}
