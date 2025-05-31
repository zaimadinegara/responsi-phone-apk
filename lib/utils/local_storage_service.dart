// lib/utils/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _favoritePhonesKey = 'favoritePhones';

  Future<List<String>> getFavoritePhoneIds() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritePhonesKey) ?? [];
  }

  Future<void> addFavoritePhone(String phoneId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavoritePhoneIds();
    if (!favorites.contains(phoneId)) {
      favorites.add(phoneId);
      await prefs.setStringList(_favoritePhonesKey, favorites);
    }
  }

  Future<void> removeFavoritePhone(String phoneId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = await getFavoritePhoneIds();
    if (favorites.contains(phoneId)) {
      favorites.remove(phoneId);
      await prefs.setStringList(_favoritePhonesKey, favorites);
    }
  }

  Future<bool> isPhoneFavorite(String phoneId) async {
    List<String> favorites = await getFavoritePhoneIds();
    return favorites.contains(phoneId);
  }
}
