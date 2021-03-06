# == Schema Information
#
# Table name: subscriptions
#
#  id           :integer          not null, primary key
#  feed_id      :integer
#  news_item_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_subscriptions_on_feed_id       (feed_id)
#  index_subscriptions_on_news_item_id  (news_item_id)
#

FactoryGirl.define do
  factory :subscription do
    feed nil
    news_item nil
  end
end
