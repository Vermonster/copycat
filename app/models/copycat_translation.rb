class CopycatTranslation < ActiveRecord::Base

  validates :key, :value, :presence => true
  validates :key, :uniqueness => true
  
  def self.import_yaml(yaml)
    Copycat.hash_flatten(yaml).each do |key, value|
      if (c = where("key = ?", key).limit(1).first)
        c.value = value
        c.save!
        Copycat.clear_cache(c.key)
      else
        create!(:key => key, :value => value)
      end
    end
  end

  def self.export_yaml
    yaml_hash = {}
    all.each do |c|
      yaml_hash = Copycat.hash_fatten(yaml_hash, c.key.split("."), c.value)
    end
    yaml_hash.to_yaml
  end

end
