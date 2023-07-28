# frozen_string_literal: true

RSpec.describe Yabeda::Prometheus do
  it "has a version number" do
    expect(Yabeda::Prometheus::VERSION).not_to be nil
  end

  before(:each) do
    Yabeda.configure do
      group :test
      counter :counter, comment: 'Test counter', tags: [:ctag]
      gauge :gauge, comment: 'Test gauge', tags: [:gtag]
      histogram :histogram, comment: 'Test histogram', tags: [:htag], buckets: [1, 5, 10]
      summary :summary, comment: 'Test summary', tags: [:stag]
    end

    Yabeda.register_adapter(:prometheus, Yabeda::Prometheus::Adapter.new)
    Yabeda.configure!
  end

  after(:each) do
    Yabeda.metrics.keys.each(&Yabeda::Prometheus.registry.method(:unregister))
    Yabeda.reset!
  end

  context 'counters' do
    specify 'increment of yabeda counter increments prometheus counter' do
      expect {
        Yabeda.test.counter.increment({ ctag: 'ctag-value' })
      }.to change {
        Yabeda::Prometheus.registry.get('test_counter')&.get(labels: { ctag: 'ctag-value' }) || 0
      }.by 1.0
    end
  end

  context 'gauges' do
    specify 'set of yabeda gauge sets prometheus gauge' do
      expect {
        Yabeda.test.gauge.set({ gtag: 'gtag-value' }, 42)
      }.to change {
        Yabeda::Prometheus.registry.get('test_gauge')&.get(labels: { gtag: 'gtag-value' }) || 0
      }.to 42.0
    end
  end

  context 'histograms' do
    specify 'measure of yabeda histogram measures prometheus histogram' do
      expect {
        Yabeda.test.histogram.measure({ htag: 'htag-value' }, 7.5)
      }.to change {
        Yabeda::Prometheus.registry.get('test_histogram')&.get(labels: { htag: 'htag-value' }) || {}
      }.to({ "1" => 0.0, "5" => 0.0, "10" => 1.0, "+Inf" => 1.0, "sum" => 7.5 })
    end
  end

  context 'summaries' do
    specify 'observation of yabeda summary observes prometheus summary' do
      expect {
        Yabeda.test.summary.observe({ stag: 'stag-value' }, 42)
      }.to change {
        Yabeda::Prometheus.registry.get('test_summary')&.get(labels: { stag: 'stag-value' }) || {}
      }.to({ "sum" => 42.0, "count" => 1.0 })
    end
  end

  context 'rack' do
    it "should render metrics for consuming by Prometheus" do
      rack = Yabeda::Prometheus::Exporter.rack_app
      env = { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/metrics' }
      response = rack.call(env).last.join
      expect(response).not_to match(/test_counter{.+} \d+/)
      expect(response).not_to match(/test_gauge{.+} \d+/)
      expect(response).not_to match(/test_histogram{.+} \d+/)

      Yabeda.test_counter.increment({ ctag: :'ctag-value' })
      Yabeda.test_gauge.set({ gtag: :'gtag-value' }, 123)
      Yabeda.test_histogram.measure({ htag: :'htag-value' }, 7)

      response = rack.call(env).last.join
      expect(response).to match(/test_counter{.+} 1\.0/)
      expect(response).to match(/test_gauge{.+} 123\.0/)
      expect(response).to match(/test_histogram_bucket{.+,le="10"} 1\.0/)
    end
  end
end
