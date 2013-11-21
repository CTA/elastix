module Elastix
  class Extension < Base
    attr_accessor :extension, :name, :sipname, :outboundcid, :devinfo_secret

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
      self.update_extension_object
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

      #TODO make it easier to add fields. Right now it's just hardcoded what is returned.
      def self.get_extension_attributes extension
        secret = Sip.where(id: extension, keyword: "secret").first.data
        user_fields = User.find_by_extension(extension)
        {extension: extension, name: user_fields.name, sipname: user_fields.sipname, outboundcid: user_fields.outboundcid, devinfo_secret: secret}
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

