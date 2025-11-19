import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';

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
  int _currentIndex = 0; // Índice de la página actual en el PageView

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
      case 2:
        return 'Mayormente despejado';
      case 3:
        return 'Parcialmente Nublado';
      case 4:
        return 'Nublado';
      case 101:
        return 'Despejado (noche)';
      case 102:
        return 'Mayormente despejado (noche)';
      case 103:
        return 'Parcialmente nublado (noche)';
      case 104:
        return 'Nublado (noche)';
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
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.ciudadesGuardadas,
      builder: (context, snapshot) {
        // Mostrar 'Loading' mientras se cargan los datos
        if (snapshot.connectionState == ConnectionState.waiting) {
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
        // Manejar errores
        if (snapshot.hasError) {
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
                  Text(
                    'Error al cargar ciudades: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        // Acceder a la lista de ciudades
        final ciudades = snapshot.data ?? [];
        if (ciudades.isEmpty) {
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
        // Mostrar el Carousel de ciudades
        return _buildCarousel(ciudades);
      },
    );
  }

  Widget _buildCarousel(List<Map<String, dynamic>> ciudades) {
    return Stack(
      children: [
        // CarouselView aquí
        CarouselView(
          itemExtent: MediaQuery.of(context).size.width,
          shrinkExtent: MediaQuery.of(context).size.width,
          onTap: (index) {
            widget.actualizaClima(ciudades[index]);
          },
          children: List.generate(ciudades.length, (index) {
            final ciudad = ciudades[index];
            return _buildCiudadCard(ciudad);
          }),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (_currentIndex < ciudades.length) {
                widget.actualizaClima(ciudades[_currentIndex]);
              }
            },
          ),
        ),
      ],
    ); // Implementación del carrusel aquí
  }

  Widget _buildCiudadCard(Map<String, dynamic> ciudad) {
    final temperatura = ciudad['temperatura'] ?? 0.0;
    final simoboloClima = ciudad['simbolo_clima'] ?? 0;
    final velocidadViento = ciudad['velocidad_viento'] ?? 0.0;
    final nombre = ciudad['nombre'] ?? 'Desconocido';
    final ultimaActualizacion = ciudad['ultima_actualizacion'] ?? '';
    return Container(
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
              // Nombre de la ciudad
              Text(nombre, style: TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 10),
              // Icono del clima
              Icon(
                _obtenerIconoClima(simoboloClima),
                color: Colors.white,
                size: 120,
              ),
              const SizedBox(height: 10),
              // Temperatura
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${temperatura.toStringAsFixed(1)}',
                    style: TextStyle(
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
              // Descripción del clima
              Text(
                _obtenerDescripcionClima(simoboloClima),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 5),
              // Información adicional (viento, última actualización)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      Icons.air,
                      '${velocidadViento.toStringAsFixed(1)} m/s',
                      'Viento',
                    ),
                    _buildInfoItem(
                      Icons.access_time,
                      _formatearHora(ultimaActualizacion),
                      'Última actualización',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
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
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }
}
