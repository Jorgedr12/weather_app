import 'package:flutter/material.dart';
import 'app_scaffold.dart';

class CreditosPage extends StatelessWidget {
  const CreditosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: "Créditos",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Acerca del Proyecto",
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Weather App v1.0.0",
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              Text(
                "Tecnologías y APIs",
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildCreditTile(
                      context,
                      "Meteomatics",
                      "API de datos meteorológicos",
                      Icons.cloud,
                      Colors.blue,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildCreditTile(
                      context,
                      "OpenStreetMap",
                      "Datos cartográficos y geográficos",
                      Icons.map,
                      Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Equipo de Desarrollo",
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildMemberTile(context, "Jorge Duarte.", "Desarrollador"),
                    const Divider(height: 1, indent: 70),
                    _buildMemberTile(context, "Daniel Estrada.", "Desarrollador"),
                    const Divider(height: 1, indent: 70),
                    _buildMemberTile(context, "Kevin Martínez.", "Desarrollador"),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  "© Proyecto Flutter 2025",
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditTile(BuildContext context, String title, String subtitle, IconData icon, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildMemberTile(BuildContext context, String name, String role) {
    String initials = name.isNotEmpty ? name[0].toUpperCase() : "?";
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Text(initials),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(role),
    );
  }
}