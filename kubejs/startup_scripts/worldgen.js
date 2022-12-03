WorldgenEvents.add(event => {
    event.addOre((ore) => {
      ore.id = "kubejs:mining_poor_uraninite"
      ore.biomes = ['allthemodium:mining']
      ore.addTarget('minecraft:stone', 'powah:uraninite_ore_poor')
      ore.addTarget('minecraft:deepslate', 'powah:deepslate_uraninite_ore_poor')
      ore.size(5)
      ore.count(8)
      ore.squared()
      ore.uniformHeight(64, 254)
    })
    event.addOre((ore) => {
      ore.id = "kubejs:mining_uraninite"
      ore.biomes = ['allthemodium:mining']
      ore.addTarget('minecraft:stone', 'powah:uraninite_ore')
      ore.addTarget('minecraft:deepslate', 'powah:deepslate_uraninite_ore')
      ore.size(4)
      ore.count(6)
      ore.squared()
      ore.uniformHeight(64, 254)
    })
    event.addOre((ore) => {
      ore.id = "kubejs:mining_dense_uraninite"
      ore.biomes = ['allthemodium:mining']
      ore.addTarget('minecraft:stone', 'powah:uraninite_ore_dense')
      ore.addTarget('minecraft:deepslate', 'powah:deepslate_uraninite_ore_dense')
      ore.size(3)
      ore.count(3)
      ore.squared()
      ore.uniformHeight(64, 254)
    })
    event.addOre((ore) => {
        ore.id = "kubejs:mining_fluorite"
        ore.biomes = ['allthemodium:mining']
        ore.addTarget('minecraft:stone', 'mekanism:fluorite_ore')
        ore.addTarget('minecraft:deepslate', 'mekanism:deepslate_fluorite_ore')
        ore.size(9)
        ore.count([15, 50])
				.squared()
				.triangleHeight(
						anchors.aboveBottom(64),
						anchors.absolute(254)
				)
        // ore.squared()
        // ore.uniformHeight(64, 254)
      })
  })
