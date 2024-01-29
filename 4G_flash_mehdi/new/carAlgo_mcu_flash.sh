#/bin/bash
#
# Consts
set -x
this_path="$(dirname $(realpath $0))"
fw_address_default="0x8000000"
target_cfg_file_name="$this_path/target.cfg"
openocd_cfg_file_name="$this_path/openocd.cfg"
#
nb_arguments=$#
fw_file_input=$1
fw_address_input=$2
#
usage() {
    echo "$0 <firmware_file> [optional] <address in hex: default 0x8000000>"
}
#
openocd_tmp_files_create() {
    # target file cfg
    rm -f $target_cfg_file_name
    touch $target_cfg_file_name
    printf "source [find interface/stlink.cfg]\n\n" >> $target_cfg_file_name
    printf "transport select hla_swd\n\n" >> $target_cfg_file_name
    printf "source [find target/stm32l4x.cfg]\n" >> $target_cfg_file_name

    # openocd cfg file
    rm -f $openocd_cfg_file_name
    touch $openocd_cfg_file_name
    printf "debug_level 2\ninit\nreset init\nhalt\n" >> $openocd_cfg_file_name
    printf "flash write_image erase file.bin 0x8000000\n" >> $openocd_cfg_file_name
    printf "reset run\nshutdown\n" >> $openocd_cfg_file_name
}
#
openocd_tmp_files_delete() {
    rm -f $target_cfg_file_name
    rm -f $openocd_cfg_file_name
}
#
input_control() {
    # Input Control
    if [ $nb_arguments -eq 0 ]; then
        usage && echo "Nb arguments = 0, need to be >= 1" && exit 1
    elif [ $nb_arguments -eq 1 ]; then # only file path provided
        fw_file=$fw_file_input
        fw_address=$fw_address_default
    elif [ $nb_arguments -eq 2 ]; then # both file & address provided
        fw_file=$fw_file_input
        fw_address=$fw_address_input
    elif [ $nb_arguments -gt 2 ]; then # too many arguments
        usage && exit 1
    fi
    #
    [ ! -f $fw_file ] && echo "File '$fw_file' : Not found !!!!!" && exit 1
    if [ $((16#${fw_address:2})) -lt $((16#${fw_address_default:2})) ];then
        echo "Firmware address is not valid" && exit 1
    fi
}
#
input_control
#
openocd_tmp_files_create
#
sed -i "s@flash write_image erase .*@flash write_image erase $fw_file $fw_address@" $openocd_cfg_file_name
#
for i in `seq 1 5`; do
    echo "************************************************************"
    time openocd -f $target_cfg_file_name -f $openocd_cfg_file_name > /dev/null
    flash_ret=$?
    [ $flash_ret -eq 0 ] && break
done
#
openocd_tmp_files_delete
#
exit $flash_ret