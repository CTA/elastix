module Elastix
  class Extension < Base
    attr_accessor :extension, :name, :sipname, :outboundcid, :devinfo_secret

    def initialize(params)
      params.each_pair{|key,value| instance_variable_set "@#{key}", value}
    end
    
    def destroy
      @@elastix.get("#{@@base_address}/config.php?type=setup&amp;display=extensions&amp;extdisplay=#{self.extension}&amp;action=del")
      Base.reload
    end
    
    def save
      raise "Extension already exists" if Extension.exist? self.extension
      Extension.new_extension_object(self.to_hash)
      Base.reload
    end
    
    def self.create(params)
      e = Extension.new(params)
      e.save
      e
    end

    def self.all
      #TODO abstract this method
      page = @@elastix.get("#{@@base_address}/index.php?menu=pbxconfig")
      extensions = []
      page.links.each do |link|
        extensions << Extension.find(get_extension_from_link_text(link.text)) if href_is_acceptable? link.href
      end
      extensions
    end

    def update_attributes(params)
      params[:extension] = self.extension
      Extension.update_extension_object(params)
      Base.reload
    end

    def self.find(extension)
     get_extension_object(extension) if exist?(extension)
    end

    def ==(extension)
      self.to_hash == extension.to_hash
    end
    
    def to_hash
      Hash[self.instance_variables.map{|var| [var.to_s.delete("@"), self.instance_variable_get(var)]}]
      #my_hash.symbolize_keys
    end
    
    private
      def self.get_extension_object(extension)
        Extension.new(get_extension_attributes(get_extension_display_page(extension).forms.first))
      end
      
      def self.update_extension_object(params)
        page = get_extension_display_page(params[:extension])
        update_and_submit_form(page, params)
      end

      def self.new_extension_object(params)
        page = get_extension_display_page(params[:extension])
        #This is necessary for new objects. It would be nice to figure out why.
        page.encoding = "utf-8"
        form = page.form("frm_extensions")
        page = form.submit(form.button_with("Submit"))
        update_and_submit_form(page, params)
      end

      def self.update_and_submit_form(page, params)
        form = page.form("frm_extensions")
        form.encoding = "utf-8"
        params.each{|key,value| form[key.to_s] = value unless value.nil?}
        @@elastix.submit(form, form.button_with("Submit"))
      end

      def self.get_extension_display_page(extension)
        @@elastix.get "#{@@base_address}/config.php?type=setup&display=extensions&extdisplay=#{extension}"
      end

      def self.get_extension_attributes(form)
        Hash[form.fields.map{|field| [field.name, field.value] if is_a_class_attribute(field.name) and not field.value.empty?}]
      end

      def self.is_a_class_attribute attr
        Extension.instance_methods.grep(/\w=$/).include? "#{attr}=".to_sym
      end

      def self.exist? extension
        if @@elastix.get("#{@@base_address}/index.php?menu=pbxconfig")
          .body.match(/#{extension}/) then true else false end
      end

      def self.href_is_acceptable?(href)
        href.include? "config.php?type=setup&display=extensions&extdisplay=" unless href.nil?
      end

      def self.get_extension_from_link_text(link_text)
        link_text.scan(/<(.*)>/).first.first
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

