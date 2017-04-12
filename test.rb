require 'yaml'
require 'erb'
require 'logger'

current_path =  File.dirname(__FILE__)

logger = Logger.new(File.join(current_path,'test.log'))

timestamp = Time.now

input_content = File.read(File.join(current_path,'test.txt'))

collections = YAML.load_file(File.join(current_path,'test.yml')) || []

unless input_content.nil?
  input_content = input_content.split('---')
  logger.info "input_content: #{input_content}"
  input_content.each do |str|
    item = {}
    str.strip!
    item['content'] = str
    item['create_at'] = timestamp
    item['shown_at'] = nil
    collections << item
  end
  File.truncate(File.join(current_path,'test.txt'), 0)
end


first_unshown_content = collections.bsearch do |item|
  item['shown_at'].nil?
end

if first_unshown_content.nil?
  logger.info 'no unshown content found~'
  exit 1
else
  logger.info "will show content: \n #{first_unshown_content}"
end

first_unshown_content['shown_at'] = timestamp

content = first_unshown_content['content'].split(/\n/).map{ |sentence| "<p>#{sentence}</p>" }.join

tpl = ERB.new File.read(File.join(current_path,'test.html.erb'))
result = tpl.result(binding)

File.open(File.join(current_path,'test.html'), 'w') do |f|
  f.write(result)
end

logger.info 'site updated!'

File.open(File.join(current_path,'test.yml'), 'w') do |f|
  f.write(collections.to_yaml)
end

logger.info 'yaml updated!'