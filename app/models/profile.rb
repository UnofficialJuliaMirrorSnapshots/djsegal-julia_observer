# == Schema Information
#
# Table name: profiles
#
#  id         :integer          not null, primary key
#  nickname   :string
#  company    :string
#  blog       :string
#  location   :string
#  bio        :string
#  owner_type :string
#  owner_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  created    :datetime
#
# Indexes
#
#  index_profiles_on_owner_type_and_owner_id  (owner_type,owner_id)
#

class Profile < ApplicationRecord
  belongs_to :owner, polymorphic: true
end
