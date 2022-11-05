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

        def start_metrics_server!(start_in_thread: true, **rack_app_options)
          if start_in_thread
            start_server_in_thread!(**rack_app_options)
          else
            start_server_in_process!(**rack_app_options)
          end
        end

        def start_server_in_thread!(**rack_app_options)
          Thread.new do
            start_app(**rack_app_options)
          end
        end

        def rack_app(exporter = self, logger: Logger.new(IO::NULL), use_deflater: true, **exporter_options)
        def start_server_in_process!(**rack_app_options)
          pid = Process.fork do
            # re-configure yabeda since we're in a new process
            Yabeda.configure!
            start_app(**rack_app_options)
          end
          Process.detach(pid) if pid
        end

        def rack_app(exporter = self, path: "/metrics", logger: Logger.new(IO::NULL), use_deflater: false)
          ::Rack::Builder.new do
            use ::Rack::Deflater if use_deflater
            use ::Rack::CommonLogger, logger
            use ::Rack::ShowExceptions
            use exporter, **exporter_options
            run NOT_FOUND_HANDLER
          end
        end

        def start_app(raise_start_error: true, **rack_app_options)
          default_port = ENV.fetch("PORT", 9394)
          ::Rack::Handler::WEBrick.run(
            rack_app(**rack_app_options.remove(:raise_failed_to_start)),
            Host: ENV["PROMETHEUS_EXPORTER_BIND"] || "0.0.0.0",
            Port: ENV.fetch("PROMETHEUS_EXPORTER_PORT", default_port),
            AccessLog: [],
          )
        rescue Errno::EADDRINUSE
          puts "Failed to start server might be started by another process"
          raise if raise_start_error
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
