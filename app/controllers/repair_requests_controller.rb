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

    @cautionary_contact = Hackney::CautionaryContact.find_by_property_reference(@property.reference)
    @keyfax_session = Hackney::KeyfaxSession.create(current_page_url: new_property_repair_request_url(@property.reference))
    cautionary_contact_alert_codes = @cautionary_contact.alert_codes.join("; ")

    @repair_request = Hackney::RepairRequest.new(
      contact_attributes: {},
      work_orders_attributes: [{
        sor_code: @keyfax_result&.sor_code,
        }],
      priority: @keyfax_result&.priority,
      description: "#{cautionary_contact_alert_codes} #{@keyfax_result&.fault_text}"
    )
  end

  def create
    @repair_request = Hackney::RepairRequest.new(repair_request_params)
    @repair_request.property_reference = @property.reference
    @repair_request.created_by_email = current_user_email

    respond_to do |format|
      if params[:add_work_order]
        @cautionary_contact = Hackney::CautionaryContact.find_by_property_reference(@property.reference)
        @keyfax_session = Hackney::KeyfaxSession.create(current_page_url: new_property_repair_request_url(@property.reference))
        @repair_request.work_orders << Hackney::WorkOrder.new
        format.html { render :new }
      else
        # cleanup blank stuff
        @repair_request.work_orders.tap do |x|
          x.reject! {|y| y.sor_code.blank? }
          x << Hackney::WorkOrder.new if x.blank?
        end

        if @repair_request.save
          issue_dlo_work_orders
          format.html { render :created }
        else
          @cautionary_contact = Hackney::CautionaryContact.find_by_property_reference(@property.reference)
          @keyfax_session = Hackney::KeyfaxSession.create(current_page_url: new_property_repair_request_url(@property.reference))
          flash.now[:error] = @repair_request.errors["base"]
          format.html { render :new }
        end
      end
    end
  end

  private

  # FIXME: work_orders and tasks are mixed up
  def issue_dlo_work_orders
    n_errors = 0
    @repair_request.work_orders.each do |work_order|
      if work_order.is_dlo?
        begin
          HackneyAPI::RepairsClient.new.post_work_order_issue(
            work_order.reference,
            created_by_email: current_user_email
          )
        rescue HackneyAPI::RepairsClient::ApiError => e
          n_errors += 1
        end
      end
      # FIXME: quick dirty fix. Must split work_orders and tasks anyway.
      break
    end

    if 0 < n_errors
      flash.now[:error] ||= []
      flash.now[:error] << "There was an error issuing the work order and it
      may not appear in DRS. This can still be done through UH. If the problem
      persists, please contact the development team."
    end
  end

  def keyfax_session_started?
    params["guid"].present?
  end

  def should_get_keyfax_result?
     params["status"] == "1"
  end

  def sor_code_valid?
    @keyfax_result.sor_code != "0"
  end

  def set_property
    @property = Hackney::Property.find(params[:property_ref])
  end

  def repair_request_params
    params.require(:hackney_repair_request).permit([
      { contact_attributes: [:name, :telephone_number] },
      { work_orders_attributes: [:sor_code, :quantity] },
      :priority,
      :description
    ])
  end
end
