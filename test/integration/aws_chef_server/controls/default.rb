node_name = input('node_name')
org_url = input('org_url')
private_ip = input('private_ip')

expected_node_name = input('expected_node_name')
expected_org_name = input('expected_org_name')

expected_org_url = "https://#{private_ip}/organizations/#{expected_org_name}"

describe node_name do
  it { should eq expected_node_name }
end

describe org_url do
  it { should eq expected_org_url }
end
