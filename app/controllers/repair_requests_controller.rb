class RepairRequestsController < ApplicationController
  before_action :set_property

  def new

    if keyfax_session_started?
      if should_get_keyfax_result?
        @keyfax_result = Hackney::KeyfaxResult.find(params["guid"])
        unless sor_code_valid?
          flash.now[:error] = [@keyfax_result.problem_description]
        end
      else
        flash.now[:error] = ["Keyfax session cancelled"]
      end
    end

    @repair_request = Hackney::RepairRequest.new(
      contact_attributes: {},
      work_orders_attributes: [{
        sor_code: @keyfax_result&.sor_code,
        }],
      priority: @keyfax_result&.priority
    )

    @cautionary_contacts = Hackney::CautionaryContact.find_by_property_reference(@property.reference)
    @keyfax_session = Hackney::KeyfaxSession.get_startup_url(new_property_repair_request_url(@property.reference))
  end

  def create
    @repair_request = Hackney::RepairRequest.new(repair_request_params)
    @repair_request.property_reference = @property.reference
    respond_to do |format|
      if @repair_request.save
        format.html { redirect_to work_order_path(@repair_request.work_orders.first.reference), notice: ['Repair raised!'] }
      else
        @cautionary_contacts = Hackney::CautionaryContact.find_by_property_reference(@property.reference)
        @keyfax_session = Hackney::KeyfaxSession.get_startup_url(new_property_repair_request_url(@property.reference))
        flash.now[:error] = @repair_request.errors["base"]
        format.html { render :new }
      end
    end
  end

  private

  def keyfax_session_started?
    params["guid"].present?
  end

  def should_get_keyfax_result?
     params["status"] == "1"
  end

  def sor_code_valid?
    @keyfax_result.sor_code != 0
  end

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
