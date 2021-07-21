# frozen_string_literal: true

require "yabeda"
require "prometheus/client"
require "prometheus/client/push"
require "yabeda/prometheus/version"
require "yabeda/prometheus/adapter"
require "yabeda/prometheus/exporter"

module Yabeda
  module Prometheus
    class << self
      def registry
        ::Prometheus::Client.registry
      end

      def push_gateway
        @push_gateway ||= begin
          ::Prometheus::Client::Push.new(
            ENV.fetch("PROMETHEUS_JOB_NAME", "yabeda"),
            nil,
            ENV.fetch("PROMETHEUS_PUSH_GATEWAY", "http://localhost:9091"),
          ).tap do |gateway|
            http = gateway.instance_variable_get(:@http)
            http.open_timeout = 5
            http.read_timeout = 5
          end
        end
      end
    end
  end
end
