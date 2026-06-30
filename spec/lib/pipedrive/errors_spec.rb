# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pipedrive::PipedriveError do
  describe "#initialize" do
    context "message and code are optional" do
      it "creates an instance" do
        expect(subject.code).to be_nil
        expect(subject.message).to be_empty
      end
    end
  end

  describe "#message" do
    context "with code" do
      subject { described_class.new("Whatever error", 500) }

      it "includes code and message" do
        expect(subject.message).to eq("(Status 500) Whatever error")
      end
    end

    context "without code" do
      subject { described_class.new("Whatever error") }

      it "includes only the message" do
        expect(subject.message).to eq("Whatever error")
      end
    end

    context "with http_method and http_path" do
      subject { described_class.new("Not Found", 404, nil, http_method: :get, http_path: "deals/99") }

      it "includes request context in the message" do
        expect(subject.message).to eq("(Status 404) Not Found [GET deals/99]")
      end

      it "exposes http_method and http_path as attributes" do
        expect(subject.http_method).to eq(:get)
        expect(subject.http_path).to eq("deals/99")
      end
    end

    context "message never leaks api_token" do
      it "does not include the api_token value even if passed in message text" do
        err = described_class.new("error", 401, nil, http_method: :get, http_path: "deals")
        expect(err.message).not_to match(/api_token/i)
        expect(err.message).not_to match(/Authorization/i)
      end
    end
  end
end
