# Ship Combat Simulator

#  * Ships
#    * Name
#    * Type
#      * Merchant
#      * Treasure Ship
#      * Warship
#    * Factions
#    * Frequency
#    * Attackable
#    * Combat Level Range
#    * Treasure Level Range
#    * Special Features

class Ship
    attr_accessor :name, :type, :factions, :attackable, :combat, :treasure, :special

    def initialize args
        @name = args.name || "Generic Ship"
        @type = args.type || :treasure_ship
        @factions = args.factions || {}
        @attackable = args.attackable || true
        @combat = args.combat || {range: 0, close: 0, defense: 0, health: 1}
        @treasure = args.treasure || {cash: 10, goods: 0}
        @special = args.special || []
    end

    def attack other
        damage = @combat.range - other.combat[defense]
        if damage > 0
            other.combat.health -= damage
        end
        if other.combat.health <= 0
            return :other_defeated
        end
        return :ok
    end
end
