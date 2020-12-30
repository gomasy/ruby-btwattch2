# ruby-btwattch2
Ruby toolkit for the RS-BTWATTCH2 Bluetooth power meter

```
Usage: btwattch2.rb [options]
    -i, --index <index>              Specify adapter index, e.g. hci0.
    -a, --addr <addr>                Specify the destination address.
    -n, --interval <second(s)>       Specify the seconds to wait between updates.
        --on                         Turn on the power switch.
        --off                        Turn off the power switch.
        --set-rtc <time>             Specify the time to set to RTC.
        --set-rtc-now                Set the current time of this system to RTC.
        --test-led                   Blink the LED on the main unit.
```
TBD

## Usage
    # ruby btwattch2.rb --addr CB:DF:6B:12:34:56
    V = 104.29123878479004, A = 1.1373979076743126, W = 106.03327941894531
    V = 104.19976472854614, A = 1.1281732693314552, W = 105.39636832475662
    V = 104.17768478393555, A = 1.1366924941539764, W = 105.92031782865524
    ...

また、[Mackerel](https://mackerel.io) のカスタムメトリック投稿に準拠したフォーマットで出力することも可能です。  
注: メトリクスの epoch は本体の RTC をもとに設定されています。RTC は定期的に同期してください。（後述）

    # ruby mackerel.rb --addr CB:DF:6B:12:34:56
    wattchecker1.voltage    104.80763912200928      1609304963
    wattchecker1.ampere     1.120739296078682       1609304963
    wattchecker1.wattage    104.89565205574036      1609304963
    
### 時刻同期
以下を systemd-timer や cron などで

    # ruby btwattch2.rb --addr CB:DF:6B:12:34:56 --set-rtc-now
