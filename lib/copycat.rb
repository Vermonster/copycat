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
      copybar = CopycatTranslation.create!(:key => key, :value => "Missing copy for #{key}") unless copybar
      cache[key] = copybar.value
      copybar.value.html_safe 
    end
  end

  def self.clear_cache(key=nil)
    if key
      @cache[key] = nil
    else
      @cache = nil
    end
  end

  # {"foo"=>{"a"=>"1", "b"=>"2"}} ----> {"foo.a"=>1, "foo.b"=>2}
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

  def self.hash_fatten(hash, keys, value)
    if keys.length == 1
      raise "duplicate key" if hash[keys.first]
      hash[keys.first] = value
    else
      head = keys.first
      rest = keys[1..-1]
      hash[head] = hash_fatten(hash[head] || {}, rest, value)
    end
    hash
  end

end
