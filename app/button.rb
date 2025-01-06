
def CreateButton  x, y, id, text, w=80, h=40,
        color={r:128,g:128,b:128}, border_color={r:128,g:128,b:128},
        text_color={r:0,b:0,g:0}
    button = {
        id: id,
        text: text,
        primitives: [
            {x:x, y:y, w:w, h:h, **color}.solid!,
            {x:x, y:y, w:w, h:h, **border_color}.border!,
            {x: x + 10, y:y + 30 ,text:text, **text_color}.label!,
        ]}
    return button
end

# From Save-Load-Game Sample
def button id, x, y, text
    @button_list[id] ||= { # assigns values to hash keys
    id: id,
    text: text,
    primitives: [
        [x + 10, y + 30, text, 2, 0].label, # positions label inside border
        [x, y, 300, 50].border,             # sets definition of border
    ]
    }

    @button_list[id][:primitives] # returns label and border for buttons
end
