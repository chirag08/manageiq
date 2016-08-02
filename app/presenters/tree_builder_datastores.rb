class TreeBuilderDatastores < TreeBuilder
  has_kids_for Hash, [:x_get_tree_hash_kids]

  def initialize(name, type, sandbox, build = true, root = nil)
    @root = root
    @data = Storage.all.inject({}) { |h, st| h[st.id] = st; h }
    super(name, type, sandbox, build)
  end

  private

  def tree_init_options(_tree_name)
    {:full_ids => false,
     :add_root => false,
     :lazy     => false}
  end

  def set_locals_for_render
    locals = super
    locals.merge!(:id_prefix                   => 'datastore_',
                  :checkboxes                  => true,
                  :onselect                    => "miqOnCheckCUFilters",
                  :check_url                   => "/ops/cu_collection_field_changed/",
                  :open_close_all_on_dbl_click => true)
  end

  def root_options
    []
  end

  def x_get_tree_roots(count_only = false, _options)
    nodes = @root.map do |node|
      children = []
      if @data[node[:id]].hosts.present?
        children = @data[node[:id]].hosts.map do |kid|
          {:name => kid.name}
        end
      end
      { :id       => node[:id].to_s,
        :text     => "<b>#{node[:name]}</b> [#{node[:location]}]".html_safe,
        :image    => 'storage',
        :tip      => "#{node[:name]} [#{node[:location]}]",
        :select   => node[:capture] == true,
        :children => children
      }
    end
    count_only_or_objects(count_only, nodes)
  end

  def x_get_tree_hash_kids(parent, count_only)
    nodes = parent[:children].map do |node|
      { :id           => node[:name],
        :text         => node[:name],
        :image        => 'host',
        :tip          => node[:name],
        :hideCheckbox => true,
        :style_class  => "cfme-no-cursor-node",
        :children     => []
      }
    end
    count_only_or_objects(count_only, nodes)
  end
end