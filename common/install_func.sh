#!/bin/sh

CONFDIR=/opt/etc/tpws
CONFFILE=$CONFDIR/tpws.conf
LISTFILE=$CONFDIR/user.list
LISTAUTOFILE=$CONFDIR/auto.list
TPWS_BIN=/opt/usr/bin/tpws
INIT_SCRIPT=/opt/etc/init.d/S51tpws
NETFILTER_SCRIPT=/opt/etc/ndm/netfilter.d/100-tpws.sh

stop_func() {
  if [ -f "$INIT_SCRIPT" ]; then
    $INIT_SCRIPT stop
  fi
}

start_func(){
  if [ -f "$INIT_SCRIPT" ]; then
    $INIT_SCRIPT start
  fi
}

show_interfaces_func() {
  echo -e "\n----------------------"
  ip addr show | awk -F" |/" '{gsub(/^ +/,"")}/inet /{print $(NF), $2}'
}

read_yes_or_abort_func() {
  read yn
  case $yn in
    [Yy]* )
      ;;
    * )
      echo "Installation aborted"
      exit
      ;;
  esac
}

begin_install_func() {
  echo -e "\nBegin install? y/N"
  read_yes_or_abort_func
}

begin_uninstall_func() {
  echo -e "\nBegin uninstall? y/N"
  read_yes_or_abort_func
}

remove_all_files_func() {
  rm -f $CONFFILE
  rm -f $TPWS_BIN
  rm -f $INIT_SCRIPT
  rm -f $NETFILTER_SCRIPT
}

remove_list_func() {
  echo -e "\nRemove hosts list? y/N"
  read yn
  case $yn in
    [Yy]* )
      rm -f $LISTFILE
      rm -f $LISTAUTOFILE
      ;;
  esac
}

check_old_config_func() {
  if [ -f "$CONFFILE" ]; then
    echo -e "\nOld config file found: $CONFFILE. It will be overwritten. Continue? y/N"
    read_yes_or_abort_func
  fi
}

install_packages_func() {
  opkg update
  opkg upgrade busybox
  opkg install iptables
}

config_copy_files_func() {
  cp -f $HOME_FOLDER/etc/init.d/S51tpws $INIT_SCRIPT
  chmod +x $INIT_SCRIPT

  cp -f $HOME_FOLDER/etc/ndm/netfilter.d/100-tpws.sh $NETFILTER_SCRIPT
  chmod +x $NETFILTER_SCRIPT

  mkdir -p $CONFDIR
  cp -f $HOME_FOLDER/etc/tpws/tpws.conf $CONFFILE
}

config_copy_list_func() {
  if [ -f "$LISTFILE" ]; then
    echo -e "\nOld hosts list file found: $LISTFILE. Overwrite? y/N"
    read yn
    case $yn in
      [Yy]* )
        cp -f $HOME_FOLDER/etc/tpws/user.list $LISTFILE
        cp -f $HOME_FOLDER/etc/tpws/auto.list $LISTAUTOFILE
        ;;
    esac
  else
    cp -f $HOME_FOLDER/etc/tpws/user.list $LISTFILE
    cp -f $HOME_FOLDER/etc/tpws/auto.list $LISTAUTOFILE
  fi
}

config_select_arch_func() {  
  ARCH="mipsel"
  TPWS_URL="https://raw.githubusercontent.com/bol-van/zapret/master/binaries/mips32r1-lsb/tpws"

  echo "Selected architecture: $ARCH"
  curl -SL# "$TPWS_URL" -o "$TPWS_BIN"
  chmod +x $TPWS_BIN
}

config_select_mode_func() {
  MODE = "list"

  if [ "$MODE" == "list" ]; then
    EXTRA_ARGS="--hostlist=$LISTFILE"
  fi
  echo "Selected mode: $MODE"

  sed -i "s#INPUT_EXTRA_ARGS#$EXTRA_ARGS#" $CONFFILE
}

config_local_interface_func() {
  if [ -z "$BIND_IFACE" ]; then
    echo -e "\nEnter the local interface name from the list above, e.g. br0 (default) or nwg0"
    echo "You can specify multiple interfaces separated by space, e.g. br0 nwg0"
    read BIND_IFACE
  fi
  if [ -z "$BIND_IFACE" ]; then
    BIND_IFACE="br0"
  fi
  echo "Selected interface: $BIND_IFACE"

  sed -i "s#INPUT_LOCAL_INTERFACE#$BIND_IFACE#" $CONFFILE
}
