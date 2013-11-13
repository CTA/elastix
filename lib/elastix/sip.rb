require 'active_record'

module Elastix
  class Sip < ActiveRecord::Base
    self.table_name = "sip"

    def self.use_existing_db_connection connection
      establish_connection connection
    end
  end
end
