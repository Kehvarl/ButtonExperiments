require 'app/button.rb'


def init args
    args.state.buttons = {
        loot: DelayActivationButton.new({x:600, y:350, w:80, h:40,
                                         unlocked:true,
                                         value:"Loot", increment:1,
                                         text:"Loot!", display:true}),
        lootmore: CountDownButton.new({x:600, y:300, w:175, h:40,
                                       unlocked:false, unlock_value:"Loot", unlock_cost:10,
                                       value:"Loot", increment:10,
                                       click_value:"Loot", click_cost:5,
                                       text:"Loot More! (5)", display:true}),
        autoloot: Button.new({x:700, y:350, w:150, h:40,
                              unlocked:false, unlock_value:"Loot", unlock_cost:100,
                              click_once:true,
                              value:nil, increment:0,
                              click_value:"Loot", click_cost:100,
                              text:"AutoLoot (100)", display:false,
                              color:{r: 240, g: 240, b: 240},
                              change_other:{loot:{"auto_click=":true, "auto_click_rate=":1}}
                    })
    }
    args.state.values = {}
end


def tick args
    if args.state.tick_count == 0
        init args
    end

    args.state.buttons.keys.each do |k|
        b = args.state.buttons[k]
        if b.unlocked == false and
                args.state.values.key?(b.unlock_value) and
                args.state.values[b.unlock_value] >= b.unlock_cost
            b.unlocked = true
        end
        if b.unlocked
            (value, increment) = b.tick(args)
            if value
                args.state.values[value] += increment
            end
            args.outputs.primitives << b.render
        end
    end

    if args.inputs.mouse.click
        args.state.buttons.keys.each do |k|
            b = args.state.buttons[k]
            if args.inputs.mouse.click.inside_rect?(b) and b.clickable
                if b.click_cost > 0
                    if args.state.values[b.click_value] >= b.click_cost
                        args.state.values[b.click_value] -= b.click_cost
                    else
                        return
                    end
                end
                (value, increment) = b.click(args)
                if value
                    args.state.values[value] += increment
                end
            end
        end
    end

    args.state.buttons.keys.each_with_index do |k, i|
        b = args.state.buttons[k]
        if b.display
            if not args.state.values.key?(b.value)
                args.state.values[b.value] = 0
            end
        end
    end
    args.state.values.keys.each_with_index do |v, i|
        args.outputs.primitives << {x: 0, y: 700 - (i * 15)  ,text: "#{v}: #{args.state.values[v]}", r: 0, g: 0, b: 0}.label!
    end
end

