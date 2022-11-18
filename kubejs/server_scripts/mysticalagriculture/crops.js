const CropRegistry = Java.loadClass('com.blakebr0.mysticalagriculture.registry.CropRegistry')

const CropManualDisableList = []
// sets the chance for a seed to drop
const SecondarySeed = 0.01

ServerEvents.tags('item', event => {
    let CropRegistryInstance = CropRegistry.getInstance()
    let cropTiers = CropRegistryInstance.getTiers()
    let tiers = Array.apply(null, Array(cropTiers.length))
    for (const CropTier of cropTiers) {
        tiers[CropTier.getValue() - 1] = CropTier.getFarmland()
    }
    for (let i = 0; i < tiers.length; i++) {
        let farmA = tiers[i]
        let farmB = null
        if (i + 1 < tiers.length) {
            if (!farmA.equals(tiers[i + 1])) {
                farmB = tiers[i + 1]
            }
        }
        let tierA = farmA.getIdLocation().getPath().replace('_farmland', '')
        event.add(`kubejs:farmland/${tierA}`, farmA.getId())
        if (farmB) {
            let tierB = farmB.getIdLocation().getPath().replace('_farmland', '')
            event.add(`kubejs:farmland/${tierA}`, `#kubejs:farmland/${tierB}`)
        } else {
            break
        }
    }
})

ServerEvents.recipes(event => {
    let JsonExport = { enabled: [], disabled: [], manual: [] }
    let CropRegistryInstance = CropRegistry.getInstance()
    let CropList = CropRegistryInstance.getCrops()
    for (const Crop of CropList) {
        let CropName = Crop.getName()
        if (Crop.isEnabled()) {
            if (CropManualDisableList.includes(Crop.getName())) {
                Crop.setEnabled(false)
                JsonExport.manual.push(CropName)
                continue
            }
            JsonExport.enabled.push(CropName)
        } else {
            JsonExport.disabled.push(CropName)
        }
    }
    JsonIO.write('kubejs/server_scripts/mysticalagriculture/cropInfo.json', JsonExport)

    // Immersive Engineering Cloche
    if (Platform.isLoaded('immersiveengineering')) {
        JsonExport.enabled.forEach(cropName => {
            let Crop = CropRegistryInstance.getCropByName(cropName)
            event.custom({
                type: 'immersiveengineering:cloche',
                results: [
                    {
                        item: Crop.getEssenceItem().getId(),
                        count: 2
                    }
                ],
                input: Ingredient.of(Crop.getSeedsItem()).toJson(),
                soil: Ingredient.of(Crop.getCruxBlock() ?? `#kubejs:farmland/${Crop.getTier().getFarmland().getIdLocation().getPath().replace('_farmland', '')}`).toJson(),
                time: 250 + (750 * Crop.getTier().getValue()),
                render: {
                    type: 'crop',
                    block: Crop.getCropBlock().getId()
                }
            }).id(`kubejs:immersiveengineering/cloche/mysticalagriculture/${cropName}`)
        })
    }
})
