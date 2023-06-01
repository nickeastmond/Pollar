import 'package:flutter/material.dart';
import 'package:pollar/maps.dart';
import '../../model/Poll/poll_model.dart';


class PollFeedObject {
  Poll poll;
  String pollId;

  PollFeedObject(this.poll, this.pollId);
}

abstract class FeedProvider extends ChangeNotifier {
  // Common properties and methods go here
  // Abstract method to be implemented by subclasses
  List<PollFeedObject> get items;
  
  Future<void> fetchInitial(int limit);
}


