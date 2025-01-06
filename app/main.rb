require 'app/game.rb'

def init args
    args.state.game = Game.new()
end


def tick args
    if args.state.tick_count == 0
        init args
    end

    args.state.game.tick(args)
end

