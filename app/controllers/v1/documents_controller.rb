class V1::DocumentsController < V1::ApplicationController
  before_action :set_document, only: [:show, :update, :destroy]

  # GET /documents
  def index
    @documents = Document.all

    render json: @documents
  end

  # GET /documents/1
  def show
    render json: @document
  end

  # POST /documents
  def create
    @document = Document.new(document_params)

    if @document.save
      render json: @document, status: :created, location: @document
    else
      render json: @document.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /documents/1
  def update
    if @document.update(document_params)
      render json: @document
    else
      render json: @document.errors, status: :unprocessable_entity
    end
  end

  # DELETE /documents/1
  def destroy
    @document.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def document_params
      params.fetch(:document, {})
    end
end
