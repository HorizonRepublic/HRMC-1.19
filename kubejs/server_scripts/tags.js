ServerEvents.tags('fluid', event =>{
    event.add('forge:crude_oil', 'ad_astra:oil')
    event.remove('minecraft:water', 'ad_astra:oil')
  })