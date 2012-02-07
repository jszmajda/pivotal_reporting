class PivotalTracker::Story
  def initials
    owned_by.split(/ /).map{|e| e[0] }.join
  end
end
class PivotalReport
  def initialize(options)
    PivotalTracker::Client.token = options[:token]
    @project = PivotalTracker::Project.find(options[:project_id])
  end

  POST_EST = 'epost'

  def report
    show_discussion_items
    separator
    show_story_bullets
    separator
    show_ppu_table
    separator
    show_stories_in_progress
  end

  def show_accounting_breakdown
    # TODO
    raise 'Unimplemented!'
  end

  def separator
    puts "\n-----\n\n"
  end

  def show_discussion_items
    puts "Discussion Items"
    puts ""
    estimates = stories.sort{|a,b| a.owned_by <=> b.owned_by }.map(&:labels).map{|e| e.to_s.split(/,/) }.flatten.map(&:strip).compact.uniq.select{|l| l =~ /^(#{POST_EST}|e\d)$/ }.sort
    estimates.each do |est|
      set = stories_with_label(est)
      set.each do |story|
        puts "(\e[31m#{story.estimate}\e[0m: \e[32m#{est}\e[0m) #{story.name.strip} (\e[33m#{story.initials}\e[0m) [\e[34m#{story.labels}\e[0m]"
      end
    end
  end

  def show_story_bullets
    puts "Story Bullets"
    puts ""
    lis = nil
    stories.sort{|a,b| a.owned_by <=> b.owned_by }.each do |story|
      if story.initials != lis
        lis = story.initials
        puts "#{story.initials}:"
      end
      puts "#{story.story_type.to_s[0]} #{story.name.strip} (#{story.estimate} point#{story.estimate > 1 ? 's' : ''})"
    end
  end

  def show_ppu_table
    puts "PPU Table"

    categories = stories.map(&:labels).map{|e| e.to_s.split(/,/) }.flatten.map(&:strip).compact.uniq.reject{|l| l =~ /^(#{POST_EST}|e\d)$/ }.sort
    people = stories.map(&:owned_by).uniq.sort.map{|p| [p, p.split(/ /).first]}
    c_width = (['Total'] + categories).map(&:length).max

    sseen = []

    o = []
    o << "".ljust(c_width)
    o << " | "
    people.each {|p| o << p[1]; o << " | " }
    o << " Total || Feature | Bug | Chore |"
    puts o.join

    categories.each do |cat|
      o = []
      o << cat.ljust(c_width)
      o << " | "
      people.each do |person, short|
        o << stories_for_user(person, stories_with_label(cat)).map(&:estimate).inject(0){|s,e| s + e }.to_s.rjust(short.length)
        o << " | "
      end
      set = stories_with_label(cat)
      sseen += set
      o << set.map(&:estimate).inject(0){|s,e| s + e }.to_s.rjust('Total '.length)
      o << " || "
      %w{feature bug chore}.each do |type|
        o << stories_with_label(cat, stories_for_type(type)).map(&:estimate).inject(0){|s,e| s + e }.to_s.rjust(type.length)
        o << " | "
      end
      puts o.join
    end

    o = []
    o << "-" * c_width
    o << "-+-"
    people.each do |person, short|
      o << "-" * short.length
      o << "-+-"
    end
    o << "-------++---------+-----+-------+"
    puts o.join

    o = []
    o << "Total".ljust(c_width)
    o << " | "
    people.each do |person, short|
      o << stories_for_user(person).map(&:estimate).inject(0){|s,e| s + e }.to_s.rjust(short.length)
      o << " | "
    end
    o << stories.map(&:estimate).inject(0){|s,e| s + e }.to_s.rjust('Total '.length)
    o << " || "
    %w{feature bug chore}.each do |type|
      o << stories_for_type(type).map(&:estimate).inject(0){|s,e| s + e }.to_s.rjust(type.length)
      o << " | "
    end
    puts o.join

    missing = stories - sseen
    if missing.any?
      puts "Missing:"
      puts missing.map(&:name).join("\n")
    end

  end

  def show_stories_in_progress
    in_progress = @project.stories.all(:state => ['started', 'delivered'])
    points_in_progress = in_progress.map(&:estimate).inject(0){|s,e| s+e}

    puts "In Progress: #{points_in_progress} points"
  end



  private
    def iteration
      @iteration ||= PivotalTracker::Iteration.done(@project, :offset => '-1').first
    end

    def stories
      @stories ||= iteration.stories
    end

    def stories_with_label(label, set=nil)
      set ||= stories
      set.select{|s| s.labels =~ /#{label}/ }
    end

    def stories_for_user(user, set=nil)
      set ||= stories
      set.select{|s| s.owned_by == user }
    end

    def stories_for_type(type, set=nil)
      set ||= stories
      set.select{|s| s.story_type == type }
    end
end
