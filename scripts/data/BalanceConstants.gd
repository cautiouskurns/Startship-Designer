class_name BalanceConstants

## Centralized game balance constants for easy tuning
## Phase 1: Extracted from scattered magic numbers across codebase
## Future: These will be loaded from JSON files for data-driven balance

## ============================================================================
## COMBAT BALANCE CONSTANTS
## ============================================================================

## Damage calculation
const DAMAGE_PER_WEAPON: int = 10  # Base damage dealt by each powered weapon
const FIRE_RATE_SYNERGY_BONUS: float = 0.15  # 15% bonus damage per weapon with synergy

## Shield calculation
const SHIELD_ABSORPTION_PER_SHIELD: int = 15  # HP absorbed by each powered shield
const SHIELD_CAPACITY_SYNERGY_BONUS: float = 0.20  # 20% bonus absorption per shield with synergy

## Room destruction
const ROOM_DESTRUCTION_THRESHOLD: int = 10  # Damage required to destroy one room (changed from 20)

## Hull HP
const BASE_HULL_HP: int = 60  # Base hull HP before armor bonuses
const HP_PER_ARMOR: int = 20  # Additional HP granted by each armor room

## Initiative
const INITIATIVE_SYNERGY_BONUS: int = 1  # Bonus initiative per engine synergy

## Synergy effects
const DURABILITY_SYNERGY_RESISTANCE_CHANCE: float = 0.25  # 25% chance weapon resists destruction

## ============================================================================
## POWER SYSTEM CONSTANTS
## ============================================================================

const RELAY_COVERAGE_RADIUS: float = 3.0  # Radius in tiles for relay coverage

## ============================================================================
## COMBAT UI CONSTANTS
## ============================================================================

const COMBAT_SPEED_DEFAULT: float = 2.0  # Default speed multiplier (2.0 = 0.5x speed)
const COMBAT_ZOOM_MIN: float = 0.5
const COMBAT_ZOOM_MAX: float = 1.5
const COMBAT_ZOOM_STEP: float = 0.25
const COMBAT_PAN_SPEED: float = 20.0  # Pixels per frame when panning with WASD
const COMBAT_PAN_LIMIT: float = 300.0  # Maximum pan offset in pixels

## ============================================================================
## DESIGNER UI CONSTANTS
## ============================================================================

const DESIGNER_ZOOM_MIN: float = 0.5
const DESIGNER_ZOOM_MAX: float = 3.0
const DESIGNER_ZOOM_STEP: float = 0.1
const DESIGNER_PAN_SPEED: float = 10.0  # Pixels per frame when panning with WASD
const DESIGNER_TILE_SIZE: int = 25  # Size of each grid tile in pixels
const DESIGNER_TILE_SPACING: int = 2  # Gap between tiles in pixels

## ============================================================================
## DISPLAY CONSTANTS
## ============================================================================

const COMBAT_DISPLAY_TILE_SIZE: int = 96  # Size of tiles in combat ship display

## ============================================================================
## RATING THRESHOLDS (for ship stats 0-100 scale)
## ============================================================================

const OFFENSE_RATING_MAX_DAMAGE: int = 50  # Damage value that gives 100 rating
const DEFENSE_RATING_MAX_VALUE: int = 200  # Defense value that gives 100 rating
const THRUST_RATING_MAX_INITIATIVE: int = 4  # Initiative value that gives 100 rating
const SHIELD_VALUE_MULTIPLIER: int = 2  # Shields worth 2x HP in defense rating

## ============================================================================
## BUDGET DISPLAY THRESHOLDS
## ============================================================================

const BUDGET_GREEN_THRESHOLD: int = 5  # Remaining budget > 5 displays as green
const BUDGET_YELLOW_THRESHOLD: int = 1  # Remaining budget >= 1 displays as yellow

## ============================================================================
## STANDARD UI COLOR PALETTE
## ============================================================================

const COLOR_RED := Color(0.886, 0.290, 0.290)  # #E24A4A - Danger, enemy, damage
const COLOR_CYAN := Color(0.290, 0.886, 0.886)  # #4AE2E2 - Player, shields, info
const COLOR_GREEN := Color(0.290, 0.886, 0.290)  # #4AE24A - Success, positive, valid
const COLOR_YELLOW := Color(0.886, 0.831, 0.290)  # #E2D44A - Warning, caution
const COLOR_ORANGE := Color(0.886, 0.627, 0.290)  # #E2A04A - Damage, engines
const COLOR_BLUE := Color(0.290, 0.565, 0.886)  # #4A90E2 - Bridge, primary
const COLOR_PURPLE := Color(0.627, 0.290, 0.886)  # #A04AE2 - Special, status
const COLOR_GRAY := Color(0.667, 0.667, 0.667)  # #AAAAAA - Neutral, disabled
