import 'package:flutter/material.dart';

import 'screens/aprender.dart';
import 'screens/asistente.dart';
import 'screens/calidad.dart';
import 'screens/cobrar.dart';
import 'screens/pedidos.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const LedPagoApp());
}

class LedPagoApp extends StatelessWidget {
  const LedPagoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CODE UNCA',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const HomeShell(),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;

  static const _pages = <Widget>[
    CobrarScreen(),
    PedidosScreen(),
    CalidadScreen(),
    AsistenteScreen(),
    AprenderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: fondoGradiente),
      child: Scaffold(
        body: IndexedStack(index: _i, children: _pages),
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppColors.bosqueProfundo,
          selectedIndex: _i,
          onDestinationSelected: (v) => setState(() => _i = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'Cobrar'),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Pedidos',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_camera_outlined),
              label: 'Calidad',
            ),
            NavigationDestination(
              icon: Icon(Icons.record_voice_over_outlined),
              label: 'Asistente',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              label: 'Aprender',
            ),
          ],
        ),
      ),
    );
  }
}
