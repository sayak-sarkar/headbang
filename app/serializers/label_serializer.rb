class LabelSerializer < ActiveModel::Serializer
  attributes :id, :name, :releases_count
end
