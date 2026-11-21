  Bridge = {}

  function Bridge.showPrompt(text)
    lib.showTextUI(text, { position = 'left-center', icon = 'box-archive' })
  end

  function Bridge.hidePrompt()
    lib.hideTextUI()
  end

  function Bridge.openStash(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
  end