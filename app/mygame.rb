require 'app/game.rb'

class MyGame < Game
    def initialize args
        super
        create_button :produce, 600, 400, "Produce!"
        highlight_button :produce
        reveal_button :produce
        create_button :defend, 600, 450, "Defend!"
        highlight_button :defend, 100
        reveal_button :defend
        @defend_increment = 0.1
        create_button :fortify, 600, 500, "Fortify (3)"
        highlight_button :fortify
    end

    def fortify_clicked
        b = @buttons[:fortify]
        if b.highlight_percent >= 100
            if use_resource(:resource, 3)
                b.highlight_percent = 0
                @defend_increment *= 0.75
            end
        end
    end

    def fortify_tick
        b = @buttons[:fortify]
        if get_resource(:resource) >= 3
            b.highlight_percent = 100
            reveal_button :fortify
        else
            b.highlight_percent = 0
        end
    end

    def produce_clicked
        b = @buttons[:produce]
        if b.highlight_percent >= 100
            generate_resource(:resource)
            b.highlight_percent = 0
        end
    end

    def produce_tick
        b = @buttons[:produce]
        b.highlight_percent += 1
    end


    def defend_clicked
        b = @buttons[:defend]
        if b.highlight_percent > 0
            b.highlight_percent = 100
        end
    end

    def defend_tick
        b = @buttons[:defend]
        b.highlight_percent -= @defend_increment
        if b.highlight_percent <= 0
            @buttons.delete(:defend)
        end
    end
end

