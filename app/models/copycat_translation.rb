class CopycatTranslation < ActiveRecord::Base

  unless ENV['COPYCAT_DEBUG']
    self.logger = Logger.new('/dev/null')
  end

  validates :key, :presence => true
  validates :locale, :presence => true

  def self.import_yaml(yaml)
    locales = YAML.load(yaml)

    locales.each do |locale, translations|
      while !translations.empty?
        flattened_translations = {}

        translations.each_key do |key_component|

          translation_or_nesting = translations.delete(key_component)

          if translation_or_nesting.is_a?(Hash)
            translation_or_nesting.each do |key, value|
              flattened_translations["#{key_component}.#{key}"] = value
            end
          elsif translation_or_nesting.present?
            attributes = { key: key_component, locale: locale }

            record = where(attributes).first_or_initialize(attributes)
            record.value = translation_or_nesting

            record.save
          end
        end

        translations.merge!(flattened_translations)
      end
    end
  end

  def self.export_yaml
    translations = all.inject(Hash.new { |h, k| h[k] = {} }) do |export, translation|
      key_components = translation.key.split('.')
      key_tail = key_components.pop

      key_scope = key_components.inject(export[translation.locale]) do |scope, key|
        scope[key] ||= {}
      end

      key_scope[key_tail] = translation.value

      export
    end

    translations.to_yaml
  end
end
