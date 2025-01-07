class Game
    def initialize args
        @args = args
        @buttons = {}
        @values = {}
        @default_button_color = {r:128,g:128,b:128}
        @default_border_color = {r:64,g:64,b:64}
        @default_hightlight_color = {r:196,g:196,b:196}
        @default_text_color = {r:0,g:0,b:0}
    end

    def create_button id, x, y, text, w=nil, h=nil
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
            highlight_percent: 0,
            highlight: false,
            primitives: [
                {x:x, y:y, w:w, h:h, **@default_button_color}.solid!,
                {x:x, y:y, w:0, h:h, **@default_hightlight_color}.solid!,
                {x:x, y:y, w:w, h:h, **@default_border_color}.border!,
                {x: x + 10, y:y + 30 ,text:text, **@default_text_color}.label!,
            ]}
    end

    def highlight_button id, starting_percent = 0
        @buttons[id].highlight = true
        @buttons[id].primitives[1].w *= starting_percent
        @buttons[id].highlight_percent = starting_percent
    end

    def tick
        @buttons.each do |b|
            if self.respond_to? b[1].on_tick
                self.send(b[1].on_tick)
            end
            if b[1].highlight and (b[1].highlight_percent < 100)
                b[1].primitives[1].w = b[1].primitives[0].w * (b[1].highlight_percent/100)
            end
        end

        if @args.inputs.mouse.click
            b = @buttons.find do |k, v|
                @args.inputs.mouse.click.point.inside_rect? v[:primitives].first
            end
            if b and self.respond_to? b[1].on_click
                self.send b[1].on_click
            end
        end
    end

    def render
        @buttons.each do |b|
            @args.outputs.primitives << b[1].primitives
            if b[1].highlight
                @args.outputs.primitives << b[1].highlight
            end
        end

        @values.keys.each_with_index do |v, i|
            @args.outputs.primitives << {x: 0, y: 700 - (i * 15)  ,text: "#{v.capitalize}: #{@values[v]}", r: 0, g: 0, b: 0}.label!
        end
    end

    def generate_resource(resource)
        if !@values.key?(resource)
            @values[resource] = 0
        end
        @values[resource]+= 1
    end
end

class MyGame < Game
    def initialize args
        super
        create_button :produce, 600, 400, "Produce!"
        highlight_button :produce
        create_button :defend, 600, 450, "Defend!"
        highlight_button :defend, 100
        puts @buttons
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
        b.highlight_percent -= 0.1
        if b.highlight_percent <= 0
            @buttons.delete(:defend)
        end
    end
end
