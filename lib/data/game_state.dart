import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameScreen {
  splash,
  menu,
  playing,
  paused,
  gameOver,
  routeComplete,
  garage,
  survivalGuide,
  settings,
  privacyPolicy,
}

enum GameOverReason { wrecked, fired, outOfFuel }

class GameState extends ChangeNotifier {
  GameScreen _currentScreen = GameScreen.splash;
  int _lives = 3;
  int _coins = 0;
  int _currentRoute = 1;
  int _highestUnlockedRoute = 1;
  int _hazardsHit = 0;
  double _distanceTraveled = 0;
  double _deadlineRemaining = 1.0;
  GameOverReason _gameOverReason = GameOverReason.wrecked;
  int _fuelCoinsCollected = 0;
  int _fuelCoinsRequired = 0;
  final Map<String, int> _upgradeLevels = {
    'suspension': 0,
    'tires': 0,
    'engine': 0,
  };

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;

  GameScreen get currentScreen => _currentScreen;
  int get lives => _lives;
  int get coins => _coins;
  int get currentRoute => _currentRoute;
  int get highestUnlockedRoute => _highestUnlockedRoute;
  int get hazardsHit => _hazardsHit;
  double get distanceTraveled => _distanceTraveled;
  double get deadlineRemaining => _deadlineRemaining;
  GameOverReason get gameOverReason => _gameOverReason;
  int get fuelCoinsCollected => _fuelCoinsCollected;
  int get fuelCoinsRequired => _fuelCoinsRequired;
  bool get hasSufficientFuel => _fuelCoinsCollected >= _fuelCoinsRequired;
  Map<String, int> get upgradeLevels => Map.unmodifiable(_upgradeLevels);

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  // --- Persistence ---

  static const _keyCoins = 'coins';
  static const _keyHighestRoute = 'highestUnlockedRoute';
  static const _keySuspension = 'upgrade_suspension';
  static const _keyTires = 'upgrade_tires';
  static const _keyEngine = 'upgrade_engine';
  static const _keySfx = 'sfxEnabled';
  static const _keyMusic = 'musicEnabled';
  static const _keyVibration = 'vibrationEnabled';

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(_keyCoins) ?? 0;
    _highestUnlockedRoute = prefs.getInt(_keyHighestRoute) ?? 1;
    _currentRoute = _highestUnlockedRoute;
    _upgradeLevels['suspension'] = prefs.getInt(_keySuspension) ?? 0;
    _upgradeLevels['tires'] = prefs.getInt(_keyTires) ?? 0;
    _upgradeLevels['engine'] = prefs.getInt(_keyEngine) ?? 0;
    _sfxEnabled = prefs.getBool(_keySfx) ?? true;
    _musicEnabled = prefs.getBool(_keyMusic) ?? true;
    _vibrationEnabled = prefs.getBool(_keyVibration) ?? true;
    notifyListeners();
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCoins, _coins);
    await prefs.setInt(_keyHighestRoute, _highestUnlockedRoute);
    await prefs.setInt(_keySuspension, _upgradeLevels['suspension'] ?? 0);
    await prefs.setInt(_keyTires, _upgradeLevels['tires'] ?? 0);
    await prefs.setInt(_keyEngine, _upgradeLevels['engine'] ?? 0);
    await prefs.setBool(_keySfx, _sfxEnabled);
    await prefs.setBool(_keyMusic, _musicEnabled);
    await prefs.setBool(_keyVibration, _vibrationEnabled);
  }

  // --- Screen ---

  void setScreen(GameScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  // --- Lives ---

  void setLives(int lives) {
    _lives = lives;
    notifyListeners();
  }

  void loseLife() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
    }
  }

  void resetLives() {
    _lives = 3;
    notifyListeners();
  }

  // --- Coins ---

  void addCoins(int amount) {
    _coins += amount;
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Routes ---

  void setCurrentRoute(int route) {
    _currentRoute = route;
    notifyListeners();
  }

  void unlockNextRoute(int completedRoute) {
    final next = completedRoute + 1;
    if (next > _highestUnlockedRoute) {
      _highestUnlockedRoute = next;
    }
  }

  // --- Upgrades ---

  int getUpgradeLevel(String upgrade) => _upgradeLevels[upgrade] ?? 0;

  void setUpgradeLevel(String upgrade, int level) {
    _upgradeLevels[upgrade] = level;
    notifyListeners();
  }

  // --- Run state ---

  void incrementHazardsHit() {
    _hazardsHit++;
    notifyListeners();
  }

  void setDistanceTraveled(double distance) {
    if ((_distanceTraveled - distance).abs() < 0.5) return;
    _distanceTraveled = distance;
    notifyListeners();
  }

  void setDeadlineRemaining(double remaining) {
    if ((_deadlineRemaining - remaining).abs() < 0.005) return;
    _deadlineRemaining = remaining;
    notifyListeners();
  }

  void setGameOverReason(GameOverReason reason) {
    _gameOverReason = reason;
  }

  void collectFuelCoin() {
    _fuelCoinsCollected++;
    notifyListeners();
  }

  void setFuelCoinsRequired(int amount) {
    _fuelCoinsRequired = amount;
  }

  void resetRunState() {
    _lives = 3;
    _hazardsHit = 0;
    _distanceTraveled = 0;
    _deadlineRemaining = 1.0;
    _fuelCoinsCollected = 0;
    _fuelCoinsRequired = 0;
    notifyListeners();
  }

  // --- Settings ---

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
    notifyListeners();
    saveProgress();
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    notifyListeners();
    saveProgress();
  }

  void toggleVibration() {
    _vibrationEnabled = !_vibrationEnabled;
    notifyListeners();
    saveProgress();
  }
}
