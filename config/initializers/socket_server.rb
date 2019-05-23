require 'socket'
require 'json'

REDIS_M_CLIENT = Redis.new url: ENV['REDIS_URL']

class Server
  LOGIN = 1
  HEAD_BEAT = 2
  PAY_NOTIFY = 100
  GET_QRCODE = 101
  GET_QRCODE_ERR = 102
  PAY_OVER_NOTIFY = 103
  BATH_BULLID_QRCODE = 104
  CREATE_BIND_CODE = 105
  CLOSE_BIND_CODE = 106
  PAY_NOTIFY_BACK = 201
  PAY_APP_DISABLE = 501
  PAY_APP_NO_LOGIN = 502
  SERVR_ERROR = 500
  CPCHECKORDER = 888
  PAY_TYPE = 'CPPAY'

  def server
    @server
  end

  def initialize(ip, port)
    @server = TCPServer.new ip, port
    @clients = {}
    @id_table = {}
  rescue Errno::ECONNREFUSED, Errno::EADDRINUSE, Errno::EHOSTUNREACH
    @server = nil
  end

  def run
    loop do
      accum_clients
    end
  end

  def accum_clients
    Thread.new(@server.accept) do |client|
      req = JSON.parse(client.gets)
      add_device req['deviceid'], client, req['app_id']
      Rails.logger.info req.to_s
      listen(client)
    rescue StandardError => err
      Rails.logger.error err.inspect
    ensure
      remove_device req['deviceid'] if req
    end
  end

  def add_device(device_id, client, app_id)
    @clients[device_id]&.close
    @clients[device_id] = client
    return check_bot_with_device(device_id) if app_id.blank?
    bot = Bot.find_by(id: app_id)
    if bot && (bot.device_id == device_id)
      @id_table[device_id] = app_id.to_s
    else
      client.puts login_req(nil)
      bot.update device_id: nil
    end
  end

  def check_bot_with_device(id)
    bot = Bot.find_by device_id: id
    if bot && bot.payment_type == 'Unionpayment'
      login(id, bot.id)
      @id_table[id] = bot.id.to_s
    end
  end

  def remove_device(device_id)
    @clients[device_id]&.close
    @clients.delete device_id
    @id_table.delete device_id
  end

  def devices_without_app_id
    @clients.keys - @id_table.keys
  end

  def devices_table
    @id_table
  end

  def send(device_id, cmd)
    @clients[device_id]&.puts(cmd)
  end

  def login_req(app_id)
    JSON.generate appid: app_id, type: LOGIN , paytype: PAY_TYPE,
                  weburl: 'http://www.paiyto.com/', token: '', name: ''
  end

  def login(device_id, app_id)
    send(device_id, login_req(app_id))
  end

  def logoff(device_id)
    send(device_id, login_req(nil))
  end

  def listen(client)
    loop do
      msg = client.gets # &.chomp
      req = JSON.parse(msg)
      case req['type']
      when LOGIN
        next unless req['deviceid'].present?
        if req['app_id'].present?
          @id_table[req['deviceid']] = req['app_id']
          REDIS_M_CLIENT.publish 'login.socket_server', msg
        else
          remove_device(req['deviceid'])
        end
      when HEAD_BEAT
        client.puts(msg)
      when GET_QRCODE
        REDIS_M_CLIENT.publish 'qrcode.socket_server', msg
      else
        REDIS_M_CLIENT.publish 'others.socket_server', msg
      end
    rescue JSON::ParserError
      REDIS_M_CLIENT.publish 'parser_error.socket_server', msg
      next
    end
  end
end

SOCKET_SERVER = Server.new('0.0.0.0', 9988)
Thread.new do
  if SOCKET_SERVER.server
    SOCKET_SERVER.run
  else
    Rails.logger.error 'port 9988 is in use'
  end
end
