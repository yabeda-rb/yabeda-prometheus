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
        @push_gateway ||=
          ::Prometheus::Client::Push.new(
            job: ENV.fetch("PROMETHEUS_JOB_NAME", "yabeda"),
            gateway: ENV.fetch("PROMETHEUS_PUSH_GATEWAY", "http://localhost:9091"),
            open_timeout: 5, read_timeout: 30,
          )
      end
    end
  end
end
