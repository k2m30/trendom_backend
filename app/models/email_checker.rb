require 'net/smtp'
require 'dnsruby'

class NoMailServerException < StandardError;
end
class OutOfMailServersException < StandardError;
end
class NotConnectedException < StandardError;
end
class FailureException < StandardError;
end

class EmailChecker
  def initialize(domain_options, email_options, user_email = 'team@trendom.io')
    domain_options.each do |domain|
      @mx_servers = list_mxs domain
      @domain = domain
      break unless @mx_servers.empty?
    end

    raise NoMailServerException.new("No mail server for #{domain_options}") if @mx_servers.empty?
    @smtp = nil

    @user_email = user_email
    _, @user_domain = @user_email.split '@'

    @email_options = email_options.map! { |e| "#{e}@#{@domain}" }
  end

  def find_right_email
    email = nil
    @email_options.each do |e|
      connect
      if verify(e)
        email = e
        break
      end
      close_connection
    end
    email
  end

  def list_mxs(domain)
    return [] unless domain
    res = Dnsruby::DNS.new
    mxs = []
    res.each_resource(domain, 'MX') do |rr|
      mxs << {priority: rr.preference, address: rr.exchange.to_s}
    end
    mxs.sort_by { |mx| mx[:priority] }
  rescue Dnsruby::NXDomain
    raise NoMailServerException.new("#{domain} does not exist")
  end

  def is_connected
    !@smtp.nil?
  end

  def connect
    begin
      server = @mail_server || next_server
      raise OutOfMailServersException.new("Unable to connect to any one of mail servers for #{@email}") if server.nil?
      @smtp = Net::SMTP.start server[:address], 25, @user_domain
      @mail_server = server
      return true
    rescue OutOfMailServersException => e
      @mail_server = nil
      raise OutOfMailServersException, e.message
    rescue => e
      @mail_server = nil
      retry
    end
  end

  def next_server
    @mx_servers.shift
  end

  def verify(email)
    self.mailfrom @user_email
    self.rcptto(email).tap do
      close_connection
    end
  end

  def close_connection
    @smtp.finish if @smtp && @smtp.started?
  end

  def mailfrom(address)
    ensure_connected

    ensure_250 @smtp.mailfrom(address)
  end

  def rcptto(address)
    ensure_connected

    begin
      ensure_250 @smtp.rcptto(address)
    rescue => e
      if e.message[/^550/]
        return false
      else
        raise FailureException.new(e.message)
      end
    end
  end

  def ensure_connected
    raise NotConnectedException.new('You have to connect first') if @smtp.nil?
  end

  def ensure_250(smtp_return)
    if smtp_return.status.to_i == 250
      return true
    else
      raise FailureException.new "Mail server responded with #{smtp_return.status} when we were expecting 250"
    end
  end
end