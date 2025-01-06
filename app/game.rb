class Game
    def initialize args
        @args = args
        @buttons = {}
        @values = {}
        create_button :produce, 600, 400, "Produce!"
    end

    def tick
        @buttons.each do |b|
            self.send(b[1].on_tick)
        end
    end

    def render
        @buttons.each do |b|
            @args.outputs.primitives << b[1].primitives
        end
    end

    def create_button id, x, y, text, w=nil, h=nil,
            color={r:128,g:128,b:128}, border_color={r:128,g:128,b:128},
            text_color={r:0,b:0,g:0}
        if w == nil or h == nil
            w, h = @args.gtk.calcstringbox text
            w += 20
            h += 20
        end
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

    def produce_clicked
    end

    def produce_tick
    end
end
