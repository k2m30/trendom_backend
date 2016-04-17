class SilentLogger
  def initialize
    @silencers, @filters = [], []
  end

  def add_silencer(&block)
    @silencers << block
  end

  def call(severity, timestamp, progname, msg)
    return if msg.empty?
    backtrace = (String === msg) ? "#{msg}\n" : "#{msg.inspect}\n"

    return backtrace if @silencers.empty?

    @silencers.each do |s|
      backtrace = backtrace.split("\n").delete_if do |line|
        s.call(line)
      end
    end

    backtrace.delete_if{|line| line.empty?}
    backtrace.insert(0, "#{severity} #{timestamp.to_formatted_s(:long)}") if backtrace.size > 1
    backtrace.insert(-1, "\n")
    backtrace.join("\n")
  end
end

