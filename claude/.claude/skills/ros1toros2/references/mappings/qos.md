# qos

## Scope

Maps ROS1's mostly implicit transport expectations to ROS2 Jazzy's explicit QoS model. Covers default reliable behavior, sensor-data profiles, transient-local equivalents for latched topics, and when QoS decisions become real surface changes.

## Symbol Mapping Table

| ROS1 | ROS2 (Jazzy) | Notes / Pitfalls | API ref |
|---|---|---|---|
| implicit reliable publisher/subscriber behavior | default QoS (`reliable`, `volatile`, depth 10) | Usually the closest default baseline | `api/docs-ros-org-jazzy-concepts-about-quality-of-service-settings.md` |
| `queue_size=10` | explicit history depth 10 | ROS2 surfaces queueing as QoS rather than a standalone arg | `api/docs-ros-org-jazzy-concepts-about-quality-of-service-settings.md` |
| sensor stream that tolerated drops | sensor-data QoS / best effort | Usually needed for LiDAR, cameras, IMU, and similar high-rate topics | `api/docs-ros-org-jazzy-concepts-about-quality-of-service-settings.md` |
| latched topic | transient local durability | This is a visible transport contract change in ROS2 terms | `api/docs-ros-org-jazzy-concepts-about-quality-of-service-settings.md` |
| one publisher, many tool subscribers | pick a QoS profile external subscribers can match | RViz and other tooling often drive the real compatibility target | `api/docs-ros-org-jazzy-how-to-guides-working-with-multiple-rmw-implementations.md` |
| `ros::TransportHints().tcpNoDelay()` expectations | executor / middleware tuning, not a direct QoS knob | Do not force a fake one-to-one mapping | `api/docs-ros-org-jazzy-concepts-about-quality-of-service-settings.md` |
| callback assumptions under ROS1 transport timing | validate with executors and callback groups | QoS and scheduling interact in ROS2 | `api/docs-ros-org-jazzy-concepts-about-executors.md` |
| default ROS1 tooling compatibility | match ROS2 tooling expectations explicitly | Some defaults differ across middleware implementations | `api/docs-ros-org-jazzy-how-to-guides-working-with-multiple-rmw-implementations.md` |

## Covered Symbols

`queue_size`, `latch`, `TransportHints`, `tcpNoDelay`, "sensor topic", "latched topic", `SensorDataQoS`, `transient_local`, `reliable`, `best_effort`

## Structural Translation Patterns

- **Ordinary control/status topic**: keep the default reliable/volatile profile unless there is a specific compatibility reason to change it.
- **High-rate sensor topic**: migrate to a sensor-data or best-effort profile and document the downstream impact.
- **Latched configuration or state topic**: map to transient-local durability so late subscribers can still receive the last value.
- **Mixed external ecosystem**: choose QoS with external subscribers in mind, not just the migrated workspace itself.

## Surface-Preserving Rules

QoS is a runtime compatibility surface in ROS2. If a QoS change affects what downstream subscribers can connect or how they receive data, declare it in `artifacts/plan-meta.json`. Plainly moving from implicit ROS1 behavior to the equivalent ROS2 default profile is not a special surface change; moving a sensor stream to best effort or a latched topic to transient-local is.

## Edge Cases

- A fully migrated internal system can sometimes tolerate broader QoS changes than mixed or external-facing systems can.
- Sensor topics often need lower-latency, drop-tolerant behavior, but that should still be called out because it changes compatibility assumptions.
- Middleware differences can expose QoS problems that never showed up in ROS1.
- Executor behavior and callback-group choices can change perceived delivery timing even when QoS is nominally unchanged.

## Banned Symbols (Verification Hooks)

`queue_size=`, `.latch`, `TransportHints`, `tcpNoDelay`, ROS1 comments that promise "latching" without a ROS2 durability mapping
