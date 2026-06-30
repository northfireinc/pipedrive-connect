# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pipedrive do
  describe "timeout defaults" do
    it "defaults open_timeout to 5 seconds" do
      expect(described_class.open_timeout).to eq(5)
    end

    it "defaults timeout to 10 seconds" do
      expect(described_class.timeout).to eq(10)
    end

    it "allows open_timeout to be overridden" do
      original = described_class.open_timeout
      described_class.open_timeout = 3
      expect(described_class.open_timeout).to eq(3)
    ensure
      described_class.open_timeout = original
    end

    it "allows timeout to be overridden" do
      original = described_class.timeout
      described_class.timeout = 30
      expect(described_class.timeout).to eq(30)
    ensure
      described_class.timeout = original
    end
  end

  describe "api_version" do
    after { described_class.use_v2_api! }

    it "defaults to v2" do
      expect(described_class.api_version).to eq(:v2)
    end

    it "switches to v1 with use_v1_api!" do
      described_class.use_v1_api!
      expect(described_class.api_version).to eq(:v1)
    end

    it "switches back to v2 with use_v2_api!" do
      described_class.use_v1_api!
      described_class.use_v2_api!
      expect(described_class.api_version).to eq(:v2)
    end
  end
end
