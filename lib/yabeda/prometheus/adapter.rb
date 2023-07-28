# frozen_string_literal: true

require "prometheus/client"
require 'prometheus/client/data_stores/direct_file_store'
require 'prometheus/client/data_stores/single_threaded'
require "yabeda/base_adapter"

module Yabeda
  class Prometheus::Adapter < BaseAdapter
    class UndeclaredMetricTags < RuntimeError
      attr_reader :message

      def initialize(metric_name, caused_exception)
        @message = <<~MESSAGE.strip
          Prometheus requires all used tags to be declared at metric registration time. \
          Please add `tags` option to the declaration of metric `#{metric_name}`. \
          Error: #{caused_exception.message}
        MESSAGE
      end
    end

    def registry
      @registry ||= ::Prometheus::Client.registry
    end

    def register_counter!(metric)
      validate_metric!(metric)
      registry.counter(
        build_name(metric),
        docstring: metric.comment,
        labels: Array(metric.tags),
        store_settings: store_settings(metric),
      )
    end

    def perform_counter_increment!(metric, tags, value)
      registry.get(build_name(metric)).increment(by: value, labels: tags)
    rescue ::Prometheus::Client::LabelSetValidator::InvalidLabelSetError => e
      raise UndeclaredMetricTags.new(build_name(metric), e)
    end

    def register_gauge!(metric)
      validate_metric!(metric)
      registry.gauge(
        build_name(metric),
        docstring: metric.comment,
        labels: Array(metric.tags),
        store_settings: store_settings(metric),
      )
    end

    def perform_gauge_set!(metric, tags, value)
      registry.get(build_name(metric)).set(value, labels: tags)
    rescue ::Prometheus::Client::LabelSetValidator::InvalidLabelSetError => e
      raise UndeclaredMetricTags.new(build_name(metric), e)
    end

    def register_histogram!(metric)
      validate_metric!(metric)
      buckets = metric.buckets || ::Prometheus::Client::Histogram::DEFAULT_BUCKETS
      registry.histogram(
        build_name(metric),
        docstring: metric.comment,
        buckets: buckets,
        labels: Array(metric.tags),
        store_settings: store_settings(metric),
      )
    end

    def perform_histogram_measure!(metric, tags, value)
      registry.get(build_name(metric)).observe(value, labels: tags)
    rescue ::Prometheus::Client::LabelSetValidator::InvalidLabelSetError => e
      raise UndeclaredMetricTags.new(build_name(metric), e)
    end

    def register_summary!(metric)
      validate_metric!(metric)
      registry.summary(
        build_name(metric),
        docstring: metric.comment,
        labels: Array(metric.tags),
        store_settings: store_settings(metric),
      )
    end

    def perform_summary_observe!(metric, tags, value)
      registry.get(build_name(metric)).observe(value, labels: tags)
    rescue ::Prometheus::Client::LabelSetValidator::InvalidLabelSetError => e
      raise UndeclaredMetricTags.new(build_name(metric), e)
    end

    def build_name(metric)
      [metric.group, metric.name, metric.unit].compact.join('_').to_sym
    end

    def validate_metric!(metric)
      return if metric.comment

      raise ArgumentError, 'Prometheus require metrics to have comments'
    end

    def debug!
      Yabeda.configure do
        group :prometheus_exporter

        histogram :render_duration,
                  tags: %i[], unit: :seconds,
                  buckets: [0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
                  comment: "Time required to render all metrics in Prometheus format"
      end
    end

    private

    # @param metric [Yabeda::Metric]
    # @return [Hash]
    def store_settings(metric)
      case ::Prometheus::Client.config.data_store
      when ::Prometheus::Client::DataStores::Synchronized, ::Prometheus::Client::DataStores::SingleThreaded
        {} # Default synchronized store doesn't allow to pass any options
      when ::Prometheus::Client::DataStores::DirectFileStore, ::Object # Anything else
        { aggregation: metric.aggregation }.compact
      end
    end

    Yabeda.register_adapter(:prometheus, new)
  end
end
