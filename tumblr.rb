require 'httparty'
require 'yaml'

class Tumblr
  CONFIG = YAML.load(File.read('config.yml'))
  
  BASE_URI  = CONFIG['base_uri']
  READ_URI  = BASE_URI + '/api/read'
  WRITE_URI = BASE_URI + '/api/write'
  
  USERNAME  = CONFIG['username']
  EMAIL     = CONFIG['email']
  PASSWORD  = CONFIG['password']

  class << self
    def posts(format = nil)
      uri = format.nil? ? READ_URI : READ_URI + "/#{format}"
      HTTParty.post(uri, :body => { :username => USERNAME, :password => PASSWORD })
    end
    
    def create_post(type, title, body, date = nil)
      HTTParty.post(WRITE_URI, :body => { 
        :email    => EMAIL,
        :password => PASSWORD,
        :type     => type,
        :title    => title,
        :body     => body,
        :date     => date
        })
    end
    
    def import_from_wordpress(file_path)      
      xml = Crack::XML.parse(open(file_path))
      xml['rss']['channel']['item'].each do |item|
        create_post('regular', item['title'], item['content:encoded'], item['wp:post_date_gmt'])
        p "Imported: #{item['title']}"
      end
    end
  end
  
end