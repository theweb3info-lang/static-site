import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../models/pomodoro_session.dart';

class TrayService with TrayListener {
  static final TrayService instance = TrayService._init();
  
  TrayService._init();

  Future<void> initialize() async {
    await trayManager.setIcon('assets/icons/tray_icon.png');
    
    final menu = Menu(
      items: [
        MenuItem(
          key: 'show',
          label: 'Show Pomodoro',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'start',
          label: 'Start',
        ),
        MenuItem(
          key: 'pause',
          label: 'Pause',
        ),
        MenuItem(
          key: 'stop',
          label: 'Stop',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'quit',
          label: 'Quit',
        ),
      ],
    );

    await trayManager.setContextMenu(menu);
    trayManager.addListener(this);
  }

  Future<void> updateTrayTitle(String time, bool isRunning, SessionType sessionType) async {
    String icon;
    switch (sessionType) {
      case SessionType.focus:
        icon = isRunning ? '🍅' : '⏸️';
        break;
      case SessionType.shortBreak:
      case SessionType.longBreak:
        icon = '☕';
        break;
    }
    
    await trayManager.setTitle('$icon $time');
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        windowManager.show();
        windowManager.focus();
        break;
      case 'quit':
        windowManager.destroy();
        break;
      // Timer controls will be connected to the provider
    }
  }

  Future<void> dispose() async {
    trayManager.removeListener(this);
  }
}
