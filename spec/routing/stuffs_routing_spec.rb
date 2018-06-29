require "rails_helper"

RSpec.describe StuffsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/stuffs").to route_to("stuffs#index")
    end

    it "routes to #new" do
      expect(:get => "/stuffs/new").to route_to("stuffs#new")
    end

    it "routes to #show" do
      expect(:get => "/stuffs/1").to route_to("stuffs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/stuffs/1/edit").to route_to("stuffs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/stuffs").to route_to("stuffs#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/stuffs/1").to route_to("stuffs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/stuffs/1").to route_to("stuffs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/stuffs/1").to route_to("stuffs#destroy", :id => "1")
    end

  end
end
