class Game
    def initialize args
        @args = args
        @buttons = {}
        @actors = {}
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
            show: false,
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

    def reveal_button id
        @buttons[id].show = true
    end

    def create_actor id
        @actors[id] = {
                    on_click: "#{id}_clicked".to_sym,
                    on_tick: "#{id}_tick".to_sym,
            }
    end

    def tick
        @actors.each do |a|
            if self.respond_to? a[1].on_tick
                self.send(a[1].on_tick)
            end
        end

        @buttons.each do |b|
            if self.respond_to? b[1].on_tick
                self.send(b[1].on_tick)
            end
            if b[1].highlight and (b[1].highlight_percent <= 100)
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
            if b[1].show
                @args.outputs.primitives << b[1].primitives
                if b[1].highlight
                    @args.outputs.primitives << b[1].highlight
                end
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

    def get_resource(resource)
        if !@values.key?(resource)
            return 0
        end
        return @values[resource]
    end

    def use_resource(resource, qty)
        if !@values.key?(resource)
            return false
        end
        if @values[resource] < qty
            return false
        end
        @values[resource] -= qty
        return true
    end

end
