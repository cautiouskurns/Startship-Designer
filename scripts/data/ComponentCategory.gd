class_name ComponentCategory
extends RefCounted

## Component Category System
## Organizes ship components into 7 functional categories for UI browsing
## Part of Component Category System - Feature 01: Seven-Category Structure

enum Category {
	POWER_SYSTEMS,      # ⚡ Generate, store, and distribute power
	WEAPONS,            # 🎯 Deal damage to enemy ships
	DEFENSE,            # 🛡️ Absorb damage and protect the ship
	PROPULSION,         # 🚀 Control initiative, speed, and maneuverability
	COMMAND_CONTROL,    # 🖥️ Required systems, sensors, targeting
	UTILITY_SUPPORT,    # 🔧 Special functions, mission-specific modules
	STRUCTURE,          # 🏗️ Hull framework, compartments, passive systems
}

## Get human-readable category name
static func get_category_name(category: Category) -> String:
	match category:
		Category.POWER_SYSTEMS:
			return "Power Systems"
		Category.WEAPONS:
			return "Weapons"
		Category.DEFENSE:
			return "Defense"
		Category.PROPULSION:
			return "Propulsion"
		Category.COMMAND_CONTROL:
			return "Command & Control"
		Category.UTILITY_SUPPORT:
			return "Utility & Support"
		Category.STRUCTURE:
			return "Structure"
		_:
			return "Unknown"

## Get icon for category (UI display)
static func get_category_icon(category: Category) -> String:
	match category:
		Category.POWER_SYSTEMS:
			return "⊕"  # Power core symbol (matches Reactor)
		Category.WEAPONS:
			return "▶"  # Arrow/projectile (matches Weapon)
		Category.DEFENSE:
			return "◆"  # Shield shape (matches Shield)
		Category.PROPULSION:
			return "▲"  # Thruster/forward (matches Engine)
		Category.COMMAND_CONTROL:
			return "⭐"  # Command star (matches Bridge)
		Category.UTILITY_SUPPORT:
			return "◇"  # Utility diamond
		Category.STRUCTURE:
			return "■"  # Solid structure block
		_:
			return "?"

## Get category description (tooltip/header subtitle)
static func get_category_description(category: Category) -> String:
	match category:
		Category.POWER_SYSTEMS:
			return "Generate, store, and distribute power to your ship's systems"
		Category.WEAPONS:
			return "Deal damage to enemy ships with energy and projectile weapons"
		Category.DEFENSE:
			return "Protect your ship with shields, armor, and defensive systems"
		Category.PROPULSION:
			return "Control initiative, speed, and maneuverability in combat"
		Category.COMMAND_CONTROL:
			return "Command centers, sensors, and targeting systems"
		Category.UTILITY_SUPPORT:
			return "Repair bays, cargo, and special mission systems"
		Category.STRUCTURE:
			return "Hull plating, bulkheads, and structural components"
		_:
			return ""

## Get category signature color (for visual theming)
static func get_category_color(category: Category) -> Color:
	match category:
		Category.POWER_SYSTEMS:
			return Color(0.886, 0.831, 0.290)  # Yellow/gold #E2D44A
		Category.WEAPONS:
			return Color(0.886, 0.290, 0.290)  # Red #E24A4A
		Category.DEFENSE:
			return Color(0.290, 0.886, 0.886)  # Cyan #4AE2E2
		Category.PROPULSION:
			return Color(0.886, 0.627, 0.290)  # Orange #E2A04A
		Category.COMMAND_CONTROL:
			return Color(0.290, 0.565, 0.886)  # Blue #4A90E2
		Category.UTILITY_SUPPORT:
			return Color(0.290, 0.886, 0.290)  # Green #4AE24A
		Category.STRUCTURE:
			return Color(0.424, 0.424, 0.424)  # Gray #6C6C6C
		_:
			return Color(0.5, 0.5, 0.5)  # Default gray

## Get full category display string (icon + name)
static func get_category_display_name(category: Category) -> String:
	return "%s %s" % [get_category_icon(category), get_category_name(category)]

## Count number of categories
static func get_category_count() -> int:
	return Category.size()

## Get all categories as array (for iteration)
static func get_all_categories() -> Array[Category]:
	var categories: Array[Category] = []
	for i in range(Category.size()):
		categories.append(i as Category)
	return categories
