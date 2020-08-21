# User.destroy_all
o = Organization.where(name: "Default Org").first_or_create!
puts "-> created default organization"

u = User.where(email: "first_member@proda.com").first_or_initialize
if u.new_record?
  u.password = "empty"
  u.organization_id = o.id
  u.save!
end
puts "-> created default user"
d = Device.where(name: "first_device", organization_id: o.id, user_id: u.id).first_or_create!
puts "-> created default device"