import 'package:flutter/material.dart';

enum FilterBy { likes, queueTime, currentGenre, energyLevels, ratio }

class Filters with ChangeNotifier {
  bool _showLikedOnly = false;
  FilterBy _filterOption = FilterBy.likes;

  bool get showLikedOnly => _showLikedOnly;
  FilterBy get filterOption => _filterOption;

  void toggleShowLikedOnly() {
    _showLikedOnly = !_showLikedOnly;
    notifyListeners();
  }

  void setFilterOption({required index}) {
    _filterOption = FilterBy.values[index];
    notifyListeners();
  }
}
