namespace :crawl do

  @durations_list = %w[ daily weekly monthly ]

  desc "make feed with crawled trending data"
  task feed: :environment do
    bar = make_progress_bar @durations_list.count

    @durations_list.each do |cur_duration|
      bar.inc

      trending_item_class = "trending_#{cur_duration}_news_item".classify.constantize
      trending_items = YAML.load_file("#{@trending_directory}/#{cur_duration}.yml")

      trending_feed = Feed.create! name: "trending_#{cur_duration}"
      trending_items.each do |trending_item|
        trending_feed.news_items << trending_item_class.create!(trending_item)
      end
    end

    bar.finished
  end

  desc "crawl github for trending"
  task github: :environment do

    @durations_list.each_with_index do |cur_duration, cur_index|

      sleep(30.seconds) unless cur_index.zero?

      link_dict = {
        "trending" => [".h3", "p"],
        "trending/developers" => [".h4", ".f6:not(.text-uppercase)"]
      }

      trending_items = []

      link_dict.each do |link_key, link_value|

        github_page = "https://github.com/#{link_key}/julia?since=#{cur_duration}"

        hit_page = HTTParty.get(github_page)

        parsed_page = Nokogiri::HTML(hit_page)

        package_list = parsed_page.css('div.explore-pjax-container article.Box-row')

        if package_list.empty?
          puts "\n-------\n missing trending: #{cur_duration} \n-------"
          next
        end

        package_dict = {}

        package_list.each do |cur_item|

          cur_key = cur_item.css("#{link_value.first} a").first.attributes['href'].value[1..-1]

          if cur_item.css(link_value.last).first.present?
            cur_value = cur_item.css(link_value.last).first.children.to_s.strip
          else
            cur_value = ""
          end

          package_dict[cur_key] = cur_value

        end

        bar = make_progress_bar package_dict.keys.count

        package_dict.each do |cur_key, cur_value|
          bar.inc

          _, package_name = cur_key.split '/'

          next unless package_name.ends_with? ".jl"
          next unless ('A'..'Z').include? package_name.first

          package_name.gsub! '.jl', ''

          next if package_name.downcase == 'julia'

          trending_items << {
            name: package_name,
            link: "https://github.com/#{cur_key}",
            target_type: 'Blurb',
            target_attributes: {
              cargo: cur_value
            }
          }

        end

      end

      FileUtils.mkdir_p(@trending_directory) \
        unless File.directory? @trending_directory

      File.open("#{@trending_directory}/#{cur_duration}.yml", 'w') do |h|
         h.write trending_items.shuffle.to_yaml
      end

    end

  end

end
