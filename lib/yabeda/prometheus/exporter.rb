# frozen_string_literal: true

require "prometheus/middleware/exporter"
require "rack"

module Yabeda
  module Prometheus
    # Rack application or middleware that provides metrics exposition endpoint
    class Exporter < ::Prometheus::Middleware::Exporter
      NOT_FOUND_HANDLER = lambda do |_env|
        [404, { "Content-Type" => "text/plain" }, ["Not Found\n"]]
      end.freeze

      class << self
        # Allows to use middleware as standalone rack application
        def call(env)
          options = env.fetch("action_dispatch.request.path_parameters", {})
          @app ||= new(NOT_FOUND_HANDLER, path: "/", **options)
          @app.call(env)
        end

        def start_metrics_server!(**rack_app_options)
          Thread.new do
            default_port = ENV.fetch("PORT", 9394)
            rack_handler.run(
              rack_app(**rack_app_options),
              Host: ENV["PROMETHEUS_EXPORTER_BIND"] || "0.0.0.0",
              Port: ENV.fetch("PROMETHEUS_EXPORTER_PORT", default_port),
              AccessLog: [],
            )
          end
        end

        def rack_app(exporter = self, logger: Logger.new(IO::NULL), use_deflater: true, **exporter_options)
          ::Rack::Builder.new do
            use ::Rack::Deflater if use_deflater
            use ::Rack::CommonLogger, logger
            use ::Rack::ShowExceptions
            use exporter, **exporter_options
            run NOT_FOUND_HANDLER
          end
        end

        def rack_handler
          if Gem.loaded_specs['rack']&.version&.>= Gem::Version.new('3.0')
            require 'rackup'
            ::Rackup::Handler::WEBrick
          else
            ::Rack::Handler::WEBrick
          end
        rescue LoadError
          warn 'Please add gems rackup and webrick to your Gemfile to expose Yabeda metrics from prometheus-mmap'
          ::Rack::Handler::WEBrick
        end
      end

      def initialize(app, options = {})
        super(app, options.merge(registry: Yabeda::Prometheus.registry))
      end

      def call(env)
        ::Yabeda.collect! if env["PATH_INFO"] == path

        if ::Yabeda.debug?
          result = nil
          ::Yabeda.prometheus_exporter.render_duration.measure({}) do
            result = super
          end
          result
        else
          super
        end
      end
    end
  end
end
