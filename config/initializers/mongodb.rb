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
Mongoid.raise_not_found_error = false
Mongoid::Config.belongs_to_required_by_default = false

# module Moped
#   module BSON
#     class ObjectId
#
#
#       def to_s
#         return
#       end
#
#       alias :to_json :to_s
#       alias :as_json :to_s
#
#
#
#     end
#   end
# end


Mongoid::Criteria::Queryable::Extensions::String.class_exec{

  def __sort_option__
    split(/,/).inject({}) do |hash, spec|

      
      # spec = spec.to_sym.asc if spec
      
      hash.tap do |_hash|
        field, direction = spec.strip.split(/\s/)
        
        # puts 'sort option edited '+field.inspect+'::'+direction.inspect
        
        
        if direction
        _hash[field.to_sym] = direction.to_direction
      elsif f = field.split(".") and f.size==2
            
          _hash[f[0].to_sym] = f[1]=='desc'?-1:1
           
        
        else
          
        _hash[field.to_sym] = 1 
      end
      end
    end
  end
  


}



Mongoid::Contextual::Mongo.class_exec{
  
  def all
    self.to_a
  end
  
  
}

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
# puts 'definde mongo'
 Mongo::Collection.class_exec{
   
   
   def db
     database
   end
   
   def group query
    []
   end
   
   def self.size
     
     self.count
     
   end
  
   
 }
 
 
 
 Mongoid::Criteria.class_exec{
   
   def where(expression)
     # puts expression.inspect 
     combine=nil
     
     if expression
     expression.each_pair do |k,v|
       if k!='$or' and k!='$in' and v.kind_of?(Array)
          expression[k] = {'$in'=>v}
       end
       
       # date key
       
       # puts "xx"+k.class.inspect 
       
       
       if false and k.class==Origin::Key
         # puts "date key #{k.inspect}"
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
      # puts 'expression'
      # puts expression.inspect
     super 
   end
   
    def all options={}
      # puts "call all #{options.inspect}"
      orders = []
      limits = nil
      
      # result = super
      unless options
        result = super
      else
    
      if options 
        
        
        if  options[:sort]
        
        order_by = options[:sort].collect{|i| 
          j = i.to_s.split(".")
          mode = :asc
          mode = :desc if j[1]=='desc'
         
          [j[0],mode]
        }
        options.delete :sort
        
        end
        
        if  options[:order]
        
        order_by = options[:order].split(",").collect{|i| 
          j =i.split " "
          mode = :asc
          mode = :desc if j[1]=='desc'
       
          [j[0],mode]
        }
        options.delete :order
        end
        
        if  options[:limit]
        
        limits = options[:limit]
        options.delete :limit
        
        end
      
      
      end
      
      
      
      
      
      
      
      
      if options[:date.lt]
        options[:date.lte] = options[:date.lt]
        options.delete :date.lt
      end
       
 kmap = {}

 
 options.each_pair do |k,v|
   

   
   if k.class==Mongoid::Criteria::Queryable::Key and  k.operator=='$lte'
     
     options[:date.lte] = v.to_datetime

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
      # puts 'call finding '+arg.inspect
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
     
      def last options={}
         # puts '#####call last'
         if options
              result = where(options)
            end
         with_default_scope.last
       end
       
           def first options={}
              # puts 'call first'
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
   
   Date.class_exec{
     def to_mongo
      self
       # if t=split("/").size==3
       #    Date.parse(self).to_s
       # end
     end
   }
   
   
   # Mongoid::Document.class_exec{
   #
   #
   #   def as_json(options={})
   #       attrs = super(options)
   #       attrs["id"] = attrs["_id"].to_s
   #       attrs
   #  end
   #
   #
   # }
   Mongoid::Document.public_instance_method(:as_json).source_location

   module Mongoid
    module Document
      def as_json(options={})
        attrs = super(options)
        attrs["_id"] = self.id.to_s
        attrs["id"] = self.id.to_s

        attrs
      end
    end
   end

   
   
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
  
  
  