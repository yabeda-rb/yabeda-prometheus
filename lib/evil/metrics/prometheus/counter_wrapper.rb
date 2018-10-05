# frozen_string_literal: true

require_relative "./metric_wrapper"

module Evil
  module Metrics
    class Prometheus::CounterWrapper < Prometheus::MetricWrapper
      def type
        :counter
      end

      def increment(labels = {}, by = 1)
        metric.increment(labels, by: by)
      end
    end
  end
end
