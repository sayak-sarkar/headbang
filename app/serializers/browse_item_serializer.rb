class BrowseItemSerializer < ActiveModel::Serializer
  attributes :name, :path

  def name
    File.basename(object)
  end

  def path
    File.expand_path(object)
  end
end
