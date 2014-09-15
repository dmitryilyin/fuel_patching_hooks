require 'rexml/document'

module Pacemaker

  @raw_cib = nil
  @cib = nil
  @resources = nil
  @resources_structure = nil

  def raw_cib
    @raw_cib = `cibadmin -Q`
    if @raw_cib == '' or not @raw_cib
      raise 'Could not dump cib!'
    end
    @raw_cib
  end

  def cib
    @cib = REXML::Document.new(raw_cib)
  end

  def reset_cib
    @raw_cib = nil
    @cib = nil
    @resources = nil
    @resources_structure = nil
  end

  def resources_cib
    @resources = cib.root.elements['configuration'].elements['resources']
  end

  def resources
    return @resources_structure if @resources_structure
    @resources_structure = {}
    primitives = REXML::XPath.match resources_cib, '//primitive'
    primitives.each do |primitive|
      primitive_structure = {}
      id = primitive.attributes['id']
      next unless id
      primitive_structure.store :name, id
      primitive.attributes.each do |k, v|
        primitive_structure.store k.to_sym, v
      end
      if primitive.parent.name and primitive.parent.attributes['id']
        parent_structure = {
            :id => primitive.parent.attributes['id'],
            :type => primitive.parent.name
        }
        primitive_structure.store :name, parent_structure[:id]
        primitive_structure.store :parent, parent_structure
      end
      @resources_structure.store id, primitive_structure
    end
    @resources_structure
  end

  def get_resources_names
    resources.map do |id, value|
      value[:name]
    end
  end

  def get_resources_by_regexp(regexp)
    matched = {}
    resources.each do |id, value|
      matched.store id, value if value[:name] =~ regexp
    end
    matched
  end

  def get_resources_names_by_regexp(regexp)
    get_resources_by_regexp(regexp).map do |id, value|
      value[:name]
    end
  end

  def stop_resources_by_regexp(regexp)
    get_resources_names_by_regexp(regexp).each do |r|
      stop_resource r
    end
  end

  def start_resources_by_regexp(regexp)
    get_resources_names_by_regexp(regexp).each do |r|
      start_resource r
    end
  end

  def ban_resources_by_regexp(regexp)
    get_resources_names_by_regexp(regexp).each do |r|
      ban_resource r
    end
  end

  def unban_resources_by_regexp(regexp)
    get_resources_names_by_regexp(regexp).each do |r|
      unban_resource r
    end
  end

  def stop_resource(value)
    run "crm resource stop '#{value}'"
  end

  def start_resource(value)
    run "crm resource start '#{value}'"
  end

  def ban_resource(value)
    run "pcs resource ban '#{value}'"
  end

  def unban_resource(value)
    run "pcs resource clear '#{value}'"
  end

  def cleanup_resource(value)
    run "crm reource cleanup '#{value}'"
  end

  def manage_resource(value)
    run "crm reource manage '#{value}'"
  end

  def unmanage_resource(value)
    run "crm reource unmanage '#{value}'"
  end

  def manage_cluster
    maintenance_mode true
  end

  def unmanage_cluster
    maintenance_mode false
  end

  def maintenance_mode(value)
    value = !!value
    xml=<<-eos
<diff>
  <diff-added>
    <cib>
      <configuration>
        <crm_config>
          <cluster_property_set id="cib-bootstrap-options">
            <nvpair id="cib-bootstrap-options-maintenance-mode" name="maintenance-mode" value="#{value}"/>
          </cluster_property_set>
        </crm_config>
      </configuration>
    </cib>
  </diff-added>
</diff>
    eos
    apply_xml xml
  end

  def apply_xml(xml)
    xml.gsub! "\n", ' '
    xml.gsub! /\s+/, ' '
    run "cibadmin --patch --sync-call --xml-text '#{xml}'"
  end

end

class Test
  include Pacemaker
end