
def CreateButton  args, id, x, y, text, w=80, h=40,
        color={r:128,g:128,b:128}, border_color={r:128,g:128,b:128},
        text_color={r:0,b:0,g:0}
    args.state.buttons[id] = {
        text: text,
        on_click: "#{id}_clicked".to_sym,
        on_tick: "#{id}_tick".to_sym,
        visible: true,
        primitives: [
            {x:x, y:y, w:w, h:h, **color}.solid!,
            {x:x, y:y, w:w, h:h, **border_color}.border!,
            {x: x + 10, y:y + 30 ,text:text, **text_color}.label!,
        ]}
    return button
end

def init args
    args.state.buttons = {}
    args.state.values = {}
end


def tick args
    if args.state.tick_count == 0
        init args
    end
end
