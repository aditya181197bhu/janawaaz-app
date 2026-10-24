import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../l10n/strings.dart';
import '../models/meta.dart';
import '../services/api_service.dart';

enum Profile { janta, volunteer, admin }

/// App-wide state: language, demo profile, cached reference data and settings.
class AppState extends ChangeNotifier {
  static const _kLanguage = 'language';
  static const _kProfile = 'profile';
  static const _kDemoLocation = 'demoLocation';
  static const _kJantaWard = 'jantaWard';
  static const _kDutyWard = 'dutyWard';

  final _api = ApiService.instance;
  SharedPreferences? _prefs;

  bool loaded = false;
  String? language;
  Profile? profile;
  bool demoLocation = false;
  int? jantaWardId;
  int? dutyWardId;

  /// Bumped after a survey or complaint is submitted so open screens reload.
  int dataVersion = 0;

  List<Ward> _wards = [];
  List<Question> _questions = [];

  bool get hindi => language == 'hi';

  Strings get s => Strings(hindi);

  List<Ward> get wards => _wards;

  List<Question> get questions => _questions;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    language = _prefs!.getString(_kLanguage);
    final p = _prefs!.getString(_kProfile);
    profile = p == null ? null : Profile.values.byName(p);
    demoLocation = _prefs!.getBool(_kDemoLocation) ?? false;
    jantaWardId = _prefs!.getInt(_kJantaWard);
    dutyWardId = _prefs!.getInt(_kDutyWard);
    loaded = true;
    notifyListeners();
  }

  void setLanguage(String code) {
    language = code;
    _prefs?.setString(_kLanguage, code);
    notifyListeners();
  }

  void toggleLanguage() => setLanguage(hindi ? 'en' : 'hi');

  void setProfile(Profile? value) {
    profile = value;
    if (value == null) {
      _prefs?.remove(_kProfile);
    } else {
      _prefs?.setString(_kProfile, value.name);
    }
    notifyListeners();
  }

  void setDemoLocation(bool value) {
    demoLocation = value;
    _prefs?.setBool(_kDemoLocation, value);
    notifyListeners();
  }

  void setJantaWard(int id) {
    jantaWardId = id;
    _prefs?.setInt(_kJantaWard, id);
    notifyListeners();
  }

  void setDutyWard(int id) {
    dutyWardId = id;
    _prefs?.setInt(_kDutyWard, id);
    notifyListeners();
  }

  void dataChanged() {
    dataVersion++;
    notifyListeners();
  }

  Future<List<Ward>> ensureWards() async {
    if (_wards.isEmpty) _wards = await _api.wards();
    return _wards;
  }

  Future<List<Question>> ensureQuestions() async {
    if (_questions.isEmpty) _questions = await _api.questions();
    return _questions;
  }

  Ward ward(int id) => _wards.firstWhere((w) => w.id == id);

  Question question(int id) => _questions.firstWhere((q) => q.id == id);

  int get volunteerId => ApiConfig.demoVolunteerId;
}
