FactoryGirl.define do
  factory :item do
    name FFaker::Movie.title
  end

  factory :user do
    email FFaker::Internet.email
    password FFaker::Internet.password
  end
end
