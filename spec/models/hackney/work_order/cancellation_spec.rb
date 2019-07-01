require 'rails_helper'

RSpec.describe Hackney::WorkOrder::Cancellation, type: :model do
  describe "#reason" do
    context "when blank" do
      it "is invalid" do
        c = Hackney::WorkOrder::Cancellation.new(reason: "")
        expect(c.valid?).to be_falsey
        expect(c.errors.added?(:reason, :blank)).to be_truthy
      end
    end
  end

  describe "#save" do
    context "when valid" do
      it "works" do
        cancel_stub = stub_request(:post, "https://hackneyrepairs/v1/work_orders/00000666/cancel")
          .with(
            body: {
              lbhEmail: "pudding@hackney.gov.uk"
            }.to_json,
          ).to_return(status: 200, body: "{}")

        note_stub = stub_request(:post, "https://hackneyrepairs/v1/notes")
          .with(
            body: {
              objectKey: "uhorder",
              objectReference: "00000666",
              text: "Cancelled in Repairs Hub: Blah",
              lbhemail: "pudding@hackney.gov.uk"
            }.to_json
          ).to_return(status: 200, body: "{}")

        cancellation = Hackney::WorkOrder::Cancellation.new(
          work_order_reference: "00000666",
          reason: "Blah",
          created_by_email: "pudding@hackney.gov.uk"
        )

        expect(cancellation.save).to be_truthy

        expect(cancel_stub).to have_been_requested
        expect(note_stub).to have_been_requested
      end
    end

    context "when invalid" do
      it "returns false" do
        c = Hackney::WorkOrder::Cancellation.new(reason: "")
        expect(c.save).to be_falsey
      end
    end

    context "when API call fails" do
      it "parses error correctly" do
        cancel_stub = stub_request(:post, "https://hackneyrepairs/v1/work_orders/00000666/cancel")
          .with(
            body: {
              lbhEmail: "pudding@hackney.gov.uk"
            }.to_json,
        ).to_return(
          status: 500,
          body: [{
            userMessage: "user error",
            developerMessage: "dev error"
          }].to_json
        )

        cancellation = Hackney::WorkOrder::Cancellation.new(
          work_order_reference: "00000666",
          reason: "Blah",
          created_by_email: "pudding@hackney.gov.uk"
        )

        expect(cancellation.save).to be_falsey

        expect(cancel_stub).to have_been_requested

        expect(cancellation.errors.added?("base", "user error")).to be_truthy
      end
    end
  end
end
