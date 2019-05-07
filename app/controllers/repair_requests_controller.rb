class RepairRequestsController < ApplicationController
  before_action :set_property

  def new
    @repair_request = Hackney::RepairRequest.new(
      contact_attributes: {},
      work_orders_attributes: [{}]
    )
    @cautionary_contacts = Hackney::CautionaryContact.find_by_property_reference(@property.reference)
    @keyfax_url = Hackney::Keyfax.get_startup_url
    @keyfax_response = Hackney::Keyfax.get_response(@keyfax_url.guid)
  end

  def create
    @repair_request = Hackney::RepairRequest.new(repair_request_params)
    @repair_request.property_reference = @property.reference
    respond_to do |format|
      if @repair_request.save
        format.html { redirect_to work_order_path(@repair_request.work_orders.first.reference), notice: 'Repair raised!' }
      else
        flash[:error] = @repair_request.errors["base"]
        format.html { render :new }
      end
    end
  end

  private

  def set_property
    @property = Hackney::Property.find(params[:property_ref])
  end

  def repair_request_params
    params.require(:hackney_repair_request).permit([
      { contact_attributes: [:name, :telephone_number] },
      { work_orders_attributes: [:sor_code] },
      :priority,
      :description
    ])
  end
end
