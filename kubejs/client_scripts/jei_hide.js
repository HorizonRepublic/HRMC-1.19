JEIEvents.hideItems(event => {
    // Uncrafting Table
    event.hide('twilightforest:uncrafting_table')

    // Refined Storage Colors
    Color.DYE.forEach(color => {
      ['controller', 'creative_controller', 'grid', 'crafting_grid', 'pattern_grid', 'fluid_grid', 'network_receiver', 'network_transmitter', 'relay', 'detector', 'security_manager', 'wireless_transmitter', 'disk_manipulator', 'crafter', 'crafter_manager', 'crafting_monitor'].forEach(machine => {
        event.hide(`refinedstorage:${color}_${machine}`)
      })
    })
  
  })