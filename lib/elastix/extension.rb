module Elastix
  class Extension < Base
    attr_accessor :extension, :name, :sipname, :outboundcid, :devinfo_secret, :record_in, :record_out

    def initialize params
      params.each_pair{|key,value| instance_variable_set "@#{key}", value}
    end
    
    def destroy
      @@elastix.get("#{@@base_address}/config.php?type=setup&amp;display=extensions&amp;extdisplay=#{self.extension}&amp;action=del")
      Base.reload
    end
    
    def save
      if Extension.exist? extension
        update_extension_object
      else
        new_extension_object
      end
      Base.reload
    end
    
    def update_attributes params
      params.each_pair{|key,value| instance_variable_set "@#{key}", value}
      update_extension_object
      Base.reload
    end

    def == extension
      self.to_hash == extension.to_hash
    end
    
    def to_hash
      Hash[self.instance_variables.map{|var| [var.to_s.delete("@"), self.instance_variable_get(var)]}]
    end
    

    def self.find extension
     get_extension_object(extension) if exist?(extension)
    end

    def self.create params
      e = Extension.new(params)
      e.save
      e
    end

    def self.all
      Sip.uniq.pluck(:id).map do |extension|
        get_extension_object(extension) if exist?(extension)
      end
    end

    private
      def update_extension_object
        page = Extension.get_extension_display_page(self.extension)
        update_and_submit_form(page, self.to_hash)
      end

      def new_extension_object
        #This is necessary for new objects. It would be nice to figure out why.
        page = @@elastix.get("#{@@base_address}/index.php?menu=pbxconfig")
        page.encoding = "utf-8"
        form = page.form("frm_extensions")
        page = form.submit(form.button_with("Submit"))
        update_and_submit_form(page, self.to_hash)
      end

      def update_and_submit_form(page, params)
        form = page.form("frm_extensions")
        form.encoding = "utf-8"
        params.each{|key,value| form[key.to_s] = value unless value.nil?}
        @@elastix.submit(form, form.button_with("Submit"))
      end

      def self.get_extension_object(extension)
        Extension.new(get_extension_attributes(extension))
      end

      def self.get_extension_display_page(extension)
        @@elastix.get "#{@@base_address}/config.php?type=setup&display=extensions&extdisplay=#{extension}"
      end

      #TODO make it easier to add fields. Right now it's just hardcoded what is returned
      # also it looks terrible.
      def self.get_extension_attributes extension
        secret_record = Sip.where(id: extension, keyword: "secret").first
        record_in_record = Sip.where(id: extension, keyword: "record_in").first
        record_out_record = Sip.where(id: extension, keyword: "record_out").first
        secret = secret_record ? secret_record.data : nil
        record_in = record_in_record ? record_in_record.data : nil
        record_out = record_out_record ? record_out_record.data : nil

        user_fields = User.find_by_extension(extension)
        {
          extension: extension, 
          name: (user_fields.name if user_fields), 
          sipname: (user_fields.sipname if user_fields), 
          outboundcid: (user_fields.outboundcid if user_fields), 
          devinfo_secret: secret,
          record_in: record_in,
          record_out: record_out
        }
      end

      def self.exist? extension
        !!Sip.find_by_id(extension)
      end
  end
end

class Hash
  #TODO figure out why symbols break the code. For now everything has to be in strings.
  def symbolize_keys
    self.keys.each do |key|
      self[(key.to_sym rescue key) || key] = self.delete(key)
    end
    self
  end
end

