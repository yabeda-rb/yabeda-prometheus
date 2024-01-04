# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased

## 0.9.1 - 2024-01-04

### Fixed

- Compatibility with Rack 3 and Rack 2. [#27](https://github.com/yabeda-rb/yabeda-prometheus/pull/27) by [@aroop][].

## 0.9.0 - 2023-07-28

### Added

- Support for summary metric type (Yabeda 0.12+ is required). [@Envek]
- Metrics endpoint response compression with Rack Deflater. [@etsenake], ([#23](https://github.com/yabeda-rb/yabeda-prometheus/pull/23)

### Changed

- prometheus-client 3.x or 4.x is required. [@Envek]

## 0.8.0 - 2021-12-30

### Added

- Ability to specify a logger instance for exporter web server. [@palkan], [#19](https://github.com/yabeda-rb/yabeda-prometheus/pull/19)
- Ability to specify Prometheus instance value for push gateway. [@ollym], [#20](https://github.com/yabeda-rb/yabeda-prometheus/pull/20)

### Changed

- Logging is disabled by default for exporter web server. [@palkan], [#19](https://github.com/yabeda-rb/yabeda-prometheus/pull/19)

## 0.7.0 - 2021-07-21

### Added

 - Debug mode with metric `yabeda_prometheus_render_duration` to measure how long takes to render response with already collected metrics for Prometheus. Requires Yabeda 0.10+. [@Envek], [@dsalahutdinov]

### Changed

 - Yabeda 0.10.0 or newer is required. [@Envek]

## 0.6.2 - 2021-06-23

### Fixed

 - Fix `uninitialized constant Yabeda::Rack::Handler (NameError)` when using [yabeda-rack-attack](https://github.com/dsalahutdinov/yabeda-rack-attack). [@dsalahutdinov]

## 0.6.1 - 2020-04-28

### Changed

 - Fixed issue with Push Gateway require. [#13](https://github.com/yabeda-rb/yabeda-prometheus/pull/13) by [@baarkerlounger].
 - Fixed possible issue with rack absense in non-web applications. Declared it as a dependency. [@Envek]

## 0.6.0 - 2020-04-15

### Changed

 - Relaxed version constraints for prometheus-client as [v2.0.0](https://github.com/prometheus/client_ruby/releases/tag/v2.0.0) doesn't break APIs. @Envek

## 0.5.0 - 2020-01-29

### Added

 - Support for metric aggregation when prometheus-client's Direct File Store is used. @Envek

   See https://github.com/prometheus/client_ruby#aggregation-settings-for-multi-process-stores for details.

## 0.2.0 - 2020-01-14

### Changed

 - Support for new versions of the official prometheus-client gem. @Envek

   It is now required to specify not only comments, but also `tags` option for all metrics as prometheus-client now enforces this.

   Support for specifying tags for metrics was added to yabeda 0.2.

### Removed

 - Removed support for old versions of the official prometheus-client gem. @Envek

   Due to incompatible changes in official client API

 - Removed support for prometheus-client-mmap gem. @Envek

   Support for multiprocess servers is now included in official Prometheus ruby client.


## 0.1.5 - 2019-10-15

### Fixed

 - Issue [#7](https://github.com/yabeda-rb/yabeda-prometheus/issues/7) with counters and gauges when using prometheus-client-mmap gem. Fixed in [#8](https://github.com/yabeda-rb/yabeda-prometheus/pull/8) by [@alexander37137]


## 0.1.4 - 2018-11-06

### Added

 - Support for prometheus-client-mmap gem that allow to collect metrics from
   forking servers like Passenger or Puma in clustered mode. @Envek

   Now you need to manually specify which gem you need to use in your Gemfile
   due to lack of either/or dependencies in RubyGems.

   ```ruby
   gem "prometheus-client"
   gem "yabeda-prometheus"
   ```

   Or:

   ```ruby
   gem "prometheus-client-mmap"
   gem "yabeda-prometheus"
   ```

## 0.1.3 - 2018-10-31

### Added

 - Ability to mount exporter to Rails application routes as standalone Rack app. @Envek

   ```ruby
   Rails.application.routes.draw do
     mount Yabeda::Prometheus::Exporter => "/metrics"
   end
   ```

## 0.1.2 - 2018-10-17

### Changed

 - Renamed evil-metrics-prometheus gem to yabeda-prometheus. @Envek

## 0.1.1 - 2018-10-05

### Changed

 - Eliminate data duplication in counters and gauges. @Envek

   Use values stored in core gem metric objects and just let Prometheus to read them.

## 0.1.0 - 2018-10-03

 - Initial release of evil-metrics-prometheus gem. @Envek

[@Envek]: https://github.com/Envek "Andrey Novikov"
[@alexander37137]: https://github.com/alexander37137 "Alexander Andreev"
[@baarkerlounger]: https://github.com/baarkerlounger "Daniel Baark"
[@dsalahutdinov]: https://github.com/dsalahutdinov "Dmitry Salahutdinov"
[@palkan]: https://github.com/palkan "Vladimir Dementyev"
[@ollym]: https://github.com/ollym "Oliver Morgan"
[@etsenake]: https://github.com/etsenake "Josh Etsenake"
[@aroop]: https://github.com/aroop "Ajay Guthikonda"
