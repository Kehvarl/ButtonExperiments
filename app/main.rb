require 'app/button.rb'


def init args
    args.state.buttons = {}
    args.state.values = {}
end


def tick args
    if args.state.tick_count == 0
        init args
    end
end
