// ClimaCarouselView.dart
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart'; // Necesario para PointerDeviceKind

class ClimaCarouselView extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> ciudadesGuardadas;
  final Function(Map<String, dynamic>) actualizaClima;

  const ClimaCarouselView({
    Key? key,
    required this.ciudadesGuardadas,
    required this.actualizaClima,
  }) : super(key: key);

  @override
  State<ClimaCarouselView> createState() => _ClimaCarouselViewState();
}

class _ClimaCarouselViewState extends State<ClimaCarouselView> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  IconData _obtenerIconoClima(int simbolo) {
    switch (simbolo) {
      case 0:
        return WeatherIcons.na;

      case 1:
        return WeatherIcons.day_sunny;
      case 101:
        return WeatherIcons.night_clear;

      case 2:
        return WeatherIcons.day_sunny_overcast;
      case 102:
        return WeatherIcons.night_alt_cloudy_gusts;

      case 3:
        return WeatherIcons.day_cloudy;
      case 103:
        return WeatherIcons.night_partly_cloudy;

      case 4:
        return WeatherIcons.cloud;
      case 104:
        return WeatherIcons.night_cloudy;

      // 5 / 105 – Rain
      case 5:
        return WeatherIcons.rain;
      case 105:
        return WeatherIcons.night_alt_rain;

      // 6 / 106 – Rain and snow / sleet
      case 6:
        return WeatherIcons.rain_mix;
      case 106:
        return WeatherIcons.night_alt_rain_mix;

      // 7 / 107 – Snow
      case 7:
        return WeatherIcons.snow;
      case 107:
        return WeatherIcons.night_alt_snow;

      // 8 / 108 – Rain shower
      case 8:
        return WeatherIcons.showers;
      case 108:
        return WeatherIcons.night_alt_showers;

      // 9 / 109 – Snow shower
      case 9:
        return WeatherIcons.snow_wind;
      case 109:
        return WeatherIcons.night_alt_snow_wind;

      // 10 / 110 – Sleet shower
      case 10:
        return WeatherIcons.sleet;
      case 110:
        return WeatherIcons.night_alt_sleet;

      // 11 / 111 – Light Fog
      case 11:
        return WeatherIcons.fog;
      case 111:
        return WeatherIcons.night_fog;

      // 12 / 112 – Dense Fog
      case 12:
        return WeatherIcons.fog;
      case 112:
        return WeatherIcons.night_fog;

      // 13 / 113 – Freezing rain
      case 13:
        return WeatherIcons.rain_mix;
      case 113:
        return WeatherIcons.night_alt_rain_mix;

      // 14 / 114 – Thunderstorms
      case 14:
        return WeatherIcons.thunderstorm;
      case 114:
        return WeatherIcons.night_alt_thunderstorm;

      // 15 / 115 – Drizzle
      case 15:
        return WeatherIcons.sprinkle;
      case 115:
        return WeatherIcons.night_alt_sprinkle;

      // 16 / 116 – Sandstorm
      case 16:
        return WeatherIcons.sandstorm;
      case 116:
        return WeatherIcons.sandstorm;

      default:
        return WeatherIcons.na;
    }
  }

  String _obtenerDescripcionClima(int simbolo) {
    switch (simbolo) {
      case 0:
        return 'Sin datos';

      case 1:
        return 'Despejado';
      case 101:
        return 'Despejado (noche)';

      case 2:
        return 'Mayormente despejado';
      case 102:
        return 'Mayormente despejado (noche)';

      case 3:
        return 'Parcialmente nublado';
      case 103:
        return 'Parcialmente nublado (noche)';

      case 4:
        return 'Nublado';
      case 104:
        return 'Nublado (noche)';

      case 5:
        return 'Lluvia';
      case 105:
        return 'Lluvia (noche)';

      case 6:
        return 'Lluvia y nieve / aguanieve';
      case 106:
        return 'Lluvia y nieve / aguanieve (noche)';

      case 7:
        return 'Nieve';
      case 107:
        return 'Nieve (noche)';

      case 8:
        return 'Chubascos';
      case 108:
        return 'Chubascos (noche)';

      case 9:
        return 'Chubascos de nieve';
      case 109:
        return 'Chubascos de nieve (noche)';

      case 10:
        return 'Chubascos de aguanieve';
      case 110:
        return 'Chubascos de aguanieve (noche)';

      case 11:
        return 'Neblina ligera';
      case 111:
        return 'Neblina ligera (noche)';

      case 12:
        return 'Neblina densa';
      case 112:
        return 'Neblina densa (noche)';

      case 13:
        return 'Lluvia helada';
      case 113:
        return 'Lluvia helada (noche)';

      case 14:
        return 'Tormentas eléctricas';
      case 114:
        return 'Tormentas eléctricas (noche)';

      case 15:
        return 'Llovizna';
      case 115:
        return 'Llovizna (noche)';

      case 16:
        return 'Tormenta de arena';
      case 116:
        return 'Tormenta de arena (noche)';

      default:
        return 'Desconocido';
    }
  }

  String _formatearHora(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Desconocido';
    try {
      final fecha = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(fecha.toLocal());
    } catch (e) {
      return 'Desconocido';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.ciudadesGuardadas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final ciudades = snapshot.data ?? [];

        if (ciudades.isEmpty) {
          return _buildEmpty();
        }

        return _buildPageView(ciudades);
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 50),
            const SizedBox(height: 10),
            const Text(
              'Error al cargar ciudades',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40),
            Icon(Icons.location_off, color: Colors.white, size: 60),
            SizedBox(height: 20),
            Text(
              'No hay ciudades guardadas',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  /// Esta parte es la clave: permitimos arrastre de mouse además de touch
  Widget _buildPageView(List<Map<String, dynamic>> ciudades) {
    return Stack(
      children: [
        // ScrollConfiguration personalizado para permitir drag con mouse
        ScrollConfiguration(
          behavior: const _DesktopDragScrollBehavior(),
          child: PageView.builder(
            controller: _pageController,
            itemCount: ciudades.length,
            onPageChanged: (i) {
              setState(() => _currentIndex = i);
            },
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => widget.actualizaClima(ciudades[i]),
                child: _buildCiudadCard(ciudades[i]),
              );
            },
          ),
        ),

        // Botón de actualizar
        Positioned(
          top: 50,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Protección por si index está fuera de rango
              if (_currentIndex >= 0 && _currentIndex < ciudades.length) {
                widget.actualizaClima(ciudades[_currentIndex]);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCiudadCard(Map<String, dynamic> ciudad) {
    final temperatura = ciudad['temperatura'] ?? 0.0;
    final simboloClima = ciudad['simbolo_clima'] ?? 0;
    final velocidadViento = ciudad['velocidad_viento'] ?? 0.0;
    final nombre = ciudad['nombre'] ?? 'Desconocido';
    final ultimaActualizacion = ciudad['ultima_actualizacion'] ?? '';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nombre,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 10),
              Icon(
                _obtenerIconoClima(simboloClima),
                color: Colors.white,
                size: 120,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    temperatura.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _obtenerDescripcionClima(simboloClima),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoColumn(
                    Icons.air,
                    '${velocidadViento.toStringAsFixed(1)} m/s',
                    'Viento',
                  ),
                  _buildInfoColumn(
                    Icons.access_time,
                    _formatearHora(ultimaActualizacion),
                    'Última',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}

class _DesktopDragScrollBehavior extends MaterialScrollBehavior {
  const _DesktopDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
