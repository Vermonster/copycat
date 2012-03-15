class CopycatTranslation < ActiveRecord::Base

  validates :key, :value, :presence => true
  validates :key, :uniqueness => true
  
  def self.import_yaml(yaml)
    hash = YAML.load(yaml)
    hash.each do |locale, data|
      next unless locale == "en" # not handling non-english languages yet.
      Copycat.hash_flatten(data).each do |key, value|
        c = find_or_initialize_by_key(key)
        c.value = value
        c.save
        #Copycat.clear_cache
      end
    end
  end

  def self.export_yaml
    yaml_hash = {}
    all.each do |c|
      yaml_hash = Copycat.hash_fatten(yaml_hash, c.key.split("."), c.value)
    end
    {"en" => yaml_hash}.to_yaml
  end

end
