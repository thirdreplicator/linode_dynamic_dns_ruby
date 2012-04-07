require 'linode'
require 'open-uri'

### Config
api_key = 'Your Linode API Key goes here'

# To find out the DomainId and ResourceId, use the print_* functions below.
dns_entries =
  [{:DomainId => '123456', :ResourceId => '7654321'},
   {:DomainId => '123456', :ResourceId => '7654322'}]
###


def print_domains(linode)
  linode.domain.list.each do |domain|
    puts "DomainId: #{domain.domainid}\t#{domain.domain}"
  end
end

def print_dns_entries(linode, domain_id)
  linode.domain.resource.list(:DomainId => domain_id.to_s).each do |resource|
    puts "DomainId: #{resource.domainid} ResourceId: #{resource.resourceid} Type: #{resource.type}\tName: #{resource.name.length > 0 ? resource.name : "   "}\tTarget: #{resource.target}"
  end
end

def get_my_ip
  open('http://ifconfig.me', 'User-Agent:' => 'curl').read.chomp
end

def update_dns(linode, domain_id, resource_id, new_ip)
  linode.domain.resource.update(:DomainId => domain_id.to_s, :ResourceId => resource_id.to_s, :Target => new_ip)
end

linode = Linode.new(:api_key => api_key)
# print_domains(linode)
# print_dns_entries(linode, 1234567)
new_ip = get_my_ip
puts "Current ip address: #{new_ip}"

dns_entries.each do |entry|
  puts "Checking #{entry[:DomainId]} #{entry[:ResourceId]}."
  old_entry = linode.domain.resource.list(entry).first
  if new_ip != old_entry.target
    puts "Updating...#{old_entry.resourceid} to #{new_ip}"
    update_dns(linode, entry[:DomainId], entry[:ResourceId], new_ip)
  end
  current_entry = linode.domain.resource.list(entry).first
end

puts "Done."
