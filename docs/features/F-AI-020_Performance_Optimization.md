# F-AI-020: Performance Optimization

**Status:** 🔴 Planned
**Priority:** ⬆️ High
**Estimated Time:** 1 day
**Dependencies:** All Phase 1-3 features
**Phase:** 5 - Polish & Balance

---

## Purpose

**Why does this feature exist?**
Complex AI systems can cause lag if not optimized. Performance optimization ensures 60fps combat with no hitches, freezes, or delays.

**What does it enable?**
Smooth combat experience regardless of AI complexity. Player doesn't notice AI "thinking time." Scalable to larger ships (10×8) or multi-ship battles in future.

**Success criteria:**
- AI decision-making completes in <50ms total per turn
- Combat maintains 60fps throughout (no frame drops)
- Memory usage stable (<100MB increase during combat)
- No garbage collection spikes (no stuttering)

---

## How It Works

### Overview

**Performance Profiling (0.5 days):**
1. Profile AI systems with Godot profiler
2. Identify bottlenecks (functions taking >10ms)
3. Measure frame time, memory allocation, GC pressure

**Optimization Pass (0.5 days):**
1. Cache expensive calculations (threat maps, power grids)
2. Reduce redundant computations (don't recalculate every turn)
3. Use object pooling for UI elements (thought bubbles, damage numbers)
4. Optimize hot paths (TargetScoring, ThreatAssessment loops)
5. Defer non-critical updates (UI updates after combat logic)

---

## Optimization Targets

**AI Decision Time Budget:**
- ShipProfileAnalyzer: <10ms (once at combat start)
- CombatStateEvaluator: <5ms per turn
- ThreatAssessment: <10ms per turn
- TargetScoring: <5ms per turn
- PredictivePlanning: <20ms per turn (most expensive)
- **Total AI per turn: <50ms** (leaves 11ms for rendering at 60fps)

**Memory Management:**
- Pre-allocate common data structures (avoid runtime allocation)
- Object pooling for transient objects (thought bubbles, damage numbers)
- Clear references to allow GC (no memory leaks)

**Rendering Optimization:**
- Batch UI updates (don't update labels every frame)
- Use CanvasItem.hide() instead of queue_free() for reusable UI
- Limit active particle effects (<5 simultaneous)

---

## Profiling Checklist

**Measure:**
- [ ] Frame time during combat (target: <16.67ms for 60fps)
- [ ] AI decision time per turn (target: <50ms)
- [ ] Memory allocation per combat (target: <100MB)
- [ ] GC frequency (target: <1 per minute)

**Common Bottlenecks:**
- Nested loops in threat calculation (O(n²) → O(n))
- String concatenation in combat log (use StringBuffer)
- Redundant ShipData queries (cache room counts)
- UI updates every frame (batch and defer)

---

## Optimization Techniques

**1. Caching:**
```gdscript
# Bad: Recalculate every turn
var threat_score = calculate_threat(room)

# Good: Cache and invalidate when needed
if threat_cache_dirty:
    threat_cache = calculate_all_threats()
    threat_cache_dirty = false
var threat_score = threat_cache[room_id]
```

**2. Early Exit:**
```gdscript
# Bad: Check all rooms
for room in enemy_ship.rooms:
    if is_valid_target(room):
        targets.append(room)

# Good: Exit early when found
for room in enemy_ship.rooms:
    if is_valid_target(room):
        return room  # Found first valid target
```

**3. Object Pooling:**
```gdscript
# Bad: Create/destroy every time
var bubble = ThoughtBubble.new()
bubble.show_thought(text)
bubble.queue_free()  # GC pressure

# Good: Pool and reuse
var bubble = thought_bubble_pool.get()
bubble.show_thought(text)
thought_bubble_pool.release(bubble)
```

---

## Acceptance Criteria

- [ ] Combat maintains 60fps with full AI system active
- [ ] AI decision time <50ms per turn (measured via profiler)
- [ ] No frame drops during combat (frame time <16.67ms)
- [ ] Memory stable (<100MB increase from combat start to end)
- [ ] No GC spikes during combat (no stuttering)
- [ ] Performance consistent across 10+ consecutive battles

---

## Deliverables

**Performance Report** (docs/performance/AI_Performance_Report.md):
- Profiling screenshots (before/after optimization)
- Benchmarks: frame time, AI time, memory usage
- Optimization techniques applied
- Remaining bottlenecks (if any)

---

## Implementation Notes

**Tools**: Godot profiler, VisualProfiler plugin, custom timing macros.
**Philosophy**: Profile first, optimize second. Don't guess bottlenecks.

---

## Change Log

| Date | Change | Reason |
|------|--------|--------|
| Dec 10 2025 | Initial spec | Feature planned |
