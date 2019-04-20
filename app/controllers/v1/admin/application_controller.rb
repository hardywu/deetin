class V1::Admin::ApplicationController < V1::ApplicationController
  before_action :set_authenticate

  def set_authenticate
    raise Peatio::Auth::Error unless current_user&.role == 'admin'
  end

  def serialize(resource, options = {})
    serialize_class = "#{controller_name.classify}Serializer".constantize
    if resource.respond_to? 'each'
      options[:meta] = { total: resource.total_count,
                         page: resource.current_page,
                         size: resource.size,
                         limit: resource.limit_value }
    end
    serialize_class.new(resource, options).serialized_json
  end
end
