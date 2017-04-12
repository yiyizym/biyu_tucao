require 'yaml'
require 'erb'
require 'logger'

class Handler

  attr_reader :current_path, :logger, :timestamp, :all_content, :first_unshown_content

  def initialize
    @current_path =  File.dirname(__FILE__)
    @logger = Logger.new(File.join(current_path,'operation.log'))
    @timestamp = Time.now
    @all_content = YAML.load_file(File.join(current_path,'all_content.yml')) || []
    @first_unshown_content = find_first_unshown_content

    if first_unshown_content.nil?
      logger.info 'no unshown content found~'
      exit 1
    end
    
    logger.info "will show content: \n #{first_unshown_content}"
  end

  def update

    update_unshown_content
    update_page
    write_content

  end

  private

  def find_first_unshown_content

    all_content.concat get_input_content
    all_content.bsearch do |item|
      item['shown_at'].nil?
    end

  end

  def get_input_content

    input_content = File.read(File.join(current_path,'input_content.txt'))
    File.truncate(File.join(current_path,'input_content.txt'), 0)

    return [] if input_content.nil?

    format_content input_content

  end

  def format_content input_content

    content = []
    input_content = input_content.split('---')
    logger.info "input_content: #{input_content}"
    
    input_content.each do |str|
      item = {}
      str.strip!
      item['content'] = str
      item['create_at'] = timestamp
      item['shown_at'] = nil
      content << item
    end
    
    content

  end

  def update_unshown_content
    first_unshown_content['shown_at'] = timestamp
  end

  def update_page
    
    content = first_unshown_content['content'].split(/\n/).map{ |sentence| "<p>#{sentence}</p>" }.join

    tpl = ERB.new File.read(File.join(current_path,'template.html.erb'))
    result = tpl.result(binding)

    File.open(File.join(current_path,'index.html'), 'w') do |f|
      f.write(result)
    end

    logger.info 'site updated!'
  end

  def write_content

    File.open(File.join(current_path,'all_content.yml'), 'w') do |f|
      f.write(all_content.to_yaml)
    end

    logger.info 'all_content.yml updated!'
  end

end