require "copycat/engine"

module Copycat

  def self.cache
    @cache ||= {}
  end

  def self.t(key)
    if cache[key]
      cache[key].html_safe
    else 
      copybar = CopycatTranslation.where("key = '#{key}'").limit(1).first
      if copybar
        cache[key] = copybar.value
        copybar.value.html_safe 
      else
        "Missing copy for #{key}"
      end
    end
  end

  def self.clear_cache(key=nil)
    if key
      @cache[key] = nil
    else
      @cache = nil
    end
  end

  def self.import_yaml(file)
    YAML.load(file).each do |locale, copies|
      hash_flatten(copies).each do |key, value|
        if (c = CopycatTranslation.where("key = '#{key}'").limit(1).first)  #TODO and locale
          c.value = value
          c.save!
        else
          CopycatTranslation.create!(:key => key, :value => value, :locale => locale)
        end
      end
    end
  end

  # { "foo" => { "a" => "1" , "b" => "2" } }
  # 
  # { "foo.a" => 1, "foo.b" => 2 }
  #

  def self.hash_flatten(hash)
    result = {} 
    hash.each do |key, value|
      if value.is_a? Hash 
        hash_flatten(value).each { |k,v| result["#{key}.#{k}"] = v }
      else 
        result[key] = value
      end
    end
    result
  end

  def self.export_yaml

  end

end
