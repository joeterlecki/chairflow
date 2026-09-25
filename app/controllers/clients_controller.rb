class ClientsController < ApplicationController
  before_action :load_stylists, except: :index

  def index
    @clients = Client.includes(:preferred_stylist).order(:name)
    if params[:q].present?
      query = "%#{Client.sanitize_sql_like(params[:q].strip)}%"
      @clients = @clients.where("name LIKE :q OR email LIKE :q OR phone LIKE :q", q: query)
    end
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    save_client(:new)
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    @client.assign_attributes(client_params)
    save_client(:edit)
  end

  private

  def load_stylists
    @stylists = Stylist.order(:name)
  end

  def client_params
    params.expect(client: [ :name, :email, :phone, :preferred_stylist_id ])
  end

  def save_client(view)
    if @client.save
      redirect_to clients_path, notice: "Client saved.", status: :see_other
    else
      render view, status: :unprocessable_entity
    end
  end
end
