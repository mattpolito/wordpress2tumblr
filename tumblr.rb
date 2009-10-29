require 'httparty'
require 'yaml'

class Tumblr
  CONFIG = YAML.load(File.read('config.yml'))
  
  BASE_URI  = CONFIG['base_uri']
  READ_URI  = BASE_URI + '/api/read'
  WRITE_URI = BASE_URI + '/api/write'
  
  EMAIL     = CONFIG['email']
  PASSWORD  = CONFIG['password']

  class << self
    def posts(format = nil)
      uri = format.nil? ? READ_URI : READ_URI + "/#{format}"
      HTTParty.post(uri, :body => { :email => EMAIL, :password => PASSWORD })
    end
    
    def create_post(args) #create_post(type, title, body, date = nil)
      HTTParty.post(WRITE_URI, :body => { 
        :email     => EMAIL,
        :password  => PASSWORD,
        :type      => args[:type],
        :title     => args[:title],
        :body      => args[:body],
        :tags      => args[:tags],
        :date      => args[:date],
        :group     => args[:group],
        :private   => args[:private]
        :generator => 'Wordpress 2 Tumblr by Matt Polito'
        })
    end
    
    def import_from_wordpress(file_path)      
      xml = Crack::XML.parse(open(file_path))
      xml['rss']['channel']['item'].each do |item|
        create_post(
          :type  => 'regular', 
          :title => item['title'], 
          :body  => item['content:encoded'], 
          :date  => item['wp:post_date_gmt'])
        p "Imported: #{item['title']}"
      end
    end
  end
  
end