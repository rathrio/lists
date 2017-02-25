FactoryGirl.define do
  factory :item do
    name FFaker::Movie.title
    user
  end

  factory :label do
    name 'Movies'
    user
  end

  factory :tag do
    name 'Action'
    user
  end

  factory :user do
    sequence(:email) { |n| "#{n}#{FFaker::Internet.email}" }
    password FFaker::Internet.password
  end
end
