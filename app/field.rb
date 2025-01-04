class Field
    def initialize x,y,w,h,border_w,border_color,fill_color
        @x = x
        @y = y
        @w = w
        @h = h
        @border_w =  border_w
        @border_color = border_color
        @fill_color = fill_color
    end

    def render
        out = []
        (0..@border_w).each do |delta|
            out << {x: @x+delta, y: @y+delta, w: @w-(2*delta), h: @h-(2*delta), **@border_color}.border!
        end
        out << {x: @x+@border_w+1, y: @y+@border_w+1, w: @w-(2*@border_w)-2, h: @h-(2*@border_w)-2, **@fill_color}.solid!
    end
end

class TextField < Field
    def initialize x,y,w,h,border_w,border_color,fill_color,text_color
        super(x,y,w,h,border_w,border_color,fill_color)
        @text_color = text_color
        @line_length = 80
    end

    def render(text)
        out = super()
        lines = String.wrapped_lines(text, @line_length)

        out << lines.map_with_index do |s, i|
        {
            x: @x+@border_w+1,
            y: (@y + @h)- (2*@border_w) - (i * 8) - 20,
            anchor_y: i,
            text: s,
            **@text_color
        }
        end
        out
    end
end

class MenuField < Field
    attr_accessor :items, :selected, :action

    def initialize x,y,w,h,border_w,border_color,fill_color,text_color,selected_fill_color,selected_text_color
        super(x,y,w,h,border_w,border_color,fill_color)
        @text_color = text_color
        @selected_text_color = selected_text_color
        @selected_fill_color = selected_fill_color
        @items = []
        @selected = 0
        @action = false
    end

    def render(test)
        out = super()
        out << @items.map_with_index do |s, i|
            if i == @selected
                fill = @selected_fill_color
                text = @selected_text_color
            else
                fill = @fill_color
                text = @text_color
            end
            [{x: @x+@border_w+1,y: (@y + @h)- (2*@border_w) - (i * 30) - 20, w: @w-(2*@border_w)-2, h: 25, **fill}.solid!,
             {x: @x+@border_w+1,y: (@y + @h)- (2*@border_w) - (i * 8) - 20,anchor_y: i,text: s,
            **text}.label!
            ]
        end
        out
    end
end
