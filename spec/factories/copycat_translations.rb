FactoryGirl.define do
  sequence :string do |n|
    "string%09d" % n
  end
  
  factory :copycat_translation do
    key { Factory.next(:string) }
    value { Factory.next(:string) }
  end
end

