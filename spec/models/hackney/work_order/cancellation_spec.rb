require 'rails_helper'

RSpec.describe Hackney::WorkOrder::Cancellation, type: :model do
  describe "#save" do
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

      cancellation.save

      expect(cancel_stub).to have_been_requested
      expect(note_stub).to have_been_requested
    end
  end
end
