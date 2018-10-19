# frozen_string_literal: true

require "prometheus/middleware/exporter"

module Yabeda
  module Prometheus
    class Exporter < ::Prometheus::Middleware::Exporter
      class << self
        def start_metrics_server!
          Thread.new do
            default_port = ENV.fetch("PORT", 9394)
            Rack::Handler::WEBrick.run(
              rack_app,
              Host: ENV["PROMETHEUS_EXPORTER_BIND"] || "0.0.0.0",
              Port: ENV.fetch("PROMETHEUS_EXPORTER_PORT", default_port),
              AccessLog: [],
            )
          end
        end

        protected

        def rack_app(exporter = self)
          Rack::Builder.new do
            use Rack::CommonLogger
            use Rack::ShowExceptions
            use exporter, registry: Yabeda::Prometheus.registry
            run ->(_env) do
              [404, { "Content-Type" => "text/plain" }, ["Not Found\n"]]
            end
          end
        end
      end

      def call(env)
        if env["REQUEST_PATH"].start_with?(path)
          Yabeda.collectors.each(&:call)
        end
        super
      end
    end
  end
end
