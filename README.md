# tpws-keenetic

Форк с https://github.com/Anonym-tsk/tpws-keenetic

Подключение к entware на роутере

    ssh -p 222 root@192.168.1.1

`user.list` генерируется вручную подтягиваем периодечески из https://bitbucket.org/anticensority/russian-unlisted-blocks/src/master/readme.txt

### Подготовка

(опционально) Рекомендуется отключить провайдерский DNS на маршрутизаторе и [настроить использование DoT/DoH](https://help.keenetic.com/hc/ru/articles/360007687159).

Установить entware на маршрутизатор по инструкции [на встроенную память роутера](https://help.keenetic.com/hc/ru/articles/360021888880) или [на USB-накопитель](https://help.keenetic.com/hc/ru/articles/360021214160).

Все дальнейшие команды выполняются не в cli роутера, а **в среде entware**.

**Следуйте инструкции установщика:**

1. Введите локальный сетевой интерфейс, обычно это `br0`
> Можно указать несколько интерфейсов через пробел (`br0 nwg0`), например, чтобы обрабатывать трафик от клиентов, подключенных через VPN или в гостевой сети


### Ручная установка (не рекомендуется, если entware установлен во внутреннюю память)

```
opkg install git git-http curl
git clone https://github.com/Anonym-tsk/tpws-keenetic.git --depth 1
chmod +x ./tpws-keenetic/*.sh
./tpws-keenetic/install.sh
```

##### Удаление

```
./tpws-keenetic/uninstall.sh
```

### Полезное

1. Конфиг-файл `/opt/etc/tpws/tpws.conf`
2. Скрипт запуска/остановки `/opt/etc/init.d/S51tpws {start|stop|restart|status}`
3. Вручную добавить домены в список можно в файле `/opt/etc/tpws/user.list`
4. Автоматически добавленные домены `/opt/etc/tpws/auto.list`
5. Проверить, что нужные правила добавлены в таблицу маршрутизации `iptables-save | grep "to-ports 999$"`
> Вы должны увидеть похожие строки (по 3 на каждый выбранный сетевой интерфейс)
> ```
> -A PREROUTING -i br0 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 999
> -A PREROUTING -i br0 -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 999
> -A PREROUTING -i br0 -p udp -m udp --dport 443 -j REDIRECT --to-ports 999
> ```
6. Если ничего не работает...
> Если ваше устройство поддерживает аппаратное ускорение (flow offloading, hardware nat, hardware acceleration), то iptables могут не работать.
> При включенном offloading пакет не проходит по обычному пути netfilter.
> Необходимо или его отключить, или выборочно им управлять.
>
> На Keenetic можно попробовать выключить или наоборот включить [сетевой ускоритель](https://help.keenetic.com/hc/ru/articles/214470905)
