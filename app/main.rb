require 'app/game.rb'

def init args
    args.state.game = MyGame.new(args)
end


def tick args
    if args.state.tick_count == 0
        init args
    end

    args.state.game.tick()
    args.state.game.render()
end
