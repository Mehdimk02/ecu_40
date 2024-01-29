bash carAlgo_mcu_flash.sh CarAlgo_4G_Bootloader.bin 0x8000000

sleep 0.1

bash carAlgo_mcu_flash.sh caralgo_4G_ble_flasher.bin 0x8008000

st-flash reset


