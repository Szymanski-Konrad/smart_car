import 'package:flutter/material.dart';

class AppLifecycle extends StatefulWidget {
  const AppLifecycle({
    Key? key,
    required this.child,
    this.didResume,
    this.didBecomeInactive,
    this.didPause,
    this.didDetach,
  }) : super(key: key);

  final Widget child;

  /// The application is visible and responding to user input.
  final VoidCallback? didResume;

  /// The application is in an inactive state and is not receiving user input.
  final VoidCallback? didBecomeInactive;

  /// The application is not currently visible to the user, not responding to
  /// user input, and running in the background.
  final VoidCallback? didPause;

  /// The application is still hosted on a flutter engine but is detached from
  /// any host views.
  final VoidCallback? didDetach;

  @override
  _AppLifecycleState createState() => _AppLifecycleState();
}

class _AppLifecycleState extends State<AppLifecycle>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.didResume?.call();
        break;
      case AppLifecycleState.inactive:
        widget.didBecomeInactive?.call();
        break;
      case AppLifecycleState.paused:
        widget.didPause?.call();
        break;
      case AppLifecycleState.detached:
        widget.didDetach?.call();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
