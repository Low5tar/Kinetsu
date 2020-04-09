module Restart
  extend Discordrb::Commands::CommandContainer

  command(:restart) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond "Sorry kiddo, you can't restart the bot!"
      break
    end
    event.respond 'Restarting the bot...'
    sleep 1
    exec('ruby run.rb')
  end

  command(:update) do |event|
    unless event.user.id == CONFIG['owner_id']
      event.respond "Imma keep it real with u chief! You can't update the bot."
      return
    end
    m = event.respond 'Updating...'
    changes = `git pull`
    m.edit('', Discordrb::Webhooks::Embed.new(
                 title: '**Updated Successfully**',

                 description: changes,
                 color: 0x7ED321
               ))
  end

  command(:updates) do |event|
    `git fetch` if event.user.id == CONFIG['owner_id']
    response = `git rev-list origin/master | wc -l`.to_i
    commits = `git rev-list master | wc -l`.to_i
    if commits.zero?
      event.respond "Your machine doesn't support git or it isn't working!"
      break
    end
    if event.user.id == CONFIG['owner_id']
      begin
        event.channel.send_embed do |e|
          e.title = "You are running Chewbotcca commit #{commits}"
          if response == commits
            e.description = 'You are running the latest commit.'
            e.color = '00FF00'
          elsif response < commits
            e.description = "You are running an un-pushed commit! Are you a developer? (Most Recent: #{response})\n**Here are up to 5 most recent commits.**\n#{`git log origin/master..master --pretty=format:\"[%h](http://github.com/Chewbotcca/Discord/commit/%H) - %s\" -5`}"
            e.color = 'FFFF00'
          else
            e.description = "You are #{response - commits} commit(s) behind! Run `%^update` to update.\n**Here are up to 5 most recent commits.**\n#{`git log master..origin/master --pretty=format:\"[%h](http://github.com/Chewbotcca/Discord/commit/%H) - %s\" -5`}"
            e.color = 'FF0000'
          end
        end
      rescue Discordrb::Errors::NoPermission
        event.respond "SYSTEM ERRor, I CANNot SEND THE EMBED, EEEEE. Can I please have the 'Embed Links' permission? Thanks, appriciate ya."
      end
    end
  end

  command(:shoo) do |event|
    break unless event.user.id == CONFIG['owner_id']

    event.send_temporary_message('I am shutting dowm, it\'s been a long run folks!', 3)
    sleep 3
    exit
  end

  command(:new) do |event|
    begin
      event.channel.send_embed do |e|
        e.title = 'Top 10 most recent changes (via git)'
        e.color = '00FF00'
        e.description = `git log master --pretty=format:\"[%h](http://github.com/Chewbotcca/Discord/commit/%H) - %s\" -10`.to_s
      end
    rescue Discordrb::Errors::NoPermission
      event.respond "SYSTEM ERRor, I CANNot SEND THE EMBED, EEEEE. Can I please have the 'Embed Links' permission? Thanks, appriciate ya."
    end
  end
end
