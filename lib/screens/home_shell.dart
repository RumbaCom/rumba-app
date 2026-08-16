import 'package:flutter/material.dart';

import '../config.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';
import 'history_screen.dart';
import 'player_screen.dart';
import 'schedule_screen.dart';

/// Contenedor principal con la barra de pestanas abajo.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Radio', 'Programación', 'Sonó'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_index == 0 ? AppConfig.appName : _titles[_index]),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          PlayerScreen(),
          ScheduleScreen(),
          HistoryScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: RumbaColors.line, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: RumbaColors.bg,
          surfaceTintColor: Colors.transparent,
          indicatorColor: RumbaColors.surfaceHigh,
          height: 66,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.radio_outlined, color: RumbaColors.dim),
              selectedIcon: Icon(Icons.radio, color: RumbaColors.accent),
              label: 'Radio',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: RumbaColors.dim),
              selectedIcon:
                  Icon(Icons.calendar_today, color: RumbaColors.accent),
              label: 'Programas',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded, color: RumbaColors.dim),
              selectedIcon: Icon(Icons.history_rounded,
                  color: RumbaColors.accent),
              label: 'Sonó',
            ),
          ],
        ),
      ),
    );
  }
}
