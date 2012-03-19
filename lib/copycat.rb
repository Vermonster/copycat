require "copycat/engine"

module CopycatImplementation
  # this method overrides part of the i18n gem, lib/i18n/backend/simple.rb
  def lookup(locale, key, scope = [], options = {})
    begin
      cct = CopycatTranslation.find_by_key(key)
    rescue ActiveRecord::StatementInvalid
      raise if CopycatTranslation.table_exists?  
      #assert Rails is initializing for the purpose of running the copycat_translations migration
      super 
    else
      return cct.value if cct
      value = super(locale, key, scope, options)
      if value.is_a?(String) || value.nil?
        CopycatTranslation.create(key: key, value: value)
      end
      value
    end
  end
end

class I18n::Backend::Simple
  include CopycatImplementation
end
