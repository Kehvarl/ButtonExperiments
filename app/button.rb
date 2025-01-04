
class Button
    attr_accessor :x, :y, :w, :h, :text, :display,
            :value, :increment,
            :unlocked, :unlock_value, :unlock_cost,
            :click_once,
            :click_value, :click_cost, :clickable,
            :auto_click, :auto_click_rate,
            :color, :border_color, :text_color,
            :change_other

    def initialize args
        @x = args.x || 0
        @y = args.y || 0
        @w = args.w || 100
        @h = args.h || 60
        @color = args.color || {r: 128, g: 128, b: 128}
        @text = args.text || "Button"
        @display = args.display || false
        @unlocked = args.unlocked || false
        @unlock_value = args.unlock_value || nil
        @unlock_cost = args.unlock_cost || 0
        @click_once = args.click_once || false
        @value = args.value || nil
        @click_value = args.click_value || nil
        @click_cost = args.click_cost || 0
        @clickable = args.clickable || true
        @increment = args.increment || 0
        @auto_click = args.auto_click || false
        @auto_click_rate = args.auto_click_rate || 0
        @auto_click_count = 100
        @text_color = args.text_color || {r: 0, g: 0, b: 0}
        @highlight_color = args.highlight_color || {r: 240, g: 240, b: 240}
        @border_color = args.border_color || @color
        @change_other = args.change_other || nil
    end

    def to_s
        return "#{@text}, #{@auto_click}, #{@auto_click_rate}, #{@auto_click_count}"
    end

    def tick args
        if @auto_click
            @auto_click_count -= @auto_click_rate
            if @auto_click_count <= 0
                @auto_click_count = 100
                click(args)
            end
        end
        return [nil, nil]
    end

    def click args
        if @change_other
            @change_other.keys.each do |b|
                @change_other[b].keys.each do |c|
                    args.state.buttons[b].send(c, @change_other[b][c])
                    puts(b, c, @change_other[b][c])
                end
                puts(args.state.buttons[b])
            end
        end
        if @click_once
            @unlocked = false
            @unlock_value = nil
        end

        return [@value, @increment]
    end

    def render
        [
            {x: @x, y: @y, w: @w, h: @h, **@color}.solid!,
            {x: @x, y: @y, w: @w, h: @h, **@border_color}.border!,
            {x: @x + 20, y: @y + 30 ,text: @text, **@text_color}.label!,
        ]
    end
end

class DelayActivationButton < Button
    attr_accessor :fill_rate

    def initialize args
        super
        @increment = args.increment || 0
        @highlight = args.highlight || 0
        @fill_rate = 1
        @highlight_color = args.highlight_color || {r: 240, g: 240, b: 240}
    end

    def tick args
        @highlight += @fill_rate
        if @highlight >= 100
            @highlight = 100
            @clickable = true
        end
        if @auto_click and @clickable
            return click(args)
        end
        return [nil, nil]
    end

    def click args
        if @highlight >= 100
            @highlight = 0
            @clickable = false
            return [@value, @increment]
        end
        return [nil, nil]
    end

    def render
        [
            {x: @x, y: @y, w: @w, h: @h, **@color}.solid!,
            {x: @x, y: @y, w: @w * (@highlight/100), h: @h, **@highlight_color}.solid!,
            {x: @x, y: @y, w: @w, h: @h, **@border_color}.border!,
            {x: @x + 20, y: @y + 30 ,text: @text, **@text_color}.label!,
        ]
    end
end

class CountDownButton < Button
    attr_accessor :count_rate, :running

    def initialize args
        super
        @increment = args.increment || 0
        @highlight = args.highlight || 0
        @count_rate = args.count_rate || 1
        @running = false
        @color = args.highlight_color || {r: 240, g: 240, b: 240}
        @highlight_color = args.highlight_color || {r: 128, g: 128, b: 128}

    end

    def tick args
        if @running
            @highlight -= @count_rate
        end
        if @running and @highlight <= 0
            @highlight = 0
            @running = false
            @clickable = true
            return [@value, @increment]
        end
        return [nil, nil]
    end

    def click args
        if not @running
            @running = true
            @clickable = false
            @highlight = 100
        end
        return [nil, nil]
    end

    def render
        [
            {x: @x, y: @y, w: @w, h: @h, **@color}.solid!,
            {x: @x, y: @y, w: @w * (@highlight/100), h: @h, **@highlight_color}.solid!,
            {x: @x, y: @y, w: @w, h: @h, **@border_color}.border!,
            {x: @x + 20, y: @y + 30 ,text: @text, **@text_color}.label!,
        ]
    end
end
