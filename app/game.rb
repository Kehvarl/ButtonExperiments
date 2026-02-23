class Game
    attr_accessor :running
    def initialize args
        @running = true
        @args = args
        @unlocks = {}
        @buttons = {}
        @actors = {}
        @values = {}
        @logs = {}
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
        @buttons[id].primitives[1].w = @buttons[id].primitives[0].w * (starting_percent / 100.0)
        @buttons[id].highlight_percent = starting_percent
    end

    def reveal_button id
        @buttons[id].show = true
    end

    def create_actor id, ticks_total: 60
        @actors[id] = {
                    ticks_total: ticks_total,
                    ticks_remaining: ticks_total,
                    on_tick: "#{id}_tick".to_sym,
            }
    end

    def create_log id, x, y, w, h
        @logs[id] = {
                id: id,
                x: x, y: y, w: w, h: h,
                messages: [],
                max_messages: 50,
                padding: 8,
                line_height: 16,
                show: true
        }
    end

    def add_message(log_id, text, color=nil)
        log = @logs[log_id]
        return unless log

        c = color || { r: 230, g: 230, b: 230 }
        log[:messages] << {text: text, color: c}
        log[:messages] = log[:messages].last(log[:max_messages])
    end

    def tick
        if not @running
            return
        end
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
                b[1].primitives[1].w = b[1].primitives[0].w * (b[1].highlight_percent/100.0)
            end
        end

        if @args.inputs.mouse.click
            b = @buttons.find do |k, v|
                @args.inputs.mouse.click.point.inside_rect? v[:primitives].first
            end
            if b and b[1].show and self.respond_to? b[1].on_click
                self.send b[1].on_click
            end
        end
    end

    def render
        @buttons.each do |b|
            if b[1].show
                @args.outputs.primitives << b[1].primitives
            end
        end

        visible_values = @values.select { |k, v| v.show }
        visible_values.keys.each_with_index do |v, i|
            resource = visible_values[v]
            @args.outputs.primitives << {x: 0, y: 700 - (i * 18)  ,text: "#{resource.label}: #{resource.value}", r: 0, g: 0, b: 0}.label!
        end

        render_logs
    end


    def wrap_text(text, max_width_px, size_px=14, font=nil)
        words = text.split(" ")
        lines = []
        current_line = ""

        words.each do |word|
            test_line = current_line.empty? ? word : "#{current_line} #{word}"

            w, _h = @args.gtk.calcstringbox(test_line, size_px: size_px, font: font)

            if w <= max_width_px
                current_line = test_line
            else
                lines << current_line unless current_line.empty?
                current_line = word
            end
        end

        lines << current_line unless current_line.empty?

        lines
    end

    def render_logs
        @logs.each do |l|
            log = l[1]

            if not log.show
                next
            end

            # Draw message box
            @args.outputs.primitives << {
                x: log.x,y: log.y, w: log.w,h: log.h,
                r: 20, g: 20, b: 20
            }.solid!

            @args.outputs.primitives << {
                x: log.x,y: log.y, w: log.w,h: log.h,
                r: 200, g: 200, b: 200
            }.border!

            # Render messages bottom-up
            y_cursor = log.y + log.h - log.padding

            log.messages.reverse.each do |msg|
                split_lines = wrap_text(msg.text, log.w - (log.padding * 2), log.line_height)
                split_lines.each do |line|
                    y_cursor -= log.line_height
                    if y_cursor < log.y + log.padding
                        break
                    end
                    @args.outputs.primitives << {
                        x: log.x + log.padding,
                        y: y_cursor,
                        text: line,
                        size_px: log.line_height-1,
                        **msg.color
                    }.label!
                end
            end
        end
    end

    def add_unlock(key)
        @unlocks[key] = false
    end

    def unlocked?(key)
        @unlocks[key] == true
    end

    def unlock(key)
        if not unlocked?(key)
            @unlocks[key] = true
            return true
        end
        return false
    end

    def ensure_resource(resource, show = true)
        if !@values.key?(resource)
            @values[resource] = {value: 0, label: resource.to_s.capitalize, show: show}
        end
    end

    def generate_resource(resource, qty=1, show=true)
        ensure_resource(resource, show)
        @values[resource].value+= qty
    end

    def set_resource(resource, qty, show=true)
        ensure_resource(resource, show)
        @values[resource].value = qty
    end

    def get_resource(resource)
        ensure_resource(resource)
        return @values[resource].value
    end

    def use_resource(resource, qty=1)
        ensure_resource(resource)
        if @values[resource].value < qty
            return false
        end
        @values[resource].value -= qty
        return true
    end

    def set_resource_label(resource, label, show=nil)
        ensure_resource(resource)
        @values[resource].label = label
        if show != nil
            @values[resource].show = show
        end
    end
end
