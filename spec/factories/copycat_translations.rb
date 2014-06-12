FactoryGirl.define do
  sequence :string do |n|
    "string%09d" % n
  end

  factory :copycat_translation do
    key { generate(:string) }
    value { generate(:string) }
    locale I18n.default_locale
  end
end

