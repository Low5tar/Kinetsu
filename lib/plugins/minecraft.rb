module Minecraft
  extend Discordrb::Commands::CommandContainer

  command(:namemc, min_args: 1, max_args: 1) do |event, mcsearch|
    event.respond "NameMC Search: http://namemc.com/s/#{mcsearch}"
  end

  command(:mcstatus) do |event|
    statusurl = JSON.parse(RestClient.get('https://status.mojang.com/check'))
    sites = ['minecraft.net', 'session.minecraft.net', 'account.mojang.com', 'authserver.mojang.com', 'sessionserver.mojang.com', 'api.mojang.com', 'textures.minecraft.net', 'mojang.com']
    green = []
    yellow = []
    red = []

    (0..7).each do |site|
      if statusurl[site][sites[site]] == 'green'
        green[green.length] = sites[site]
      elsif statusurl[site][sites[site]] == 'yellow'
        yellow[yellow.length] = sites[site]
      else
        red[red.length] = sites[site]
      end
    end

    begin
      event.channel.send_embed do |e|
        e.title = 'Minecraft/Mojang Statuses'

        e.add_field(name: 'Working', value: green.join("\n"), inline: true) unless green.length.zero?
        e.add_field(name: '~Shakey~', value: yellow.join("\n"), inline: true) unless yellow.length.zero?
        e.add_field(name: 'Down!!', value: red.join("\n"), inline: true) unless red.length.zero?
        e.color = '00FF00'
      end
    rescue Discordrb::Errors::NoPermission
      event.respond "SYSTEM ERRor, I CANNot SEND THE EMBED, EEEEE. Can I please have the 'Embed Links' permission? Thanks, appreciate ya."
    end
  end

  command(:mcavatar, min_args: 1, max_args: 1) do |event, mcuser|
    event.respond "Alright, here is a 3D full view of the player for the skin: #{mcuser}. https://visage.surgeplay.com/full/512/#{mcuser}.png"
  end

  command(:uuid, min_args: 1, max_args: 1) do |event, name|
    event.respond "The UUID for #{name} is: #{JSON.parse(RestClient.get("https://api.mojang.com/users/profiles/minecraft/#{name}"))['id']}"
  end

  command(:blacklisted, min_args: 1, max_args: 1) do |event, server|
    data = JSON.parse(RestClient.get("https://eu.mc-api.net/v3/server/blacklisted/#{server}"))
    if data['blacklisted'] == true
      event.respond "The server `#{server}` is :warning: **BLACKLISTED** :warning:. Time it took to search: #{data['took']}."
    else
      event.respond "The server `#{server}` is NOT blacklisted. It's safe to play on!"
    end
  end

  command(:mcserver, min_args: 1, max_args: 1) do |event, server|
    data = JSON.parse(RestClient.get("https://eu.mc-api.net/v3/server/ping/#{server}"))
    begin
      event.channel.send_embed do |e|
        e.title = "**Server Info For** `#{server}`"
        e.thumbnail = { url: (data['favicon']).to_s }

        oof = if !data['error'].nil?
                true
              else
                false
              end

        online = if data['online']
                   'Online'
                 else
                   'Offline'
                 end

        e.add_field(name: 'Error', value: data['error'], inline: true) if oof
        e.add_field(name: 'Status', value: online, inline: true)
        e.add_field(name: 'Players [Online/Max]', value: "#{data['players']['online']}/#{data['players']['max']}", inline: true) unless oof
        e.add_field(name: 'Version', value: data['version']['name'], inline: true) unless oof

        e.color = if data['online'] == true
                    '00FF00'
                  else
                    'FF0000'
                  end
      end
    rescue Discordrb::Errors::NoPermission
      event.respond "SYSTEM ERRor, I CANNot SEND THE EMBED, EEEEE. Can I please have the 'Embed Links' permission? Thanks, appreciate ya."
    end
  end
end
