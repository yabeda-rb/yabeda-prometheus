# frozen_string_literal: true

require_relative "./metric_wrapper"

module Evil
  module Metrics
    class Prometheus::GaugeWrapper < Prometheus::MetricWrapper
      def type
        :gauge
      end

      def set(labels, value)
        unless value.is_a?(Numeric)
          raise ArgumentError, 'value must be a number'
        end

        metric.set(labels, value)
      end
    end
  end
end
