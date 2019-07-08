class RepairRequestsController < ApplicationController
  before_action :set_property
  before_action :set_cautionary_contact
  before_action :create_and_set_keyfax_session
  before_action :set_keyfax_result

  def new
    @repair_request = new_repair_request(
      contact_attributes: {
      },
      tasks: [
        new_task(
          sor_code: @keyfax_result&.sor_code,
        )
      ],
      priority: @keyfax_result&.priority || "N",
      description: "%{alerts} %{text}" % {
        alerts: @cautionary_contact.alert_codes.join("; "),
        text: @keyfax_result&.fault_text
      }
    )
  end

  def create
    @repair_request = new_repair_request(repair_request_params)

    respond_to do |format|
      if params[:add_task]
        @repair_request.tasks << new_task
        format.html { render :new }
      else
        normalize_tasks(@repair_request)
        if @repair_request.save
          issue_dlo_work_orders
          format.html { render :created }
        else
          flash.now[:error] = @repair_request.errors["base"]
          format.html { render :new }
        end
      end
    end
  end

  private

  def issue_dlo_work_orders
    task = @repair_request.tasks.first
    if task.is_dlo?
      HackneyAPI::RepairsClient.new.post_work_order_issue(
        task.work_order_reference,
        created_by_email: current_user_email
      )
    end

  rescue HackneyAPI::RepairsClient::ApiError => e
    flash.now[:error] ||= []
    flash.now[:error] += e.errors.map {|err| err["userMessage"] }
  end

  def set_property
    @property = Hackney::Property.find(params[:property_ref])
  end

  def set_cautionary_contact
    @cautionary_contact =
      Hackney::CautionaryContact.find_by_property_reference(params[:property_ref])
  end

  def set_keyfax_result
    if params[:guid].present?
      if params[:status] == "1"
        @keyfax_result = Hackney::KeyfaxResult.find(params[:guid])
        unless @keyfax_result.sor_code != "0"
          flash.now[:error] = [@keyfax_result.problem_description]
        end
      else
        flash.now[:error] ||= []
        flash.now[:error] << t(".keyfax_session_cancelled")
      end
    end
    @keyfax_result
  end

  def create_and_set_keyfax_session
    @keyfax_session = Hackney::KeyfaxSession.create(
      current_page_url: new_property_repair_request_url(params[:property_ref])
    )
  end

  def new_repair_request(attributes = {})
    Hackney::RepairRequest.new(attributes).tap do |repair_request|
      repair_request.created_by_email = current_user_email
      repair_request.property_reference = params[:property_ref]
    end
  end

  # cleanup blank stuff and ensure at least one task is present
  def normalize_tasks(repair_request)
    repair_request.tasks.tap do |tasks|
      tasks.reject! {|task| task.sor_code.blank? }
      tasks << new_task if tasks.blank?
    end
  end

  def new_task(attributes = {})
    Hackney::Task.new(attributes).tap do |task|
      task.estimated_units ||= 1
    end
  end

  def repair_request_params
    params.require(:hackney_repair_request)
      .permit([
        {
          contact_attributes: [
            :name,
            :telephone_number
          ]
        },
        {
          tasks_attributes: [
            :sor_code,
            :estimated_units
          ]
        },
        :priority,
        :description,
        :recharge
    ])
  end
end
