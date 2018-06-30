


puts 'start patching'

op = Operation.all 
op.each do |o|
  
  if o.command.index('create_record')
    puts o.service.package
    command = o.command.gsub(/create_record/,'record_create')
    o.update_attributes :command=>command
    
  elsif o.command.index('update_record')
    puts o.service.package
    command = o.command.gsub(/update_record/,'record_update')
    o.update_attributes :command=>command
  end
  
  
end