import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static Future<List<String>> getFavorites(String? userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final key = (userEmail == null || userEmail.isEmpty) ? 'favorites_guest' : 'favorites_$userEmail';
    return prefs.getStringList(key) ?? [];
  }

  static Future<void> addFavorite(String? userEmail, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = (userEmail == null || userEmail.isEmpty) ? 'favorites_guest' : 'favorites_$userEmail';
    final favorites = prefs.getStringList(key) ?? [];
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await prefs.setStringList(key, favorites);
    }
  }

  static Future<void> removeFavorite(String? userEmail, String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = (userEmail == null || userEmail.isEmpty) ? 'favorites_guest' : 'favorites_$userEmail';
    final favorites = prefs.getStringList(key) ?? [];
    favorites.remove(productId);
    await prefs.setStringList(key, favorites);
  }

  static Future<bool> isFavorite(String? userEmail, String productId) async {
    final favorites = await getFavorites(userEmail);
    return favorites.contains(productId);
  }
} 