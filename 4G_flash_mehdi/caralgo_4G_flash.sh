#/bin/bash

bash carAlgo_mcu_flash.sh CarAlgo_4G_Bootloader.bin 0x8000000

sleep 0.1

bash carAlgo_mcu_flash.sh caralgo_4G_ble_flasher.bin 0x8008000

sleep 12 

bash carAlgo_mcu_flash.sh CarAlgo+_app_1.2_f9cf2fba_11-05-2022_16:47.bin 0x8008000



