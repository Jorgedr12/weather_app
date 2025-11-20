import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  static Future<String?> _getCustomText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_text') ?? 'Menú';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png'),
          ),
        ],
      ),
      body: body,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade400, Colors.blue.shade800],
                ),
              ),
              child: FutureBuilder<String?>(
                future: _getCustomText(),
                builder: (context, snapshot) {
                  final drawerText = snapshot.data ?? 'Menú';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), // Fondo sutil circular
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/Logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),                      
                      const SizedBox(height: 12),
                      Text(
                        drawerText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sunny),
              title: const Text('Inicio'),
              onTap: () {
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Agregar Ciudades'),
              onTap: () {
                context.go('/agregar_ciudades');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Créditos'),
              onTap: () {
                context.go('/creditos');
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}