class CopycatTranslation < ActiveRecord::Base

  validates :key, :presence => true

  module Serialize
   
    def import_yaml(yaml)
      hash = YAML.load(yaml)
      hash.each do |locale, data|
        next unless locale == "en" # not handling non-english languages yet.
        hash_flatten(data).each do |key, value|
          c = find_or_initialize_by_key(key)
          c.value = value
          c.save
        end
      end
    end

    def export_yaml
      yaml_hash = {}
      all.each do |c|
        yaml_hash = hash_fatten(yaml_hash, c.key.split("."), c.value)
      end
      {"en" => yaml_hash}.to_yaml
    end
    
    # {"foo"=>{"a"=>"1", "b"=>"2"}} ----> {"foo.a"=>1, "foo.b"=>2}
    def hash_flatten(hash)
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

    # ({"a"=>{"b"=>{"e"=>"f"}}}, ["a","b","c"], "d") ----> {"a"=>{"b"=>{"c"=>"d", "e"=>"f"}}}
    def hash_fatten(hash, keys, value)
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

  extend Serialize

end
