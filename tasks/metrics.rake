unless 'production' == ENV['RACK_ENV']
  require "flay_task"
  FlayTask.new do |t|
    t.dirs = %w[lib]
  end

  require "flog"
  desc 'Analyze code using ABC metric'
  task :flog do
    flog = Flog.new
    flog.flog ['lib']
    threshold = 50

    bad_methods = flog.totals.select do |name, score|
      score > threshold
    end

    bad_methods.sort do |a, b|
      a[1] <=> b[1]
    end.each do |name, score|
      puts "%8.1f: %s" % [score, name]
    end

    unless bad_methods.empty?
      raise "#{bad_methods.size} methods have a flog complexity > #{threshold}"
    end
  end
end
