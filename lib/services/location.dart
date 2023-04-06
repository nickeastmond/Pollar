

import 'package:cloud_firestore/cloud_firestore.dart';

_saveLocationToFirestore() async {
  Position _currentPosition;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (_currentPosition != null) {
      await firestore.collection('User').add({
        'position': GeoPoint(
            _currentPosition.latitude, _currentPosition.longitude)
      });
    }
  }