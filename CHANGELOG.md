# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


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
