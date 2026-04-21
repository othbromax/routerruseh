enum HazardType { pothole, nailsGlass, barricade, oilSpill, trafficCone }

class RouteDefinition {
  final int routeNumber;
  final String zoneName;
  final double targetDistance;
  final double deadlineFillRate;
  final double spawnInterval;
  final double obstacleSpeed;
  final List<HazardType> availableHazards;
  final int basePay;
  final int requiredCoins;
  final double coinSpawnInterval;

  const RouteDefinition({
    required this.routeNumber,
    required this.zoneName,
    required this.targetDistance,
    required this.deadlineFillRate,
    required this.spawnInterval,
    required this.obstacleSpeed,
    required this.availableHazards,
    required this.basePay,
    required this.requiredCoins,
    required this.coinSpawnInterval,
  });
}

class UpgradeDefinition {
  final String name;
  final String id;
  final String description;
  final List<UpgradeTier> tiers;

  const UpgradeDefinition({
    required this.name,
    required this.id,
    required this.description,
    required this.tiers,
  });
}

class UpgradeTier {
  final int level;
  final int cost;
  final String label;
  final double effectValue;

  const UpgradeTier({
    required this.level,
    required this.cost,
    required this.label,
    required this.effectValue,
  });
}

const List<RouteDefinition> allRoutes = [
  // Zone 1: The Suburbs (Routes 1-3) - potholes + traffic cones
  RouteDefinition(
    routeNumber: 1,
    zoneName: 'The Suburbs',
    targetDistance: 1000,
    deadlineFillRate: 0.022,
    spawnInterval: 2.0,
    obstacleSpeed: 280,
    availableHazards: [HazardType.pothole],
    basePay: 50,
    requiredCoins: 3,
    coinSpawnInterval: 3.0,
  ),
  RouteDefinition(
    routeNumber: 2,
    zoneName: 'The Suburbs',
    targetDistance: 1400,
    deadlineFillRate: 0.018,
    spawnInterval: 1.8,
    obstacleSpeed: 300,
    availableHazards: [HazardType.pothole, HazardType.trafficCone],
    basePay: 70,
    requiredCoins: 4,
    coinSpawnInterval: 2.8,
  ),
  RouteDefinition(
    routeNumber: 3,
    zoneName: 'The Suburbs',
    targetDistance: 1800,
    deadlineFillRate: 0.015,
    spawnInterval: 1.6,
    obstacleSpeed: 320,
    availableHazards: [HazardType.pothole, HazardType.trafficCone],
    basePay: 90,
    requiredCoins: 5,
    coinSpawnInterval: 2.5,
  ),
  // Zone 2: Industrial Zone (Routes 4-6) - add nails, oil, barricades
  RouteDefinition(
    routeNumber: 4,
    zoneName: 'Industrial Zone',
    targetDistance: 2200,
    deadlineFillRate: 0.013,
    spawnInterval: 1.4,
    obstacleSpeed: 340,
    availableHazards: [HazardType.pothole, HazardType.nailsGlass, HazardType.trafficCone],
    basePay: 120,
    requiredCoins: 6,
    coinSpawnInterval: 2.4,
  ),
  RouteDefinition(
    routeNumber: 5,
    zoneName: 'Industrial Zone',
    targetDistance: 2600,
    deadlineFillRate: 0.012,
    spawnInterval: 1.3,
    obstacleSpeed: 360,
    availableHazards: [HazardType.pothole, HazardType.nailsGlass, HazardType.barricade, HazardType.oilSpill],
    basePay: 150,
    requiredCoins: 7,
    coinSpawnInterval: 2.2,
  ),
  RouteDefinition(
    routeNumber: 6,
    zoneName: 'Industrial Zone',
    targetDistance: 3000,
    deadlineFillRate: 0.0112,
    spawnInterval: 1.2,
    obstacleSpeed: 380,
    availableHazards: [HazardType.pothole, HazardType.nailsGlass, HazardType.barricade, HazardType.oilSpill, HazardType.trafficCone],
    basePay: 180,
    requiredCoins: 8,
    coinSpawnInterval: 2.0,
  ),
  // Zone 3: The Gridlock (Routes 7-10) - all hazards, more coins required
  RouteDefinition(
    routeNumber: 7,
    zoneName: 'The Gridlock',
    targetDistance: 3500,
    deadlineFillRate: 0.0105,
    spawnInterval: 1.0,
    obstacleSpeed: 400,
    availableHazards: [HazardType.pothole, HazardType.nailsGlass, HazardType.barricade, HazardType.oilSpill, HazardType.trafficCone],
    basePay: 220,
    requiredCoins: 10,
    coinSpawnInterval: 1.8,
  ),
  RouteDefinition(
    routeNumber: 8,
    zoneName: 'The Gridlock',
    targetDistance: 4000,
    deadlineFillRate: 0.0098,
    spawnInterval: 0.9,
    obstacleSpeed: 420,
    availableHazards: [HazardType.pothole, HazardType.nailsGlass, HazardType.barricade, HazardType.oilSpill, HazardType.trafficCone],
    basePay: 260,
    requiredCoins: 12,
    coinSpawnInterval: 1.6,
  ),
  RouteDefinition(
    routeNumber: 9,
    zoneName: 'The Gridlock',
    targetDistance: 4500,
    deadlineFillRate: 0.0093,
    spawnInterval: 0.8,
    obstacleSpeed: 440,
    availableHazards: [HazardType.pothole, HazardType.nailsGlass, HazardType.barricade, HazardType.oilSpill, HazardType.trafficCone],
    basePay: 300,
    requiredCoins: 14,
    coinSpawnInterval: 1.4,
  ),
  RouteDefinition(
    routeNumber: 10,
    zoneName: 'The Gridlock',
    targetDistance: 5000,
    deadlineFillRate: 0.009,
    spawnInterval: 0.7,
    obstacleSpeed: 460,
    availableHazards: [HazardType.pothole, HazardType.nailsGlass, HazardType.barricade, HazardType.oilSpill, HazardType.trafficCone],
    basePay: 350,
    requiredCoins: 16,
    coinSpawnInterval: 1.2,
  ),
];

const List<UpgradeDefinition> allUpgrades = [
  UpgradeDefinition(
    name: 'Suspension',
    id: 'suspension',
    description: 'Reduces speed penalty from potholes',
    tiers: [
      UpgradeTier(level: 1, cost: 80, label: 'Stock Shocks', effectValue: 0.35),
      UpgradeTier(level: 2, cost: 180, label: 'Sport Dampers', effectValue: 0.28),
      UpgradeTier(level: 3, cost: 350, label: 'Rally Suspension', effectValue: 0.20),
      UpgradeTier(level: 4, cost: 600, label: 'Competition Kit', effectValue: 0.12),
    ],
  ),
  UpgradeDefinition(
    name: 'Tires',
    id: 'tires',
    description: 'Reduces flat-tire drift duration',
    tiers: [
      UpgradeTier(level: 1, cost: 80, label: 'Budget Rubber', effectValue: 3.2),
      UpgradeTier(level: 2, cost: 180, label: 'All-Terrain', effectValue: 2.5),
      UpgradeTier(level: 3, cost: 350, label: 'Puncture-Resistant', effectValue: 1.8),
      UpgradeTier(level: 4, cost: 600, label: 'Kevlar-Lined', effectValue: 1.0),
    ],
  ),
  UpgradeDefinition(
    name: 'Engine',
    id: 'engine',
    description: 'Increases top speed for deadline breathing room',
    tiers: [
      UpgradeTier(level: 1, cost: 100, label: 'Tuned Intake', effectValue: 1.08),
      UpgradeTier(level: 2, cost: 220, label: 'Turbo Kit', effectValue: 1.16),
      UpgradeTier(level: 3, cost: 420, label: 'Forged Internals', effectValue: 1.25),
      UpgradeTier(level: 4, cost: 700, label: 'Race Engine', effectValue: 1.35),
    ],
  ),
];

RouteDefinition getRouteDefinition(int routeNumber) {
  return allRoutes.firstWhere(
    (r) => r.routeNumber == routeNumber,
    orElse: () => allRoutes.last,
  );
}
