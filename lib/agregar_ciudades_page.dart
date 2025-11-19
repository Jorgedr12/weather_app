import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'app_scaffold.dart';

class AgregarCiudadesPage extends StatefulWidget {
  const AgregarCiudadesPage({super.key});
  @override
  State<AgregarCiudadesPage> createState() => _AgregarCiudadesPageState();
}

class _AgregarCiudadesPageState extends State<AgregarCiudadesPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List ciudadData = [];
  double selectedLat = 29.0948207;
  double selectedLon = -110.9692202;
  int? selectedIndex;
  List<Map<String, dynamic>> ciudadesGuardadas = [];
  bool isSearching = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarCiudades();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarCiudades() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = prefs.getStringList('ciudades') ?? [];
    setState(() {
      ciudadesGuardadas = ciudadesString
          .map((ciudad) => json.decode(ciudad) as Map<String, dynamic>)
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Mis Ciudades",
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              if (isSearching) _buildSearchResults(),
              if (!isSearching) _buildCiudadesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Buscar ciudad...',
                hintStyle: TextStyle(color: Colors.white60),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    isSearching = false;
                    ciudadData = [];
                    selectedIndex = null;
                  });
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _buscarCiudad(value);
                }
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  isSearching = false;
                  ciudadData = [];
                  selectedIndex = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: Column(
        children: [
          if (ciudadData.isEmpty && !isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, color: Colors.white70, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron resultados',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (ciudadData.isNotEmpty) ...[
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: ciudadData.length,
                  itemBuilder: (context, index) {
                    final ciudadInfo = ciudadData[index];
                    final isSelected = selectedIndex == index;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                        title: Text(
                          _obtenerNombreCiudad(ciudadInfo['display_name']),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          _obtenerUbicacion(ciudadInfo['display_name']),
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            selectedLat = double.parse(ciudadInfo['lat']);
                            selectedLon = double.parse(ciudadInfo['lon']);
                            _mapController.move(
                              LatLng(selectedLat, selectedLon),
                              13,
                            );
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(selectedLat, selectedLon),
                      initialZoom: 13,
                      maxZoom: 18,
                      minZoom: 3,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.weather_app',
                      ),
                      if (selectedIndex != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(selectedLat, selectedLon),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedIndex != null
                      ? () {
                          final ciudadInfo = ciudadData[selectedIndex!];
                          _agregarCiudad(
                            ciudadInfo['display_name'],
                            double.parse(ciudadInfo['lat']),
                            double.parse(ciudadInfo['lon']),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    disabledBackgroundColor: Colors.white.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_location_alt),
                      const SizedBox(width: 8),
                      Text(
                        'Agregar Ciudad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildCiudadesList() {
    if (isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (ciudadesGuardadas.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white70, size: 80),
              const SizedBox(height: 20),
              Text(
                'No hay ciudades guardadas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Busca y agrega tu primera ciudad',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ciudadesGuardadas.length,
        onReorder: _reordenarCiudades,
        itemBuilder: (context, index) {
          final ciudad = ciudadesGuardadas[index];
          return _buildCiudadCard(ciudad, index);
        },
      ),
    );
  }

  Widget _buildCiudadCard(Map<String, dynamic> ciudad, int index) {
    final nombre = ciudad['nombre'] ?? 'Desconocido';
    final temperatura = ciudad['temperatura'];
    final simboloClima = ciudad['simbolo_clima'];
    final lat = ciudad['latitud'] ?? 0.0;
    final lon = ciudad['longitud'] ?? 0.0;

    return Container(
      key: ValueKey(ciudad['nombre']),
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('${ciudad['nombre']}_$index'),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        confirmDismiss: (direction) async {
          return await _mostrarDialogoEliminar(nombre, index);
        },
        onDismissed: (direction) {
          _eliminarCiudad(index);
        },
        child: InkWell(
          onTap: () {
            _mostrarMapaCiudad(nombre, lat, lon);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.drag_handle, color: Colors.white70),
                  const SizedBox(width: 8),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _obtenerIconoClima(simboloClima),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              title: Text(
                _obtenerNombreCiudad(nombre),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                _obtenerUbicacion(nombre),
                style: TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (temperatura != null)
                    Text(
                      '${temperatura.toStringAsFixed(1)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.white70),
                    onPressed: () => _mostrarDialogoEliminar(nombre, index),
                    tooltip: 'Eliminar ciudad',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _mostrarDialogoEliminar(String nombre, int index) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text("Eliminar Ciudad"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¿Estás seguro de eliminar?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _obtenerNombreCiudad(nombre),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Esta acción no se puede deshacer.",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.delete, size: 20),
              label: const Text("Eliminar", style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop(true);
                _eliminarCiudad(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarMapaCiudad(String nombre, double lat, double lon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _MapaBottomSheet(nombre: nombre, lat: lat, lon: lon),
    );
  }

  IconData _obtenerIconoClima(int? simbolo) {
    if (simbolo == null) return Icons.cloud;
    switch (simbolo) {
      case 1:
        return Icons.wb_sunny;
      case 2:
      case 3:
        return Icons.wb_cloudy;
      case 4:
        return Icons.cloud;
      case 101:
        return Icons.nights_stay;
      case 102:
      case 103:
      case 104:
        return Icons.cloud;
      default:
        return Icons.cloud;
    }
  }

  String _obtenerNombreCiudad(String displayName) {
    final partes = displayName.split(',');
    return partes.isNotEmpty ? partes[0].trim() : displayName;
  }

  String _obtenerUbicacion(String displayName) {
    final partes = displayName.split(',');
    if (partes.length > 1) {
      return partes.sublist(1).join(',').trim();
    }
    return '';
  }

  Future<void> _buscarCiudad(String nombreCiudad) async {
    setState(() {
      isSearching = true;
      isLoading = true;
    });

    final url =
        'https://nominatim.openstreetmap.org/search?q=$nombreCiudad&format=json&addressdetails=1&limit=10';
    debugPrint('URL de búsqueda: $url');

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {'User-Agent': 'WeatherApp/1.0 (Flutter)'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado');
            },
          );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        debugPrint('Ciudades encontradas: ${data.length}');
        setState(() {
          ciudadData = data;
          selectedIndex = null;
          isLoading = false;
        });
      } else {
        debugPrint('Error en respuesta: ${response.statusCode}');
        if (!mounted) return;
        setState(() {
          isLoading = false;
          ciudadData = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al buscar: código ${response.statusCode}'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al buscar ciudad: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        ciudadData = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error de conexión: ${e.toString().substring(0, 50)}...',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _agregarCiudad(String nombre, double lat, double lon) async {
    // Verificar si la ciudad ya existe
    final existe = ciudadesGuardadas.any(
      (ciudad) => ciudad['nombre'] == nombre,
    );

    if (existe) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Text('La ciudad ya existe en tu lista'),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> listaciudadesGuardadas = prefs.getStringList('ciudades') ?? [];

    String ciudadString = json.encode({
      'nombre': nombre,
      'latitud': lat,
      'longitud': lon,
    });

    listaciudadesGuardadas.add(ciudadString);
    await prefs.setStringList('ciudades', listaciudadesGuardadas);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('${_obtenerNombreCiudad(nombre)} agregada')),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Limpiar búsqueda y recargar lista
    _searchController.clear();
    setState(() {
      isSearching = false;
      ciudadData = [];
      selectedIndex = null;
    });
    await _cargarCiudades();
  }

  Future<void> _eliminarCiudad(int index) async {
    final ciudadEliminada = ciudadesGuardadas[index];
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      ciudadesGuardadas.removeAt(index);
    });

    final ciudadesString = ciudadesGuardadas
        .map((c) => json.encode(c))
        .toList();
    await prefs.setStringList('ciudades', ciudadesString);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_obtenerNombreCiudad(ciudadEliminada['nombre'])} eliminada',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _reordenarCiudades(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final ciudad = ciudadesGuardadas.removeAt(oldIndex);
      ciudadesGuardadas.insert(newIndex, ciudad);
    });

    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = ciudadesGuardadas
        .map((c) => json.encode(c))
        .toList();
    await prefs.setStringList('ciudades', ciudadesString);
  }
}

// Widget para mostrar el mapa en un bottom sheet
class _MapaBottomSheet extends StatefulWidget {
  final String nombre;
  final double lat;
  final double lon;

  const _MapaBottomSheet({
    required this.nombre,
    required this.lat,
    required this.lon,
  });

  @override
  State<_MapaBottomSheet> createState() => _MapaBottomSheetState();
}

class _MapaBottomSheetState extends State<_MapaBottomSheet> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _obtenerNombreCiudad(widget.nombre),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _obtenerUbicacion(widget.nombre),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Mapa
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(widget.lat, widget.lon),
                        initialZoom: 13,
                        maxZoom: 18,
                        minZoom: 3,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.weather_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(widget.lat, widget.lon),
                              width: 50,
                              height: 50,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Controles de zoom
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Column(
                        children: [
                          _buildZoomButton(
                            icon: Icons.add,
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(
                                _mapController.camera.center,
                                currentZoom + 1,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildZoomButton(
                            icon: Icons.remove,
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(
                                _mapController.camera.center,
                                currentZoom - 1,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Coordenadas
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lat: ${widget.lat.toStringAsFixed(4)}°',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              'Lon: ${widget.lon.toStringAsFixed(4)}°',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.blue.shade700),
        onPressed: onPressed,
        iconSize: 24,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  String _obtenerNombreCiudad(String displayName) {
    final partes = displayName.split(',');
    return partes.isNotEmpty ? partes[0].trim() : displayName;
  }

  String _obtenerUbicacion(String displayName) {
    final partes = displayName.split(',');
    if (partes.length > 1) {
      return partes.sublist(1).join(',').trim();
    }
    return '';
  }
}
