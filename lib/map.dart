import 'package:flutter/material.dart';

// Paquetes
import 'package:mapbox_gl/mapbox_gl.dart';

import 'package:provider/provider.dart';

// Código
import 'package:context/map_controller.dart';
import 'package:context/navigate_in_problem.dart';
import 'package:context/problem_card.dart';
import 'package:context/victim_card.dart';

class CustomMap extends StatelessWidget {
  const CustomMap({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapController(),
      child: const _BuildMap(),
    );
  }
}

class _BuildMap extends StatefulWidget {
  const _BuildMap();

  @override
  State<_BuildMap> createState() => _BuildMapState();
}

class _BuildMapState extends State<_BuildMap> with TickerProviderStateMixin {
  final String style = "mapbox://styles/poyito/clxmgfxam02ax01qjdq4f374f";

  @override
  void initState() {
    MapController().context = context;
    MapController().setUpAnimCtrls(this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mapController = Provider.of<MapController>(context);

    return Stack(
      children: [
        MapboxMap(
          accessToken:
              'pk.eyJ1IjoicG95aXRvIiwiYSI6ImNseG1jczNqeDAyZWoybHB0cTN5dHFrbWQifQ.g8EzOJluCY5o5x3o5gl8YQ',
          onMapCreated: mapController.onMapCreated,
          onCameraIdle: mapController.onCameraIdleCallback,
          onStyleLoadedCallback: mapController.styleLoaded,
          styleString: style,
          initialCameraPosition:
              const CameraPosition(target: LatLng(20.879961, -100.929315)),
          compassEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          doubleClickZoomEnabled: false,
          minMaxZoomPreference: const MinMaxZoomPreference(3.0, 5.9),
          onMapClick: (point, __) => mapController.onClick(point),
        ),
        Stack(
          children: mapController.markers,
        ),
        const ProblemCard(),
        const VictimCard(),
        const NavigateInProblem()
      ],
    );
  }
}
