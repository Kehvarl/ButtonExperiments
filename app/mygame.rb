require 'app/game.rb'

# TODO
# - Hide "Passive" count
# - Increase "Defend" decay rate based on "Passive" Count
# - "Fortify" reduces "Passive" Count

class MyGame < Game

    MEDIATE_MESSAGES = [
        {whisper_min: 0, whisper_max: 5, text: "Dear Diary: I meditated and I feel empowered."},
        {whisper_min: 0, whisper_max: 10, text: "Dear Diary: That was a very nice cup of tea."},
        {whisper_min: 5, whisper_max: 15, text: "Dear Diary: Napped a lot."},
        {whisper_min: 5, whisper_max: 20, text: "Hello Friend: Why don't you evern write back?"},
        {whisper_min: 10, whisper_max: 25, text: "Dear Diary: Did you know you can see shapes with your eyes closed?"},
        {whisper_min: 10, whisper_max: 30, text: "Dear Diary: Sometimes I don't want to stop meditating."},
        {whisper_min: 15, whisper_max: 35, text: "Dear meditating, I diaried and spilled my tea."},
        {whisper_min: 15, whisper_max: 40, text: "Lalalalalalallalalalala."},
        {whisper_min: 20, whisper_max: 45, text: "Words.  So many words.   What did they mean?"},
        {whisper_min: 20, whisper_max: 50, text: "Dear Diary: I meditated and I feel tired."},
        {whisper_min: 25, whisper_max: 55, text: ".derewopme leef I dna detatidem I :yraiD raeD"}
        ]


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
        create_log :diary, 300, 10, 680, 270
    end

    def whispers_tick
        a = @actors[:whispers]
        a.ticks_remaining -=1
        if a.ticks_remaining <= 0
            generate_resource(:whispers)
            a.ticks_remaining = a.ticks_total
            if rand(10) <3
                whispers = ["Whispers", "Ghostly touch", "Self doubt", "Management would like a wor."]
                set_resource_label(:whispers, whispers.sample)
            end
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

    def get_meditate_message(value)
        allowed = MEDIATE_MESSAGES.select {|m| m.whisper_min <= value && m.whisper_max >= value }
        allowed.sample().text
    end

    def meditate_clicked
        b = @buttons[:meditate]
        if b.highlight_percent >= 100
            generate_resource(:clarity)
            b.highlight_percent = 0
            add_message(:diary, get_meditate_message(get_resource(:whispers)))
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
            add_message(:diary, "Dear Diary: I don't feel like myself anymore.")
            b.show = false
        end
    end
end

