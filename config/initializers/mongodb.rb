# # Set up database name, appending the environment name 
# # (e.g., palette-development, palette-production)
# MongoMapper.config = {
#     Rails.env => { 'uri' => ENV['MONGOHQ_URL'] ||
#         'mongodb://localhost/xxxxxxxx' } }
# MongoMapper.connect(Rails.env)
# name = "palette-#{Rails.env}"
# if ENV['MONGOHQ_URL']
#   uri = URI.parse(ENV['MONGOHQ_URL'])
#   name = uri.path.gsub(/^\//, '')
#   puts "Env = #{ENV['MONGOHQ_URL']}; DB NAME: #{name}"
# end
# MongoMapper.database = "#{name}"


# module Mongo
#   
#   class Connection
#   
#   def self.db
#     self.database
#   end
#   
#   end
# 
# end
puts 'definde mongo'
 Mongo::Collection.class_exec{
   
   
   def db
     database
   end
   
   def group query
    []
   end
   

  
   
 }
 
 # call all {#<Origin::Key:0x007fc52ba28f58 @name=:date, @strategy=:__override__, @operator="$gte", @expanded=nil, @block=nil>=>Wed, 27 Jun 2018 00:00:00 +07 +07:00, #<Origin::Key:0x007fc52ba28b70 @name=:date, @strategy=:__override__, @operator="$lt", @expanded=nil, @block=nil>=>Wed, 27 Jun 2018 23:59:59 +07 +07:00}
 # MONGODB | localhost:27017 | esm-cusys.find | STARTED | {"find"=>"colorectal.appointment", "filter"=>{"date"=>{"$gte"=>Wed, 27 Jun 2018 00:00:00 +07 +07:00, "$lt"=>Wed, 27 Jun 2018 00:00:00 +07 +07:00}}}
 #  db.colorectal.appointment.find({date:{"$gte":ISODate("2018-06-27T00:00:00Z"), "$lte":ISODate("2018-06-27T23:54:00Z")}})
 Mongoid::Criteria.class_exec{
   
   def where(expression)
     puts expression.inspect 
     combine=nil
     
     if expression
     expression.each_pair do |k,v|
       if k!='$or' and k!='$in' and v.kind_of?(Array)
          expression[k] = {'$in'=>v}
       end
      
       if k.class==Origin::Key
         puts "date key #{k.inspect}"
         combine={} unless combine
         combine[k.name]={} unless combine[k.name]
         v+=1 if k.operator=='$lt'
         combine[k.name][k.operator] = v #Time.at(v.to_i)#"ISODate('#{v.("%Y-%m-%dT%H:%M:00.000Z")}')" 
         expression.delete k  
         
       end
       if v==''
         expression.delete k
       end
     
     end
     
     expression.merge! combine if combine
     
      end
      puts 'expression'
      puts expression.inspect 
     super 
   end
   
    def all options=nil
      puts "call all #{options.inspect}"
      orders = []
      limits = nil
      
      # result = super
      unless options
        result = super
      else
    
      if options 
        
        if  options[:order]
        
        order_by = options[:order].split(",").collect{|i| 
          j =i.split " "
          mode = :asc
          mode = :desc if j[1]=='desc'
          options.delete :order
          [j[0],mode]
        }
        
        end
        
        if  options[:limit]
        
        limits = options[:limit]
        options.delete :limit
        
        end
      
      
      end
      
      result = where(options)
      
      if orders.size>0
        result = result.order_by orders
      end
      
      if limits
        # result = result.limit limits
      end
      
      
      end 
    
      res =  result.to_a
      
      res
      
          # puts 'call all'
          #      order = nil
          # 
          # 
          #      result = super({})
          #      if options and options[:order]
          # 
          #        result = result.order_by options[:order].split(",").collect{|i| 
          #          j =i.split " "
          #          mode = :asc
          #          mode = :desc if j[1]=='desc'
          #          [j[0],mode]
          # 
          #        }
          # 
          #      end
          # 
          #      result
      
    end
    
   
 }
   Mongoid::Findable.class_exec{
     def find *arg
      puts 'call finding '+arg.inspect
      if arg and arg[0]!=nil and arg[0]!=""
        
        if arg[0].kind_of?(Array) and arg[0][0] and arg[0][0] =='[]'
                arg[0][0] = []
        end
        
        if arg.size>1 and arg[1].kind_of? Hash
              scope = only(arg[1].keys)
              arg.delete_at 1
              arg.compact!
              scope.with_default_scope.find(*arg)
        else
              with_default_scope.find(*arg)
        end
      else
        return nil
      end
     end
     
      def last options=nil
         # puts 'call last'
         if options
              result = where(options)
            end
         with_default_scope.last
       end
       
           def first options=nil
              puts 'call first'
              where(options).find_first
            end
   }
 
 
   Mongo::Database.class_exec{


     def stats
       {'storageSize'=>0}
     end


   }
   
   String.class_exec{
     def to_mongo
       if t=split("/").size==3
          Date.parse(self).to_s
          
       end
     end
   }
   
   module Extensions
    module Date
     def to_mongo date
        DateTime.parse(date)
     end
    end
    
    module Regexp
      def __evolve_date__
         ""
      end
    end
   end
  class Date
    extend Extensions::Date
  end
  class Regexp
    extend Extensions::Regexp
  end   
  
  
  