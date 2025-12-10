class_name BattleAnalysisConfig extends Resource

## Configuration constants for battle analysis system

## Performance thresholds (0-100 ratings)
const EXCELLENT_THRESHOLD = 80.0
const GOOD_THRESHOLD = 60.0
const POOR_THRESHOLD = 40.0

## Damage thresholds
const HIGH_DAMAGE_PER_TURN = 30.0
const LOW_DAMAGE_PER_TURN = 15.0

## Defense thresholds
const CRITICAL_HP_THRESHOLD = 25.0
const LOW_HP_THRESHOLD = 50.0
const HEAVY_DAMAGE_TAKEN = 80

## Shield thresholds
const GOOD_SHIELD_EFFICIENCY = 70.0
const POOR_SHIELD_EFFICIENCY = 30.0

## Power efficiency thresholds
const EXCELLENT_POWER_EFFICIENCY = 90.0
const POOR_POWER_EFFICIENCY = 60.0

## Room loss thresholds
const CRITICAL_ROOM_LOSSES = 5
const MODERATE_ROOM_LOSSES = 3

## Initiative thresholds
const GOOD_ENGINE_COUNT = 3
const MINIMUM_ENGINE_COUNT = 2

## Animation timings (seconds)
const PANEL_FADE_IN_TIME = 0.3
const PANEL_FADE_OUT_TIME = 0.3
const STAT_REVEAL_DELAY = 0.1
const STAT_REVEAL_TIME = 0.3

## Stat weight for calculations
const DAMAGE_WEIGHT = 1.0
const DEFENSE_WEIGHT = 1.0
const EFFICIENCY_WEIGHT = 0.8
const SURVIVAL_WEIGHT = 1.2
