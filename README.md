# Yabeda::[Prometheus]

Adapter for easy exporting your collected evil metrics from your application to the [Prometheus]!

## One more? Why not X?

 - https://github.com/discourse/prometheus_exporter – built on assumption that various processes (web, jobs, etc) are able to communicate between them on single machine. But in containerized environments all your processes on different “machines”!
 - https://github.com/getqujing/prome – actually inspired this all these gems but seems abandoned and lacks extensibility.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yabeda'
# Then add monitoring system adapter, e.g.:
# gem 'yabeda-prometheus'
```

And then execute:

    $ bundle

## Usage

 1. Exporting from running web servers:

    Place following in your `config.ru` _before_ running your application:

    ```ruby
    use Yabeda::Prometheus::Exporter
    ```

    Metrics will be available on `/metrics` path.

 2. Run web-server from long-running processes (delayed jobs, …):

    ```ruby
    Yabeda::Prometheus::Exporter.start_metrics_server!
    ```

    WEBrick will be launched in separate thread and will serve metrics on `/metrics` path.

    See [yabeda-sidekiq] for example.

    Listening address is configured via `PROMETHEUS_EXPORTER_BIND` env variable (default is `0.0.0.0`).

    Port is configured by `PROMETHEUS_EXPORTER_PORT` or `PORT` variables (default is `9310`).

 3. Use push gateway for short living things (rake tasks, cron jobs, …):

    ```ruby
    Yabeda::Prometheus.push_gateway.add(Yabeda::Prometheus.registry)
    ```

    Address of push gateway is configured with `PROMETHEUS_PUSH_GATEWAY` env variable.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yabeda-rb/yabeda-prometheus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[Prometheus]: https://prometheus.io/ "Open-source monitoring solution"
[yabeda-sidekiq]: https://github.com/yabeda-rb/yabeda-sidekiq
