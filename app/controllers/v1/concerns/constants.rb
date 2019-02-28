module V1::Concerns::Constants
  extend ActiveSupport::Concern

  LOGIN_FAILED = '0101'.freeze
  NOT_ALLOWED = '0102'.freeze
  NOT_FOUND = '0201'.freeze
  INTERNAL_ERROR = '0200'.freeze
  PARAMS_INVALID = '0202'.freeze
  QUICK_PRICE = 0.1

  class InvalidParamError < StandardError
    def initialize(msg = 'invalid parameter')
      super(msg)
    end
  end
end
