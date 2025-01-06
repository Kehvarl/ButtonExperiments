class Game
    def initialize
        @buttons = {}
        @values = {}
        create_button :produce, 600, 400, "Produce!"
    end

    def tick args
        @buttons.each do |b|
            self.send(b[1].on_tick, args)
        end
    end

    def create_button  id, x, y, text, w=80, h=40,
            color={r:128,g:128,b:128}, border_color={r:128,g:128,b:128},
            text_color={r:0,b:0,g:0}
        @buttons[id] = {
            text: text,
            on_click: "#{id}_clicked".to_sym,
            on_tick: "#{id}_tick".to_sym,
            visible: true,
            primitives: [
                {x:x, y:y, w:w, h:h, **color}.solid!,
                {x:x, y:y, w:w, h:h, **border_color}.border!,
                {x: x + 10, y:y + 30 ,text:text, **text_color}.label!,
            ]}
    end

    def produce_clicked args
    end

    def produce_tick args
        puts("produce tick")
    end
end
