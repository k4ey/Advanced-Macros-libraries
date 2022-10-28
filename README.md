# Advanced-Macros-libraries

### I highly suggest using this fork: https://github.com/MajsterTynek/AdvancedMacros-WD_fix

### Features:

#### Inventory

* Inventory.open(chest)
* Inventory.calc(name,range)
* Inventory.move(name,amount,source,destination)
* Inventory.refill(name,amount,source,destination)
* Inventory.calcEmptySlots(range)
* Inventory.dropItems(range)
* Inventory.find(name,range)
* Inventory.placeInHotbar(slot,item)
* Inventory.deepFind(itemAttribute,range)

#### Logging

* Logger.emerg(text)
* Logger.alert(text)
* Logger.crit(text)
* Logger.err(text)
* Logger.warning(text)
* Logger.notice(text)
* Logger.info(text)
* Logger.debug(text)

#### DonkeyLib

* DonkeyLib.sit(uuid)
* DonkeyLib.distanceTo(uuid)
* DonkeyLib.lookAt(uuid)
* DonkeyLib.open(uuid)
* DonkeyLib.walkTo(uuid)
* DonkeyLib.getByName(uuid)
* DonkeyLib.getClosest(uuid)
* DonkeyLib.getByUUID(uuid)

#### Relogging

* Relogging(serverIP,tiemoutDuration)

#### relativeBlocks 

 * Blocks.getBlockByRelative(relative,position)
 * Blocks.getBlockByDirection(direction,position,horizontalOffset,verticalOffset)
 * Blocks.addIndices(table1,table2)
 * Blocks.direction(direction,offset)
 * Blocks.show(blocks,allowXray,delay)

#### more docs are in the code
