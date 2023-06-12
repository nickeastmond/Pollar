import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pollar/model/Position/position_adapter.dart';
import 'package:pollar/navigation/feed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pollar/model/Poll/database/voting.dart';
import 'package:mockito/mockito.dart';
import 'package:pollar/model/Position/position_adapter.dart';
import 'package:pollar/services/feeds/main_feed_provider.dart';
import 'package:pollar/maps.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollar/open_street_map_search_and_pick.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockMainFeedProvider extends Mock implements MainFeedProvider {}

class MockPositionAdapter extends Mock implements PositionAdapter {
  Future<Position?> getFromSharedPreferences(String key) async {
    // Provide the desired mock behavior here
    return null;
  }
}

class LocationData {
  final LatLng latLng;
  LocationData({required this.latLng});
}

class MockCreateMapPage extends CreateMapPage {
  MockCreateMapPage({
    required MainFeedProvider feedProvider,
    required bool fromFeed,
  }) : super(feedProvider: feedProvider, fromFeed: fromFeed);
}

class MockLocationData extends Mock implements LocationData {}

class MockGetCurrentLocation extends Mock implements Future<LocationData> {}

class MockFeedProvider extends Mock implements MainFeedProvider {}

void main() {
  // Create a mock SharedPreferences instance
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    // Initialize the mockSharedPreferences before each test
    mockSharedPreferences = MockSharedPreferences();
  });

  group('CreateMapPage', () {
    testWidgets('should display loading screen while fetching location data',
        (WidgetTester tester) async {
      // Build the CreateMapPage widget with the mocked SharedPreferences
      await tester.pumpWidget(
        MaterialApp(
          home: CreateMapPage(
            feedProvider: MainFeedProvider(), // Mock the required dependencies
            fromFeed: false,
          ),
        ),
      );

      // Verify that the CircularProgressIndicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display the map after fetching location data',
        (WidgetTester tester) async {
      // Mock the SharedPreferences data
      when(mockSharedPreferences.getDouble('Radius')).thenAnswer((_) => 5);

      // Build the CreateMapPage widget with the mocked dependencies
      await tester.pumpWidget(
        MaterialApp(
          home: CreateMapPage(
            feedProvider: MainFeedProvider(), // Mock the required dependencies
            fromFeed: true,
          ),
        ),
      );

      await tester.pump();

      // Verify that the CircularProgressIndicator is no longer displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify that the map is displayed
      expect(find.byType(OpenStreetMapSearchAndPick), findsNothing);
    });
  });

  test('geoPointsDistance() should return the correct distance comparison',
      () async {
    // Arrange
    Position p1 = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0); // Sample position 1
    Position p2 = Position(
        latitude: 34.0522,
        longitude: -118.2437,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0); // Sample position 2
    double r1 = 10.0; // Sample radius

    // Act
    bool result = await geoPointsDistance(p1, p2, r1);

    // Assert
    expect(result, isFalse);
  });
  test('geoPointsDistance() should return the correct distance comparison',
      () async {
    // Arrange
    Position p1 = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0); // Sample position 1
    Position p2 = Position(
        latitude: 37.6522,
        longitude: -122.2437,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0); // Sample position 2
    double r1 = 20.0; // Sample radius

    // Act
    bool result = await geoPointsDistance(p1, p2, r1);

    // Assert
    expect(result, isTrue);
  });
}
