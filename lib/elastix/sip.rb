require 'active_record'

module Elastix
  class Sip < ActiveRecord::Base
    self.table_name = "sip"
  end
end
