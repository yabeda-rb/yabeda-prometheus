# ![`Yabeda::Prometheus`](./yabeda-prometheus-logo.png)

[![Gem Version](https://badge.fury.io/rb/yabeda-prometheus.svg)](https://rubygems.org/gems/yabeda-prometheus)

Adapter for easy exporting your collected metrics from your application to the [Prometheus]!

<a href="https://evilmartians.com/?utm_source=yabeda-prometheus&utm_campaign=project_page">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
</a>


## One more? Why not X?

 - https://github.com/discourse/prometheus_exporter – built on assumption that various processes (web, jobs, etc) are able to communicate between them on single machine. But in containerized environments all your processes on different “machines”!
 - https://github.com/getqujing/prome – actually inspired this all these gems but seems abandoned and lacks extensibility.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yabeda-prometheus'
```

And then execute:

    $ bundle

## Usage

 1. Exporting from running web servers:

    Place following in your `config.ru` _before_ running your application:

    ```ruby
    use Yabeda::Prometheus::Exporter
    ```

    Metrics will be available on `/metrics` path (configured by `:path` option), additionally metrics can be served only on specific port with `:port` option.

    Alternatively you can mount it in Rails application routes as standalone Rack application:

    ```ruby
    Rails.application.routes.draw do
      mount Yabeda::Prometheus::Exporter, at: "/metrics"
    end
    ```

    Additional options (like `:port`) are also accepted and forwarded to [Prometheys Exporter](https://github.com/prometheus/client_ruby/blob/main/lib/prometheus/middleware/exporter.rb) middleware.

 2. Run web-server from long-running processes (delayed jobs, …):

    ```ruby
    Yabeda::Prometheus::Exporter.start_metrics_server!
    ```

    WEBrick will be launched in separate thread and will serve metrics on `/metrics` path.

    > **ATTENTION**: Starting from Ruby 3.0 WEBrick isn't included with Ruby by default. You should either add `gem "webrick"` into your Gemfile or launch `Yabeda::Prometheus::Exporter.rack_app` with application server of your choice.

    See [yabeda-sidekiq] for example.

    Listening address is configured via `PROMETHEUS_EXPORTER_BIND` env variable (default is `0.0.0.0`).

    Port is configured by `PROMETHEUS_EXPORTER_PORT` or `PORT` variables (default is `9394`).

 3. Use push gateway for short living things (rake tasks, cron jobs, …):

    ```ruby
    Yabeda::Prometheus.push_gateway.add(Yabeda::Prometheus.registry)
    ```

    Address of push gateway is configured with `PROMETHEUS_PUSH_GATEWAY` env variable.


## Multi-process server support

To use Unicorn or Puma in clustered mode, you'll want to set up underlying prometheus-client gem to use `DirectFileStore`, which aggregates metrics across the processes.

```ruby
Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(dir: '/tmp/prometheus_direct_file_store')
```

See more information at [prometheus-client README](https://github.com/prometheus/client_ruby#data-stores).

### Aggregation settings

You can specify aggregation policy in gauges declaration:

```ruby
group :some do
  gauge :tasks do
    comment "Number of test tasks"
    aggregation :max
  end
end
```

## Debugging metrics

 - Time of already collected metrics rendering in response for Prometheus: `yabeda_prometheus_render_duration`.

These are only enabled in debug mode. See [Yabeda debugging metrics](https://github.com/yabeda-rb/yabeda#debugging-metrics) on how to enable it  (e.g. by specifying `YABEDA_DEBUG=true` in your environment variables).

## Exporter logs

By default, exporter web server logs are disabled. For example, you can plug in a Rails logger:

```ruby
Yabeda::Prometheus::Exporter.start_metrics_server! logger: Rails.application.logger
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yabeda-rb/yabeda-prometheus.

### Releasing

1. Bump version number in `lib/yabeda/prometheus/version.rb`

   In case of pre-releases keep in mind [rubygems/rubygems#3086](https://github.com/rubygems/rubygems/issues/3086) and check version with command like `Gem::Version.new(Yabeda::Prometheus::VERSION).to_s`

2. Fill `CHANGELOG.md` with missing changes, add header with version and date.

3. Make a commit:

   ```sh
   git add lib/yabeda/prometheus/version.rb CHANGELOG.md
   version=$(ruby -r ./lib/yabeda/prometheus/version.rb -e "puts Gem::Version.new(Yabeda::Prometheus::VERSION)")
   git commit --message="${version}: " --edit
   ```

4. Create annotated tag:

   ```sh
   git tag v${version} --annotate --message="${version}: " --edit --sign
   ```

5. Fill version name into subject line and (optionally) some description (list of changes will be taken from changelog and appended automatically)

6. Push it:

   ```sh
   git push --follow-tags
   ```

7. GitHub Actions will create a new release, build and push gem into RubyGems! You're done!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[Prometheus]: https://prometheus.io/ "Open-source monitoring solution"
[yabeda-sidekiq]: https://github.com/yabeda-rb/yabeda-sidekiq
