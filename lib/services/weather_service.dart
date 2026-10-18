import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple weather info matching the same condition words already used
/// in the "What should I wear?" dropdown, so both stay consistent.
class WeatherInfo {
  final double tempC;
  final String condition; // 'Sunny' | 'Hot' | 'Rainy' | 'Cold' | 'Mild'
  final String cityName;

  WeatherInfo({required this.tempC, required this.condition, required this.cityName});
}

/// Fetches an approximate current weather with NO API key and NO
/// location permission prompt.
///
/// By default it guesses your city from your phone's IP address
/// (ipapi.co, then ipwho.is as a fallback -- both free, no key). This
/// is inherently approximate: mobile carriers often route your IP
/// through a gateway in a different city than where you actually are,
/// so the guessed city can be wrong.
///
/// If the user has manually set a city (see [setManualCity]), that is
/// used instead of the IP guess -- geocoded via Open-Meteo's free
/// geocoding API. This is the reliable path; IP guessing is only the
/// no-setup default.
class WeatherService {
  static const _manualCityKey = 'stylemate_manual_city';

  Future<String?> getManualCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_manualCityKey);
  }

  Future<void> setManualCity(String? city) async {
    final prefs = await SharedPreferences.getInstance();
    if (city == null || city.trim().isEmpty) {
      await prefs.remove(_manualCityKey);
    } else {
      await prefs.setString(_manualCityKey, city.trim());
    }
  }

  Future<WeatherInfo?> fetchCurrentWeather() async {
    final manualCity = await getManualCity();
    final geo = manualCity != null ? await _geocodeCity(manualCity) : await _lookupGeoByIp();
    if (geo == null) return null;

    try {
      final weatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=${geo.lat}&longitude=${geo.lon}&current=temperature_2m,weather_code';
      final wRes = await http.get(Uri.parse(weatherUrl)).timeout(const Duration(seconds: 8));
      if (wRes.statusCode != 200) {
        debugPrint('[WeatherService] weather lookup failed: HTTP ${wRes.statusCode} -- ${wRes.body}');
        return null;
      }
      final w = jsonDecode(wRes.body);
      final temp = (w['current']['temperature_2m'] as num).toDouble();
      final code = w['current']['weather_code'] as int;

      return WeatherInfo(tempC: temp, condition: _mapCondition(code, temp), cityName: geo.city);
    } catch (e) {
      debugPrint('[WeatherService] weather lookup exception: $e');
      return null;
    }
  }

  /// Turns a manually-typed city name into coordinates using
  /// Open-Meteo's free geocoding API -- no key needed.
  Future<_GeoResult?> _geocodeCity(String city) async {
    try {
      final url = 'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=1';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) {
        debugPrint('[WeatherService] geocoding failed: HTTP ${res.statusCode} -- ${res.body}');
        return null;
      }
      final decoded = jsonDecode(res.body);
      final results = decoded['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        debugPrint('[WeatherService] geocoding found no match for "$city"');
        return null;
      }
      final match = results.first;
      return _GeoResult(lat: match['latitude'], lon: match['longitude'], city: match['name'] as String? ?? city);
    } catch (e) {
      debugPrint('[WeatherService] geocoding exception: $e');
      return null;
    }
  }

  /// Tries two different free, no-key IP-geolocation providers in turn,
  /// since a single provider can be flaky or rate-limited on some
  /// networks, and IP-based location can be inaccurate on mobile data.
  Future<_GeoResult?> _lookupGeoByIp() async {
    try {
      final res = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final geo = jsonDecode(res.body);
        if (geo['latitude'] != null && geo['longitude'] != null) {
          return _GeoResult(lat: geo['latitude'], lon: geo['longitude'], city: (geo['city'] as String?) ?? '');
        }
        debugPrint('[WeatherService] ipapi.co returned no coordinates: $geo');
      } else {
        debugPrint('[WeatherService] ipapi.co failed: HTTP ${res.statusCode} -- ${res.body}');
      }
    } catch (e) {
      debugPrint('[WeatherService] ipapi.co exception: $e');
    }

    try {
      final res = await http.get(Uri.parse('https://ipwho.is/')).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final geo = jsonDecode(res.body);
        if (geo['success'] != false && geo['latitude'] != null && geo['longitude'] != null) {
          return _GeoResult(lat: geo['latitude'], lon: geo['longitude'], city: (geo['city'] as String?) ?? '');
        }
        debugPrint('[WeatherService] ipwho.is returned no coordinates: $geo');
      } else {
        debugPrint('[WeatherService] ipwho.is failed: HTTP ${res.statusCode} -- ${res.body}');
      }
    } catch (e) {
      debugPrint('[WeatherService] ipwho.is exception: $e');
    }

    debugPrint('[WeatherService] both geo providers failed -- giving up for this attempt.');
    return null;
  }

  String _mapCondition(int code, double temp) {
    const rainCodes = [51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99];
    const clearCodes = [0, 1]; // clear sky, mainly clear
    if (rainCodes.contains(code)) return 'Rainy';
    if (clearCodes.contains(code)) return 'Sunny';
    if (temp <= 15) return 'Cold';
    if (temp >= 33) return 'Hot';
    return 'Mild';
  }
}

class _GeoResult {
  final double lat;
  final double lon;
  final String city;
  _GeoResult({required this.lat, required this.lon, required this.city});
}
