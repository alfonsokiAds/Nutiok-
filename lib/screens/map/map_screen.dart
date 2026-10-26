import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nutiok_app/app_theme.dart';

/// Pantalla de mapa de restaurantes cercanos
/// Sprint 4 - HU-6: Búsqueda de restaurantes saludables cercanos
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // Controlador del mapa
  final Completer<GoogleMapController> _mapController = Completer();

  // Estado de la ubicación actual
  Position? _currentPosition;
  bool _locationLoaded = false;
  final bool _mapsAvailable = false;

  // Barra de búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredRestaurants = [];

  // Modo de transporte seleccionado
  int _selectedTransport = 0;
  final List<String> _transportModes = ['Caminando', 'Auto', 'Bici'];
  final List<IconData> _transportIcons = [
    Icons.directions_walk_rounded,
    Icons.directions_car_rounded,
    Icons.directions_bike_rounded,
  ];

  // Marcadores del mapa
  Set<Marker> _markers = {};

  // Estado de carga
  bool _isLoadingLocation = true;

  // Coordenadas de Universidad de Cundinamarca Seccional Ubaté (centro del mapa)
  static const LatLng _ubateCenter = LatLng(5.2847, -73.8179);

  // Datos de restaurantes saludables en Ubaté
  final List<Map<String, dynamic>> _restaurants = const [
    {
      'name': 'Restaurante Doña Luz',
      'address': 'Calle 14 #10-45, Ubaté',
      'lat': 5.2862,
      'lng': -73.8160,
      'distance': '350 m',
      'rating': 4.5,
      'type': 'Comida Casera Balanceada',
      'specialty': 'Almuerzo balanceado con vegetales y proteína magra',
      'time': '11:00 AM - 3:00 PM',
      'phone': '310 123 4567',
    },
    {
      'name': 'Comedor Estudiantil Ubaté',
      'address': 'Calle 16 #9-20, Ubaté',
      'lat': 5.2890,
      'lng': -73.8205,
      'distance': '520 m',
      'rating': 4.2,
      'type': 'Menú Estudiantil Saludable',
      'specialty': 'Menú del día nutritivo con opción vegetariana',
      'time': '11:30 AM - 2:30 PM',
      'phone': '311 987 6543',
    },
    {
      'name': 'Cafetería Saludable El Sabor',
      'address': 'Carrera 6 #14-30, Ubaté',
      'lat': 5.2878,
      'lng': -73.8152,
      'distance': '280 m',
      'rating': 4.7,
      'type': 'Desayunos & Bowls',
      'specialty': 'Bowls de avena, frutas frescas, yogur griego y café',
      'time': '7:00 AM - 7:00 PM',
      'phone': '320 555 7890',
    },
    {
      'name': 'Restaurante Verde Oliva',
      'address': 'Calle 12 #8-15, Ubaté',
      'lat': 5.2835,
      'lng': -73.8220,
      'distance': '600 m',
      'rating': 4.6,
      'type': 'Vegetariano & Ensaladas',
      'specialty': 'Wraps integrales, ensaladas gourmet y batidos verdes',
      'time': '11:00 AM - 8:00 PM',
      'phone': '315 444 3210',
    },
    {
      'name': 'Don Pedro - Parrilla & Ensaladas',
      'address': 'Carrera 5 #13-25, Ubaté',
      'lat': 5.2855,
      'lng': -73.8240,
      'distance': '750 m',
      'rating': 4.4,
      'type': 'Proteínas & Guarniciones',
      'specialty': 'Pechuga a la plancha con verduras al vapor y arroz integral',
      'time': '12:00 PM - 9:00 PM',
      'phone': '312 888 9900',
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredRestaurants = List.from(_restaurants);
    _determinePosition();
    _initMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Inicializa los marcadores del mapa
  void _initMarkers() {
    _markers = {};
    for (final restaurant in _restaurants) {
      _markers.add(
        Marker(
          markerId: MarkerId(restaurant['name'] as String),
          position: LatLng(
            restaurant['lat'] as double,
            restaurant['lng'] as double,
          ),
          infoWindow: InfoWindow(
            title: restaurant['name'] as String,
            snippet: '${restaurant['distance']} - ${restaurant['address']}',
            onTap: () => _showRestaurantDetails(restaurant),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
  }

  /// Obtiene la posición actual del usuario
  Future<void> _determinePosition() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _locationLoaded = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationLoaded = false;
        });
        return;
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _locationLoaded = true;
          _isLoadingLocation = false;
        });

        // Agregar marcador de ubicación actual
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Mi ubicación'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationLoaded = false;
        });
      }
    }
  }

  /// Mueve la cámara del mapa a la posición dada
  Future<void> _moveCamera(LatLng target) async {
    if (_mapsAvailable) {
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 15),
        ),
      );
    }
  }

  /// Abre Google Maps con la ruta hacia un restaurante
  Future<void> _openGoogleMapsDirections(
    double lat,
    double lng,
    String name,
  ) async {
    final modeParam = _selectedTransport == 0
        ? 'walking'
        : _selectedTransport == 1
            ? 'driving'
            : 'bicycling';

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=$modeParam',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        final fallbackUri = Uri.parse(
          'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(name)})',
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir Google Maps: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  /// Abre la vista de restaurantes saludables en Google Maps en Ubaté
  Future<void> _openGoogleMapsArea() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/restaurantes+saludables/@5.2847,-73.8179,16z',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        final fallbackUri = Uri.parse(
          'geo:5.2847,-73.8179?q=restaurantes+saludables',
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir Google Maps: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  /// Abre el marcador telefónico para contacto
  Future<void> _openRestaurantPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error al marcar teléfono: $e');
    }
  }

  /// Filtra los restaurantes según la búsqueda
  void _filterRestaurants(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredRestaurants = List.from(_restaurants);
      } else {
        _filteredRestaurants = _restaurants.where((r) {
          final name = (r['name'] as String).toLowerCase();
          final address = (r['address'] as String).toLowerCase();
          final type = (r['type'] as String).toLowerCase();
          return name.contains(_searchQuery) ||
              address.contains(_searchQuery) ||
              type.contains(_searchQuery);
        }).toList();
      }
    });
  }

  /// Muestra los detalles de un restaurante en un bottom sheet
  void _showRestaurantDetails(Map<String, dynamic> restaurant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRestaurantBottomSheet(restaurant),
    );
  }

  /// Calcula una distancia estimada según el modo de transporte
  String _getEstimatedTime(String distance) {
    // Extraer metros de la cadena
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(distance);
    if (match == null) return distance;

    final meters = int.parse(match.group(1)!);
    final minutes = _selectedTransport == 0
        ? (meters / 80).ceil() // Caminando ~80m/min
        : _selectedTransport == 1
            ? (meters / 400).ceil() // Auto ~400m/min
            : (meters / 200).ceil(); // Bici ~200m/min

    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutiokTheme.backgroundGray,
      appBar: AppBar(
        title: Text(
          'Restaurantes Cerca',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: NutiokTheme.primaryGreen,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            tooltip: 'Ver en Google Maps',
            onPressed: _openGoogleMapsArea,
          ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: Colors.white),
            tooltip: 'Mi ubicación',
            onPressed: () {
              if (_currentPosition != null) {
                _moveCamera(
                  LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude),
                );
              } else {
                _determinePosition();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de búsqueda ──
          _buildSearchBar(),

          // ── Botones de modo de transporte ──
          _buildTransportModes(),

          // ── Mapa o Guía del Campus ──
          Expanded(
            child: Stack(
              children: [
                _mapsAvailable ? _buildGoogleMap() : _buildCampusGuide(),
                // Indicador de carga de ubicación
                if (_isLoadingLocation)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  NutiokTheme.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Obteniendo ubicación...',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Barra de búsqueda
  // ─────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      color: Colors.white,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterRestaurants,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar restaurante...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _filterRestaurants('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Modos de transporte
  // ─────────────────────────────────────────
  Widget _buildTransportModes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: List.generate(_transportModes.length, (index) {
          final isSelected = _selectedTransport == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < _transportModes.length - 1 ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTransport = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? NutiokTheme.primaryGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? NutiokTheme.primaryGreen
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _transportIcons[index],
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _transportModes[index],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Google Maps
  // ─────────────────────────────────────────
  Widget _buildGoogleMap() {
    final initialPos = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _ubateCenter;

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        if (!_mapController.isCompleted) {
          _mapController.complete(controller);
        }
      },
      initialCameraPosition: CameraPosition(
        target: initialPos,
        zoom: 15,
      ),
      markers: _markers,
      myLocationEnabled: _locationLoaded,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      onCameraMove: (position) {},
      // Estilo del mapa
      buildingsEnabled: true,
      compassEnabled: true,
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Guía del Campus Universitario y Restaurantes Saludables
  // ─────────────────────────────────────────
  Widget _buildCampusGuide() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner interactivo del Campus y Ubaté
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Fondo con mapa ilustrado de vías y zonas verdes
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MapPlaceholderPainter(),
                    ),
                  ),

                  // Pins interactivos de los restaurantes
                  Positioned(
                    left: 18,
                    top: 20,
                    child: _buildInteractiveMapPin(_restaurants[0]),
                  ),
                  Positioned(
                    right: 18,
                    top: 20,
                    child: _buildInteractiveMapPin(_restaurants[1]),
                  ),
                  Positioned(
                    left: 24,
                    top: 95,
                    child: _buildInteractiveMapPin(_restaurants[2]),
                  ),
                  Positioned(
                    right: 22,
                    top: 90,
                    child: _buildInteractiveMapPin(_restaurants[3]),
                  ),
                  Positioned(
                    left: 110,
                    top: 48,
                    child: _buildInteractiveMapPin(_restaurants[4]),
                  ),

                  // Pin central de la Universidad
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 75,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'UdeC Sede Ubaté',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Barra flotante inferior de Google Maps
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: NutiokTheme.primaryGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: NutiokTheme.primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Guía del Campus Ubaté',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Restaurantes saludables a pocos minutos',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _openGoogleMapsArea,
                            icon: const Icon(Icons.open_in_new_rounded, size: 14, color: Colors.white),
                            label: Text(
                              'Ver Mapa',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NutiokTheme.primaryGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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

          // Lista de restaurantes como tarjetas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Restaurantes cercanos',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: NutiokTheme.primaryGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: NutiokTheme.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_filteredRestaurants.length} opciones',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: NutiokTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._filteredRestaurants.map(
                  (restaurant) => _buildRestaurantCard(restaurant),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Marcador interactivo para la vista ilustrada del mapa
  Widget _buildInteractiveMapPin(Map<String, dynamic> restaurant) {
    return GestureDetector(
      onTap: () => _showRestaurantDetails(restaurant),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NutiokTheme.primaryOrange, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant_rounded,
              size: 11,
              color: NutiokTheme.primaryOrange,
            ),
            const SizedBox(width: 4),
            Text(
              (restaurant['name'] as String)
                  .replaceAll('Restaurante ', '')
                  .replaceAll('Cafetería Saludable ', ''),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Tarjeta de restaurante
  // ─────────────────────────────────────────
  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    final rating = restaurant['rating'] as double;
    final estimatedTime = _getEstimatedTime(restaurant['distance'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showRestaurantDetails(restaurant),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícono del restaurante
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: NutiokTheme.primaryOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: NutiokTheme.primaryOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Información principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  restaurant['name'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Color(0xFFFFC107),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            restaurant['type'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: NutiokTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (restaurant['specialty'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FBE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE6EE9C), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          size: 13,
                          color: Color(0xFF689F38),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            restaurant['specialty'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF33691E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 0.6, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 10),

                // Fila de dirección, distancia, tiempo y botón cómo llegar
                Row(
                  children: [
                    // Distancia y tiempo dinámico
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: NutiokTheme.primaryGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _transportIcons[_selectedTransport],
                            size: 13,
                            color: NutiokTheme.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant['distance']} (~$estimatedTime)',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: NutiokTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Botón directo Cómo llegar con Google Maps
                    ElevatedButton.icon(
                      onPressed: () {
                        _openGoogleMapsDirections(
                          restaurant['lat'] as double,
                          restaurant['lng'] as double,
                          restaurant['name'] as String,
                        );
                      },
                      icon: const Icon(
                        Icons.directions_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Cómo llegar',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NutiokTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Bottom Sheet del restaurante
  // ─────────────────────────────────────────
  Widget _buildRestaurantBottomSheet(Map<String, dynamic> restaurant) {
    final estimatedTime = _getEstimatedTime(restaurant['distance'] as String);
    final rating = restaurant['rating'] as double;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de arrastre
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y tipo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant['name'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    NutiokTheme.primaryGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                restaurant['type'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: NutiokTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rating grande
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: Color(0xFFFFC107),
                            ),
                            Text(
                              rating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Especialidad saludable recomendada
                  if (restaurant['specialty'] != null) ...[
                    _buildDetailRow(
                      icon: Icons.eco_rounded,
                      label: 'Plato saludable recomendado',
                      value: restaurant['specialty'] as String,
                      iconColor: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Dirección
                  _buildDetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Dirección',
                    value: restaurant['address'] as String,
                    iconColor: NutiokTheme.primaryGreen,
                  ),
                  const SizedBox(height: 14),

                  // Distancia y tiempo en transporte seleccionado
                  _buildDetailRow(
                    icon: _transportIcons[_selectedTransport],
                    label: 'Distancia (${_transportModes[_selectedTransport]})',
                    value: '${restaurant['distance']} (~$estimatedTime)',
                    iconColor: NutiokTheme.primaryOrange,
                  ),
                  const SizedBox(height: 14),

                  // Horario
                  _buildDetailRow(
                    icon: Icons.schedule_rounded,
                    label: 'Horario de atención',
                    value: restaurant['time'] as String,
                    iconColor: const Color(0xFF1976D2),
                  ),

                  // Teléfono si existe
                  if (restaurant['phone'] != null) ...[
                    const SizedBox(height: 14),
                    _buildDetailRow(
                      icon: Icons.phone_rounded,
                      label: 'Contacto / Reservas',
                      value: restaurant['phone'] as String,
                      iconColor: Colors.teal,
                      onTap: () => _openRestaurantPhone(restaurant['phone'] as String),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Botón "Cómo llegar" conectado directamente a Google Maps
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: NutiokTheme.greenGradient,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: NutiokTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _openGoogleMapsDirections(
                          restaurant['lat'] as double,
                          restaurant['lng'] as double,
                          restaurant['name'] as String,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.navigation_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Iniciar Ruta en Google Maps',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fila de detalle para el bottom sheet
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onTap != null ? NutiokTheme.primaryGreen : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.phone_forwarded_rounded,
              size: 16,
              color: NutiokTheme.primaryGreen,
            ),
        ],
      ),
    );
  }
}

/// Pintor personalizado para el mapa del campus de Ubaté
class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fondo de área verde
    final bgPaint = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Calles principales y secundarias
    final mainStreetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final streetBorderPaint = Paint()
      ..color = const Color(0xFFC8E6C9)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    final paths = [
      // Carrera 6 (vertical)
      [Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height)],
      // Carrera 5 (vertical)
      [Offset(size.width * 0.72, 0), Offset(size.width * 0.72, size.height)],
      // Calle 14 (horizontal)
      [Offset(0, size.height * 0.38), Offset(size.width, size.height * 0.38)],
      // Calle 12 (horizontal)
      [Offset(0, size.height * 0.72), Offset(size.width, size.height * 0.72)],
    ];

    for (final p in paths) {
      canvas.drawLine(p[0], p[1], streetBorderPaint);
      canvas.drawLine(p[0], p[1], mainStreetPaint);
    }

    // Bloque central: Campus Universidad de Cundinamarca
    final campusRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.38),
        width: 140,
        height: 60,
      ),
      const Radius.circular(12),
    );

    final campusBgPaint = Paint()
      ..color = const Color(0xFFA5D6A7)
      ..style = PaintingStyle.fill;
    final campusBorderPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(campusRect, campusBgPaint);
    canvas.drawRRect(campusRect, campusBorderPaint);

    // Bloques de manzanas circundantes
    final blockPaint = Paint()
      ..color = const Color(0xFFDCEDC8)
      ..style = PaintingStyle.fill;

    // Manzana 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, size.width * 0.28, size.height * 0.28),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // Manzana 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.78, 10, size.width * 0.2, size.height * 0.28),
        const Radius.circular(8),
      ),
      blockPaint,
    );

    // Manzana 3
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, size.height * 0.44, size.width * 0.28, size.height * 0.22),
        const Radius.circular(8),
      ),
      blockPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
