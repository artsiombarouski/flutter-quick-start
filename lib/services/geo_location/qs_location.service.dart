import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_quick_start/services/geo_location/qs_geo_location.model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class QsLocationServiceState {
  final isServiceEnabled;
  final isPermissionsGranted;
  final isPermissionDeniedForever;

  QsLocationServiceState({
    this.isServiceEnabled,
    this.isPermissionsGranted,
    this.isPermissionDeniedForever,
  });

  bool get canTrackLocation => isServiceEnabled && isPermissionsGranted;
}

class QsLocationService with WidgetsBindingObserver {
  final _stateSubject = BehaviorSubject<QsLocationServiceState?>();

  QsLocationServiceState? get currentState => _stateSubject.valueOrNull;

  ValueStream<QsLocationServiceState?> get stateStream => _stateSubject.stream;

  final _locationSubject = BehaviorSubject<QsGeoLocation?>();

  QsGeoLocation? get currentLocation => _locationSubject.valueOrNull;

  ValueStream<QsGeoLocation?> get locationStream => _locationSubject.stream;

  bool _isInitialized = false;
  bool _isTracking = false;

  StreamSubscription? _serviceStatusSubscription;
  StreamSubscription? _positionSubscription;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;
    // Subscribe to listen app state changes (needed for stop / start tracking
    // after app is paused / resumed)
    WidgetsFlutterBinding.ensureInitialized().addObserver(this);

    // Subscribe for track current state of service
    _serviceStatusSubscription = Geolocator.getServiceStatusStream()
        .listen((ServiceStatus status) => syncState());

    // Update current location
    syncState().then((value) {
      if (value.canTrackLocation) {
        _updateCurrentLocation();
        startTrackingIfAvailable();
      }
    });
  }

  void dispose() {
    _stateSubject.close();
    _locationSubject.close();
    _serviceStatusSubscription?.cancel();
    stopTracking();
  }

  Future<QsLocationServiceState> syncState() async {
    // Get required information from device
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();

    // Prepare current state update
    final result = QsLocationServiceState(
      isServiceEnabled: isServiceEnabled,
      isPermissionsGranted: permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse,
      isPermissionDeniedForever: permission == LocationPermission.deniedForever,
    );

    // Update global state, because state of location tracking availability
    // is single for all
    _stateSubject.add(result);
    return result;
  }

  Future<QsLocationServiceState> syncStateAndStartIfAvailable() async {
    final state = await syncState();
    if (state.canTrackLocation) {
      _updateCurrentLocation();
      _startTracking();
    }
    return state;
  }

  // Check if service enabled and permissions are granted and update current
  // location if everything is ok, if not - all appropriate variables will be
  // updated and you should track state
  Future<void> updateCurrentLocationIfAvailable() async {
    // Sync service enabled state and permissions
    final state = await syncState();
    // If everything is OK - update current location
    if (state.canTrackLocation) {
      _updateCurrentLocation();
    }
  }

  // Update current location
  void _updateCurrentLocation() {
    Geolocator.getLastKnownPosition().then(_updateLocation);
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then(_updateLocation);
  }

  // Check if service enabled and permissions are granted and start location
  // tracking if everything is ok, if not - all appropriate variables will be
  // updated and you should track state
  Future<void> startTrackingIfAvailable() async {
    // Sync service enabled state and permissions
    final state = await syncState();
    // If everything is OK - update current location
    if (state.canTrackLocation) {
      _startTracking();
    }
  }

  // Actual location tracking start
  void _startTracking() {
    if (_isTracking) {
      return;
    }
    _isTracking = true;
    _positionSubscription =
        Geolocator.getPositionStream().listen(_updateLocation);
  }

  // Stop location tracking
  void stopTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> requestPermissions() async {
    // If state was updated and everything is ok - just return
    var state = await syncStateAndStartIfAvailable();
    if (state.canTrackLocation) {
      return;
    }

    // If geo location not enabled at all, than we should open location settings
    // (on iOS are same as app settings)
    if (state.isServiceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // If geo location not enabled because of permissions, than we should open
    // app settings (on iOS are same as location settings)
    if (state.isPermissionDeniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    // Ask user for permissions
    await Geolocator.requestPermission();
    // Try to sync permissions and start again
    await syncStateAndStartIfAvailable();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Sync enable state and permissions and if everything is ok - start
        // location tracking
        syncState().then((value) {
          if (value.canTrackLocation) {
            _updateCurrentLocation();
            _startTracking();
          }
        });
        startTrackingIfAvailable();
        break;
      case AppLifecycleState.paused:
        // Pause tracking, because we don't need any updates while app is in
        // background. Also useful because new OS showing appropriate indicator
        stopTracking();
        break;
      default:
        break;
    }
  }

  void _updateLocation(Position? position) {
    // If we have newer location and it's null, we shouldn't update previous one
    // because it can be non null and can be used
    if (position == null) {
      return;
    }
    final current = currentLocation;
    final updated = _positionToQsLocation(position)!;
    if (current?.timestamp != null &&
        updated.timestamp != null &&
        updated.timestamp! < current!.timestamp!) {
      // If previous received location is newer, than we don't need update it
      return;
    } else {
      _locationSubject.add(updated);
    }
  }

  QsGeoLocation? _positionToQsLocation(Position? position) {
    if (position == null) {
      return null;
    }
    return QsGeoLocation(
      position.latitude,
      position.longitude,
      timestamp: position.timestamp?.millisecond,
    );
  }
}
