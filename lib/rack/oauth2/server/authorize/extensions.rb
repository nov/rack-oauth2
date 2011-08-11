Dir[File.dirname(__FILE__) + '/extensions/*.rb'].each do |file| 
  require file
end