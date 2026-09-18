import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:nutiok_app/app_theme.dart';
import 'package:nutiok_app/widgets/bottom_nav_bar.dart';

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
  final bool _mapsAvailable = true;

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

  // Datos de restaurantes hardcoded
  final List<Map<String, dynamic>> _restaurants = const [
    {
      'name': 'Restaurante Doña Luz',
      'address': 'Calle 14 #10-45',
      'lat': 5.2862,
      'lng': -73.8160,
      'distance': '350 m',
      'rating': 4.5,
      'type': 'Comida casera',
      'time': '11:00 AM - 3:00 PM',
    },
    {
      'name': 'Comedor Estudiantil Ubaté',
      'address': 'Calle 16 #9-20',
      'lat': 5.2890,
      'lng': -73.8205,
      'distance': '520 m',
      'rating': 4.2,
      'type': 'Menú del día',
      'time': '11:30 AM - 2:30 PM',
    },
    {
      'name': 'Cafetería El Sabor',
      'address': 'Carrera 6 #14-30',
      'lat': 5.2878,
      'lng': -73.8152,
      'distance': '280 m',
      'rating': 4.7,
      'type': 'Cafetería',
      'time': '7:00 AM - 7:00 PM',
    },
    {
      'name': 'Hamburguesas El Buen Sabor',
      'address': 'Calle 12 #8-15',
      'lat': 5.2835,
      'lng': -73.8220,
      'distance': '600 m',
      'rating': 4.3,
      'type': 'Hamburguesas',
      'time': '12:00 PM - 9:00 PM',
    },
    {
      'name': 'Pizzería Don Pedro',
      'address': 'Carrera 5 #13-25',
      'lat': 5.2855,
      'lng': -73.8240,
      'distance': '750 m',
      'rating': 4.6,
      'type': 'Pizzería',
      'time': '12:00 PM - 10:00 PM',
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
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 15),
      ),
    );
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
            icon: const Icon(Icons.my_location_rounded, color: Colors.white),
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

          // ── Mapa o Fallback ──
          Expanded(
            child: Stack(
              children: [
                _mapsAvailable ? _buildGoogleMap() : _buildFallbackMap(),
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
  // SECCIÓN: Fallback cuando Google Maps no está disponible
  // ─────────────────────────────────────────
  Widget _buildFallbackMap() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Placeholder del mapa
          Container(
            height: 280,
            width: double.infinity,
            color: const Color(0xFFE8F5E9),
            child: Stack(
              children: [
                // Fondo con patrón de calles
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPlaceholderPainter(),
                  ),
                ),
                // Mensaje central
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: NutiokTheme.primaryGreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.map_rounded,
                            size: 36,
                            color: NutiokTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mapa no disponible',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Se muestra la lista de\nrestaurantes debajo',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Indicador de ubicación
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.45,
                  top: 120,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Marcadores de restaurantes
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.25,
                  top: 90,
                  child: _buildMiniMarker(),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.6,
                  top: 80,
                  child: _buildMiniMarker(),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.35,
                  top: 160,
                  child: _buildMiniMarker(),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.7,
                  top: 150,
                  child: _buildMiniMarker(),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.55,
                  top: 200,
                  child: _buildMiniMarker(),
                ),
              ],
            ),
          ),

          // Lista de restaurantes como tarjetas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Restaurantes cercanos',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
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
                        '${_filteredRestaurants.length} lugares',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NutiokTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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

  /// Marcador miniatura para el placeholder
  Widget _buildMiniMarker() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: NutiokTheme.primaryOrange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: NutiokTheme.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.restaurant,
        size: 12,
        color: Colors.white,
      ),
    );
  }

  // ─────────────────────────────────────────
  // SECCIÓN: Tarjeta de restaurante (fallback)
  // ─────────────────────────────────────────
  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    final rating = restaurant['rating'] as double;
    final estimatedTime = _getEstimatedTime(restaurant['distance'] as String);

    return GestureDetector(
      onTap: () => _showRestaurantDetails(restaurant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono del restaurante
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: NutiokTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: NutiokTheme.primaryOrange,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant['name'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant['address'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Distancia
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: NutiokTheme.primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_walk_rounded,
                              size: 12,
                              color: NutiokTheme.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              restaurant['distance'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: NutiokTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tiempo estimado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: NutiokTheme.primaryOrange.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: NutiokTheme.primaryOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              estimatedTime,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: NutiokTheme.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: const Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Flecha
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
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

                  const SizedBox(height: 20),

                  // Dirección
                  _buildDetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Dirección',
                    value: restaurant['address'] as String,
                    iconColor: NutiokTheme.primaryGreen,
                  ),
                  const SizedBox(height: 14),

                  // Distancia
                  _buildDetailRow(
                    icon: Icons.directions_walk_rounded,
                    label: 'Distancia',
                    value: '${restaurant['distance']} (~$estimatedTime)',
                    iconColor: NutiokTheme.primaryOrange,
                  ),
                  const SizedBox(height: 14),

                  // Horario
                  _buildDetailRow(
                    icon: Icons.schedule_rounded,
                    label: 'Horario',
                    value: restaurant['time'] as String,
                    iconColor: const Color(0xFF1976D2),
                  ),

                  const SizedBox(height: 24),

                  // Botón "Cómo llegar"
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
                        // TODO: Abrir Google Maps con direcciones
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Abriendo direcciones hacia ${restaurant['name']}...',
                            ),
                            backgroundColor: NutiokTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
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
                            'Cómo llegar',
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
  }) {
    return Row(
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
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pintor personalizado para el placeholder del mapa
class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8E6C9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Dibujar líneas horizontales simulando calles
    for (double y = 40; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Dibujar líneas verticales
    for (double x = 60; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Dibujar bloque principal (representando el campus)
    final blockPaint = Paint()
      ..color = const Color(0xFFA5D6A7)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width * 0.45, size.height * 0.5),
          width: 100,
          height: 70),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, blockPaint);

    // Texto en el bloque
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Ubaté',
        style: TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.45 - textPainter.width / 2,
          size.height * 0.5 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
