class Epicenter < ActiveRecord::Base

  def video
    if video_url.present?
      # <iframe width="560" height="315" src="https://www.youtube.com/embed/AiZFoxjQFcI" frameborder="0" allowfullscreen></iframe>
      if video_url.include? "youtube"
        id = video_url.split('watch?v=')[1]
        embed_link = "<iframe width='560' height='315' src='https://www.youtube.com/embed/#{id}' frameborder='0' allowfullscreen></iframe>"
        return embed_link
      end
    end
    return ""
  end

end
