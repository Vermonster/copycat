require "copycat/engine"

=begin
from i18n gem, lib/i18n/backend/simple.rb

  # Looks up a translation from the translations hash. Returns nil if
  # eiher key is nil, or locale, scope or key do not exist as a key in the
  # nested translations hash. Splits keys or scopes containing dots
  # into multiple keys, i.e. <tt>currency.format</tt> is regarded the same as
  # <tt>%w(currency format)</tt>.
  def lookup(locale, key, scope = [], options = {})
    init_translations unless initialized?
    keys = I18n.normalize_keys(locale, key, scope, options[:separator])

    keys.inject(translations) do |result, _key|
      _key = _key.to_sym
      return nil unless result.is_a?(Hash) && result.has_key?(_key)
      result = result[_key]
      result = resolve(locale, _key, result, options.merge(:scope => nil)) if result.is_a?(Symbol)
      result
    end
  end

=end
module CopycatImplementation
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

module Copycat

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

  # ({"a"=>{"b"=>{"e"=>"f"}}}, ["a","b","c"], "d") ----> {"a"=>{"b"=>{"c"=>"d", "e"=>"f"}}}
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


=begin
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
      cache[key] = nil
    else
      @cache = {}
    end
  end
=end

end
