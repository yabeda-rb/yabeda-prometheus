# frozen_string_literal: true

require "prometheus/client"
require "evil/metrics/base_adapter"

module Evil
  module Metrics
    class Prometheus::Adapter < BaseAdapter
      def registry
        @registry ||= ::Prometheus::Client.registry
      end

      def register_counter!(metric)
        validate_metric!(metric)
        registry.counter(build_name(metric), metric.comment)
      end

      def perform_counter_increment!(metric, tags, increment)
        registry.get(build_name(metric)).increment(tags, increment)
      end

      def register_gauge!(metric)
        validate_metric!(metric)
        registry.gauge(build_name(metric), metric.comment)
      end

      def perform_gauge_set!(metric, tags, increment)
        registry.get(build_name(metric)).set(tags, increment)
      end

      def register_histogram!(metric)
        validate_metric!(metric)
        buckets = metric.buckets || ::Prometheus::Client::Histogram::DEFAULT_BUCKETS
        registry.histogram(build_name(metric), metric.comment, {}, buckets)
      end

      def perform_histogram_measure!(metric, tags, value)
        registry.get(build_name(metric)).observe(tags, value)
      end

      def build_name(metric)
        [metric.group, metric.name, metric.unit].compact.join("_").to_sym
      end

      def validate_metric!(metric)
        return if metric.comment

        raise ArgumentError, "Prometheus require metrics to have comments"
      end

      Evil::Metrics.register_adapter(:prometheus, new)
    end
  end
end
