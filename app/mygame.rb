require 'app/game.rb'

# TODO
# - Hide "Passive" count
# - Increase "Defend" decay rate based on "Passive" Count
# - "Fortify" reduces "Passive" Count

class MyGame < Game
    def initialize args
        super
        create_button :meditate, 600, 400, "Meditation"
        highlight_button :meditate
        reveal_button :meditate
        create_button :defend, 600, 450, "Sanity"
        highlight_button :defend, 100
        reveal_button :defend
        @defend_increment = 0.1
        create_button :fortify, 600, 500, "Reaffirm Self (3)"
        highlight_button :fortify
        create_actor :whispers
        @actors[:whispers].ticks_total = 120
    end

    def whispers_tick
        a = @actors[:whispers]
        a.ticks_remaining -=1
        if a.ticks_remaining <= 0
            generate_resource(:whispers)
            a.ticks_remaining = a.ticks_total
        end
    end

    def fortify_clicked
        b = @buttons[:fortify]
        if b.highlight_percent >= 100
            if use_resource(:clarity, 3)
                b.highlight_percent = 0
                use_resource(:whispers, 5)
            end
        end
    end

    def fortify_tick
        b = @buttons[:fortify]
        if get_resource(:clarity) >= 3
            b.highlight_percent = 100
            reveal_button :fortify
        else
            b.highlight_percent = 0
        end
    end

    def meditate_clicked
        b = @buttons[:meditate]
        if b.highlight_percent >= 100
            generate_resource(:clarity)
            b.highlight_percent = 0
        end
    end

    def meditate_tick
        b = @buttons[:meditate]
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
        whispers = get_resource(:whispers)
        decay = @defend_increment + (whispers * 0.01)

        b.highlight_percent -= decay
        if b.highlight_percent <= 0
            b.show = false
        end
    end
end

