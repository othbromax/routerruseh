import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_rush/data/dls.dart';
import 'package:route_rush/data/game_state.dart';
import 'package:route_rush/data/route_data.dart';
import 'package:route_rush/game/route_rush_game.dart';
import 'package:route_rush/screens/game_over_screen.dart';
import 'package:route_rush/screens/gameplay_hud.dart';
import 'package:route_rush/screens/garage_screen.dart';
import 'package:route_rush/screens/main_menu_screen.dart';
import 'package:route_rush/screens/pause_menu.dart';
import 'package:route_rush/screens/privacy_policy_screen.dart';
import 'package:route_rush/screens/route_complete_screen.dart';
import 'package:route_rush/screens/settings_screen.dart';
import 'package:route_rush/screens/splash_screen.dart';
import 'package:route_rush/screens/survival_guide_screen.dart';
import 'package:route_rush/game/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const RouteRushApp());
}

class RouteRushApp extends StatefulWidget {
  const RouteRushApp({super.key});

  @override
  State<RouteRushApp> createState() => _RouteRushAppState();
}

class _RouteRushAppState extends State<RouteRushApp> {
  final GameState gameState = GameState();
  late final RouteRushGame _game;
  late final AudioManager _audio;

  int _lastBasePay = 0;
  int _lastTimeBonus = 0;
  int _lastCleanRideBonus = 0;
  bool _payoutCalculated = false;

  @override
  void initState() {
    super.initState();
    _audio = AudioManager(gameState);
    _game = RouteRushGame();
    _game.gameState = gameState;
    _game.audioManager = _audio;
    gameState.addListener(_onGameStateChanged);
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    await gameState.loadProgress();
  }

  void _onGameStateChanged() {
    if (gameState.currentScreen == GameScreen.routeComplete && !_payoutCalculated) {
      _payoutCalculated = true;
      _calculatePayout();
    }
  }

  @override
  void dispose() {
    gameState.removeListener(_onGameStateChanged);
    _audio.dispose();
    gameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Route Rush',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.scuffedBlack,
      ),
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: _game,
            ),
            ListenableBuilder(
              listenable: gameState,
              builder: (context, _) => _buildCurrentScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (gameState.currentScreen) {
      case GameScreen.splash:
        return SplashScreen(
          onComplete: () => gameState.setScreen(GameScreen.menu),
        );

      case GameScreen.menu:
        _game.stopRun();
        return MainMenuScreen(
          gameState: gameState,
          onStartGame: _startGame,
        );

      case GameScreen.playing:
        return GameplayHud(
          gameState: gameState,
          onPause: _pauseGame,
        );

      case GameScreen.paused:
        return PauseMenu(
          onResume: _resumeGame,
          onQuit: _quitToMenu,
          hapticEnabled: gameState.vibrationEnabled,
        );

      case GameScreen.gameOver:
        return GameOverScreen(
          gameState: gameState,
          onRetry: _retryRoute,
          onMainMenu: _quitToMenu,
        );

      case GameScreen.routeComplete:
        return RouteCompleteScreen(
          gameState: gameState,
          basePay: _lastBasePay,
          timeBonus: _lastTimeBonus,
          cleanRideBonus: _lastCleanRideBonus,
          onNextRoute: _nextRoute,
          onGarage: () => gameState.setScreen(GameScreen.garage),
          onMainMenu: _quitToMenu,
        );

      case GameScreen.garage:
        return GarageScreen(
          gameState: gameState,
          onBack: () => gameState.setScreen(GameScreen.menu),
        );

      case GameScreen.survivalGuide:
        return SurvivalGuideScreen(
          onBack: () => gameState.setScreen(GameScreen.menu),
        );

      case GameScreen.settings:
        return SettingsScreen(
          gameState: gameState,
          onBack: () => gameState.setScreen(GameScreen.menu),
        );

      case GameScreen.privacyPolicy:
        return PrivacyPolicyScreen(
          onBack: () => gameState.setScreen(GameScreen.menu),
        );
    }
  }

  void _startGame() {
    _payoutCalculated = false;
    gameState.resetRunState();
    final routeDef = getRouteDefinition(gameState.currentRoute);
    _game.startRun(routeDef);
    _game.resumeEngine();
    gameState.setScreen(GameScreen.playing);
    _audio.playIgnition();
  }

  void _pauseGame() {
    _game.pauseEngine();
    gameState.setScreen(GameScreen.paused);
    _audio.playTireScreech();
  }

  void _resumeGame() {
    _game.resumeEngine();
    gameState.setScreen(GameScreen.playing);
  }

  void _quitToMenu() {
    _game.stopRun();
    _game.resumeEngine();
    gameState.setScreen(GameScreen.menu);
  }

  void _retryRoute() {
    _payoutCalculated = false;
    gameState.resetRunState();
    final routeDef = getRouteDefinition(gameState.currentRoute);
    _game.startRun(routeDef);
    _game.resumeEngine();
    gameState.setScreen(GameScreen.playing);
    _audio.playIgnition();
  }

  void _nextRoute() {
    final nextRoute = gameState.currentRoute + 1;
    if (nextRoute <= allRoutes.length && nextRoute <= gameState.highestUnlockedRoute) {
      gameState.setCurrentRoute(nextRoute);
    }
    _startGame();
  }

  void _calculatePayout() {
    final routeDef = getRouteDefinition(gameState.currentRoute);
    _lastBasePay = routeDef.basePay;

    final deadlineRemaining = gameState.deadlineRemaining;
    _lastTimeBonus = (routeDef.basePay * 0.5 * deadlineRemaining).round();

    _lastCleanRideBonus = gameState.hazardsHit == 0
        ? (routeDef.basePay * 0.5).round()
        : 0;

    final total = _lastBasePay + _lastTimeBonus + _lastCleanRideBonus;
    gameState.addCoins(total);
    gameState.unlockNextRoute(gameState.currentRoute);
    gameState.saveProgress();
    _audio.playReceiptPrint();
  }
}
