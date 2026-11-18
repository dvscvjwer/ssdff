import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight user state: My List + Downloads.
/// Persists to SharedPreferences so toggles survive restarts.
class UserState extends ChangeNotifier {
  static const _myListKey = 'user_my_list_ids';
  static const _downloadsKey = 'user_downloads_ids';

  final Set<String> _myList = <String>{};
  final Set<String> _downloads = <String>{};

  Set<String> get myListIds => Set.unmodifiable(_myList);
  Set<String> get downloadsIds => Set.unmodifiable(_downloads);

  bool isInMyList(String id) => _myList.contains(id);
  bool isDownloaded(String id) => _downloads.contains(id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_myListKey);
    if (list != null) {
      _myList
        ..clear()
        ..addAll(list);
    }
    final dl = prefs.getStringList(_downloadsKey);
    if (dl != null) {
      _downloads
        ..clear()
        ..addAll(dl);
    }
    notifyListeners();
  }

  Future<bool> toggleMyList(String id) async {
    final wasIn = _myList.contains(id);
    if (wasIn) {
      _myList.remove(id);
    } else {
      _myList.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_myListKey, _myList.toList());
    return !wasIn;
  }

  Future<bool> toggleDownload(String id) async {
    final wasIn = _downloads.contains(id);
    if (wasIn) {
      _downloads.remove(id);
    } else {
      _downloads.add(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_downloadsKey, _downloads.toList());
    return !wasIn;
  }
}

final userState = UserState();
