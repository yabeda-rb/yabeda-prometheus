# frozen_string_literal: true

require "prometheus/client/metric"

module Evil
  module Metrics
    class Prometheus::MetricWrapper < ::Prometheus::Client::Metric
      attr_reader :metric

      def initialize(metric, base_labels = {})
        @metric = metric

        @validator = ::Prometheus::Client::LabelSetValidator.new
        @base_labels = base_labels

        validate_name(self.name)
        validate_docstring(self.docstring)
        @validator.valid?(base_labels)
      end

      def name
        @name ||=
          [metric.group, metric.name, metric.unit].compact.join("_").to_sym
      end

      def docstring
        metric.comment
      end

      def get(labels = {})
        @validator.valid?(labels)

        metric.get(labels)
      end

      def values
        metric.values
      end
    end
  end
end
