class Lecture < ActiveRecord::Base
  belongs_to :course
  has_many :lecture_dates, :autosave => true
  validates_presence_of :course

  def after_initialize
    if new_record?
      if self.number.nil?
        self.number = ActiveRecord::Base.connection.execute("select max(number) from lectures where course_id=#{self.course_id}").first["max"].to_i + 1
      end
    end
  end

  def lecture_dates_string
    lecture_dates.sort {|d1,d2| d1.date <=> d2.date}.collect { |d| d.date.to_formatted_s(:rfc822) }.join('<br/>')
  end
  
  def lecture_dates_string=(dates)
    logger.debug "Lecture dates= #{dates.inspect}"
    lecture_dates.delete_all
    if dates.is_a? Array
      dates.each do |date|
        lecture_dates.build({:date => date})
      end
    else
      lecture_dates.build({:date=>dates})
    end
    lecture_dates.each { |ld| ld.lecture = self }
  end
end
