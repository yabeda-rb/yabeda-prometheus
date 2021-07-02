Yabeda::Prometheus.debug_mode!

Yabeda.configure do
      LONG_RUNNING_REQUEST_BUCKETS = [
      0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10, # standard
      30, 60, 120, 300, 600, # Sometimes requests may be really long-running
    ].freeze
  group :prometheus_exporter

  histogram :collect_duration, tags: %i[location],
                                     buckets: LONG_RUNNING_REQUEST_BUCKETS,
                                     comment: "A histogram of the response latency."
  histogram :render_duration, tags: %i[],
                                     buckets: LONG_RUNNING_REQUEST_BUCKETS,
                                     comment: "A histogram of the response latency."
 
end
